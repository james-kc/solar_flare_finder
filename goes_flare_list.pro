function goes_flare_list, tstart, tend, csv_out=csv_out

    a = ogoes()  ; Initialising goes object.

    gev = a->get_gev(tstart, tend, /struct)  ; Acquiring flare list for date range.

    help, gev  ; Temp line
    help, gev[0]  ; Temp line

    ; Removing duplicates
    dup = rem_dup(gev.gstart)
    gev_no_dup = gev[dup]

    flare_count = n_elements(gev_no_dup)  ; Number of flares observed within the time range.

    for i = 0, (flare_count - 1) do print, gev_no_dup[i]  ; Printing the returned array of structs.

    print, "No. flares in date range: " + string(flare_count)

    ; Writing output to csv
    if keyword_set(csv_out) then begin
        file_mkdir, 'flare_lists_csv'
        filename = "flare_lists_csv/gev_" + tstart + "_" + tend + ".csv"
        headers = tag_names(gev_no_dup)
        write_csv, filename, gev_no_dup, header=headers
    endif

    return, gev_no_dup

end
