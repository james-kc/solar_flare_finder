pro ewq

    ; flare_spe = ['2013-11-09 06:22:00', '2013-11-09 06:38:00', '2013-11-09 06:47:00']
    flare_spe = ['2013-11-09 05:00:00', '2013-11-09 06:38:00', '2013-11-09 08:30:00']

    flare_start = flare_spe[0]
    flare_peak = flare_spe[1]
    flare_end = flare_spe[2]

    time_range = [anytim(flare_start) - 1800, anytim(flare_end) + 1800]

    goes_obj = ogoes()
    goes_obj -> set, tstart = time_range[0], tend = time_range[1], sat = 'goes15'
    xrs_data = goes_obj -> getdata( /struct )

    ; goes_obj -> plotman

    goes_obj -> plotman, /noaa

    ; plot, xrs_data.tarray, xrs_data.yclean[*, 0]

    ; if ( size( xrs_data, /type ) ne 8 ) then begin
    ;     goes_obj -> set, sat = 'goes14'
    ;     xrs_data = goes_obj -> getdata( /struct )
    ; endif   
    ; if ( size( xrs_data, /type ) eq 8 ) then begin
    ; utplot, xrs_data.tarray, xrs_data.yclean[ *, 0 ], xrs_data.utbase, position = [ 0.05, 0.57, 0.46, 0.96 ], /no_timestamp, /xs, yrange = [ 1e-12, 1e-2 ], $
    ;         ystyle = 9, legend = 0, ytitle = 'X-ray Flux (W m!U-2!N)', /ylog, title = goes_obj -> get( /sat ) + ' XRS'
    ; outplot, xrs_data.tarray, xrs_data.yclean[ *, 1 ], line = 1;, thick = 2.

    write_csv, 'instrument_data/2013_goes_time.csv', xrs_data.tarray
    write_csv, 'instrument_data/2013_goes_yclean.csv', xrs_data.yclean
    write_csv, 'instrument_data/2013_goes_utbase.csv', xrs_data.utbase

end