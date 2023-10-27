pro generate_flare_list, tstart, tend

    ; generate_flare_list, '2023-10-01', '2023-10-02'

    ; Solar Cycle 24 ish
    ; generate_flare_list, '2010-04-11', '2019-06-01'

    ; tstart='2010-04-11'  ; SDO first light
    ; tend='2019-06-01'  ; End of solar cycle 24

    tstart_her = tstart
    tend_her = tend

    tstart_gev = tstart
    tend_gev = tend

    her_output = her_flare_list(tstart_her, tend_her, /csv_out)
    gev_output = goes_flare_list(tstart_gev, tend_gev, /csv_out)

    her = her_output.data
    her_filename = her_output.filename

    gev = gev_output.data
    gev_filename = gev_output.filename

    spawn, "source venv/bin/activate && python3 flare_list_joiner.py " + her_filename + " " + gev_filename + " verbose"

end
