function jul_to_geo_str, julian_date

    CALDAT, julian_date, month, day, year
    georgian_date = strtrim(year, 2) + "-" + strtrim(month, 2) + "-" + strtrim(day, 2)
    
    return, georgian_date

end


function full_her_flare_list, csv_out=csv_out
    
    ; Initialising tstart and tend to be for "all time".
    tstart = julday(09, 01, 2003)  ; tstart (mm, dd, yyyy)
    tend = julday()  ; tend today's date.
    
    her_flare_list = her_flare_list(tstart, tend, csv_out)

    return, her_flare_list

end
