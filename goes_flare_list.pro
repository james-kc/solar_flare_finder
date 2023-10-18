function goes_flare_list, tstart, tend

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

    return, gev_no_dup

end
