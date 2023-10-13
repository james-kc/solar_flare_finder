pro her_update
    ; All time
    ; last_update = '01-jan-0000'
    ; present = '01-jan-2024'

    ; Solar cycle 24
    ; last_update = '01-dec-2008'
    ; present = '01-dec-2019'

    ; X-class flare
    ; last_update = '14-feb-2011' 
    ; present = '16-feb-2011'

    ; Previously missing data
    ; last_update = '01-oct-2012'
    ; present = '01-jan-2013'

    ; last_update = '01-jul-2013'
    ; present = '01-dec-2013'

    last_update = '01-may-2014'
    present = '01-jun-2014'

    ; last_update = '01-feb-2015'
    ; present = '01-mar-2015'

    ; last_update = '01-mar-2016'
    ; present = '01-apr-2016'

    ; last_update = '01-jun-2016'
    ; present = '01-jul-2016'

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
    her_temp = ssw_her_query( ssw_her_make_query( last_update, present, /fl, search=[ 'FRM_NAME=SSW Latest Events' ], result_limit = 1000 ) ) & help, her_temp
    her = her_temp.fl

    ; Number of flares listed in time range
    her_count = n_elements( her )

    print, her_count

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

    ; Populating array with HEK flare list data
    for i = 0, her_count - 1 do ssw_gev_array_temp[i] = { ssw_gev_struct, gev_start[ i ], gev_peak[ i ], gev_end[ i ], goes_class[ i ], aia_loc[ i ], aia_xcen[ i ], aia_ycen[ i ] }

    ; Removing duplicates
    dup = rem_dup( ssw_gev_array_temp.gev_start )
    ssw_gev_array_rem_dup_temp = ssw_gev_array_temp[ dup ]

    ; Remove A-class flares
    aa = where( strmid( ssw_gev_array_rem_dup_temp.goes_class, 0, 1 ) ne 'A' )
    ssw_gev_array = ssw_gev_array_rem_dup_temp[ aa ]
    count = n_elements( ssw_gev_array )

    print, "No. flares found: ", count

    ; Printing flare data
    for i = 0, count -1 do print, ssw_gev_array[i]

    ; filename = last_update + "->" + present + ".csv"
    ; write_csv, filename, ssw_gev_array

end
