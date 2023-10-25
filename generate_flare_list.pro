pro generate_flare_list

    tstart='2010-04-11'  ; SDO first light
    tend='2019-06-01'  ; End of solar cycle 24

    her = her_flare_list_query(tstart, tend)
    gev = goes_flarelist(tstart, tend)

    spawn, "python3 testing.py" + tstart + tend
    print, "After?"

end
