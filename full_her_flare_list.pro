function jul_to_geo_str, julian_date

    CALDAT, julian_date, month, day, year
    georgian_date = strtrim(year, 2) + "-" + strtrim(month, 2) + "-" + strtrim(day, 2)
    
    return, georgian_date

end


function full_her_flare_list, csv_out=csv_out
    
    ; Initialising tstart and tend to be for "all time".
    tstart = julday(09, 01, 2003)  ; tstart (mm, dd, yyyy)
    tend = julday()  ; tend today's date.
    ; tend = julday(01, 01, 2005)  ; tend (mm, dd, yyyyy).
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
        ; tstep = tstep + 365  ; Adding 365 days to the previous time range end.

        ; Changing from julday to georgian str.
        tstep_last_g = jul_to_geo_str(tstep_last)
        tstep_g = jul_to_geo_str(tstep)
        
        print, "Current query range: " + tstep_last_g + " to " + tstep_g

        ; Querying between last tstep and current tstep.
        her = her_flare_list(tstep_last_g, tstep_g)

        if ~is_struct(her) then begin 
            missing_time_ranges = [missing_time_ranges, [tstep_last_g + " to " + tstep_g]]
            continue
        endif

        her_flare_list = [her_flare_list, her]

        ; Printing a blank line for terminal spacing.
        print, ""

    ; Repeating until tstep_last is greater than tend meaning the previously completed query searched for flares up to or past tend date.    
    endrep until (tstep_last ge tend)

    ; Writing output to csv
    if keyword_set(csv_out) then begin
        file_mkdir, 'flare_lists_csv'
        filename_fl = "flare_lists_csv/her_" + tstart_g + "_" + tstep_g + ".csv"
        headers = tag_names(her_flare_list)
        write_csv, filename_fl, her_flare_list, header=headers

        filename_tr = "flare_lists_csv/her_empty_months" + tstart_g + "_" + tstep_g + ".csv"
        write_csv, filename_tr, missing_time_ranges
    endif

    print, missing_time_ranges

    return, her_flare_list

end
