function her_flare_list_query, tstart, tend, csv_out=csv_out

    ; All time
    ; tstart = '01-jan-0000'
    ; tend = '01-jan-2024'

    ; Solar cycle 24
    ; tstart = '01-dec-2008'
    ; tend = '01-dec-2019'

    ; X-class flare
    ; tstart = '14-feb-2011' 
    ; tend = '16-feb-2011'

    ; Previously missing data
    ; tstart = '01-oct-2012'
    ; tend = '01-jan-2013'

    ; tstart = '01-jul-2013'
    ; tend = '01-dec-2presentb-2015'
    ; tend = '01-mar-2015'

    ; tstart = '01-mar-2016'
    ; tend = '01-apr-2016'

    ; tstart = '01-jun-2016'
    ; tend = '01-jul-2016'

    ; Running HEK query 
    ; Returns:
    ; {
    ;     fl:[
    ;         {flr-1}, 
    ;         {flr-2}, 
    ;         ..., 
    ;         {flr-n}
    ;     ]
    ; }

    ; her queries are limited to 1,000 and will never return more than 1,000 results, even when result_limit > 1,000.
    her_temp = ssw_her_query( ssw_her_make_query( tstart, tend, /fl, search=[ 'FRM_NAME=SSW Latest Events' ], result_limit = 1000) ); & help, her_temp
    
    ; If no flares are found, return her_temp
    if ~is_struct(her_temp) then return, her_temp
    
    her = her_temp.fl

    ; Number of flares listed in time range
    her_count = n_elements( her )

    ; Extracting useful fields
    gev_start = her.event_starttime
    gev_peak = her.event_peaktime
    gev_end = her.event_endtime
    goes_class = her.fl_goescls
    ;xdum = her.fl.event_coord1
    ;ydum = her.fl.event_coord2
    aia_xcen = her.hpc_x
    aia_ycen = her.hpc_y
    aia_xhel = her.hgs_x
    aia_yhel = her.hgs_y
    aia_loc = strarr( her_count )

    ; Creates an array with no. elements = her_count. Each element is a struct with gev_start, gev_peak, gev_end, goes_class, aia_loc, aia_xcen & aia_ycen
    ssw_gev_array_temp = REPLICATE( { ssw_gev_struct, gev_start:' ', gev_peak:' ', gev_end:' ', goes_class:' ', aia_loc:' ', aia_xcen:0E, aia_ycen:0E }, her_count )

    ; Converting between solar coordinate systems
    for i = 0, her_count-1 do aia_loc[ i ] = conv_a2h( [ aia_xcen[ i ], aia_ycen[ i ] ], /string )

    ; Populating array with HEK flare list data
    for i = 0, her_count - 1 do ssw_gev_array_temp[i] = { ssw_gev_struct, gev_start[ i ], gev_peak[ i ], gev_end[ i ], goes_class[ i ], aia_loc[ i ], aia_xcen[ i ], aia_ycen[ i ] }

    ; Removing duplicates
    dup = rem_dup( ssw_gev_array_temp.gev_peak )
    ssw_gev_array_rem_dup_temp = ssw_gev_array_temp[ dup ]

    ; Remove A-class flares
    aa = where( strmid( ssw_gev_array_rem_dup_temp.goes_class, 0, 1 ) ne 'A' )
    ssw_gev_array = ssw_gev_array_rem_dup_temp[ aa ]
    count = n_elements( ssw_gev_array )

    ; Printing flare data
    ; for i = 0, count -1 do print, ssw_gev_array[i]

    print, "No. flares found: ", count

    ; Writing output to csv
    if keyword_set(csv_out) then begin
        file_mkdir, 'flare_lists_csv'
        filename = "flare_lists_csv/her_" + tstart + "_" + tend + ".csv"
        headers = tag_names(ssw_gev_array)
        write_csv, filename, ssw_gev_array, header=headers
    endif

    return, ssw_gev_array

end

function jul_to_geo_str, julian_date

    CALDAT, julian_date, month, day, year
    georgian_date = strtrim(year, 2) + "-" + strtrim(month, 2) + "-" + strtrim(day, 2)
    
    return, georgian_date

end


function her_flare_list, tstart, tend, csv_out=csv_out
    
    ; Converting tstart and tend to Julian date
    tstart = date_conv(tstart, 'J')
    tend = date_conv(tend, 'J')

    ; Initialising loop parameters
    tstep = tstart  ; First 30-day step forward.
    tstep_last = tstart  ; The tstep of the previous loop.

    her_flare_list = []
    missing_time_ranges = []

    ; Printing dates in human-readable format; yyyy-mm-dd.
    tstart_g = jul_to_geo_str(tstart)
    tend_g = jul_to_geo_str(tend)

    print, tstart_g + " to " + tend_g
    print, ""

    repeat begin
        ; tstep and tstep_last are initially equal to tstart.
        tstep_last = tstep  ; Saving the previous tstep value to serve as the beginning of the queried time range.
        tstep = tstep + 30  ; Adding 30 days to the previous time range end.
        if (tstep gt tend) then tstep = tend
        ; tstep = tstep + 365  ; Adding 365 days to the previous time range end.

        ; Changing from julday to georgian str.
        tstep_last_g = jul_to_geo_str(tstep_last)
        tstep_g = jul_to_geo_str(tstep)
        
        print, "Current query range: " + tstep_last_g + " to " + tstep_g

        ; Querying between last tstep and current tstep.
        her = her_flare_list_query(tstep_last_g, tstep_g)

        if ~is_struct(her) then begin 
            missing_time_ranges = [missing_time_ranges, [tstep_last_g + " to " + tstep_g]]
            continue
        endif

        her_flare_list = [her_flare_list, her]

        ; Printing a blank line for terminal spacing.
        print, ""

    ; Repeating until tstep_last is greater than tend meaning the previously completed query searched for flares up to or past tend date.    
    endrep until (tstep ge tend)

    ; Writing output to csv
    if keyword_set(csv_out) then begin
        file_mkdir, 'flare_lists_csv'
        filename_fl = "flare_lists_csv/her_" + tstart_g + "_" + tstep_g + ".csv"
        headers = tag_names(her_flare_list)
        write_csv, filename_fl, her_flare_list, header=headers

        filename_tr = "flare_lists_csv/her_empty_months" + tstart_g + "_" + tstep_g + ".csv"
        if (n_elements(missing_time_ranges) gt 0) then write_csv, filename_tr, missing_time_ranges
    endif

    print, "No. HER flares in date range: " + string(n_elements(her_flare_list))
    print, "Missing time ranges:"
    print, missing_time_ranges

    return, her_flare_list

end
