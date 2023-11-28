pro ewq

    flare_spe = ['2013-11-09 06:22:00', '2013-11-09 06:38:00', '2013-11-09 06:47:00']

    wave = 131
    wave = 171
    wave = 193
    wave = 304
    wave = 335

    result = vso_search( $
        '2013-11-09 06:38:00', $
        '2013-11-09 06:38:11', $
        inst='aia', $
        wave=wave, $
        sample=60 $
    )

    help, result, /struct

    aia_lct, rr, gg, bb, wavelnth=wave, /load

    log = vso_get(result, out_dir='aia_fits', filenames=fnames, /rice)

    map = sdo2map(fnames)

    ; aia_prep, fnames, -1, out_index, out_data

    ; index2map, out_index, out_data, map 
    plot_map, map, /log, drange=[1e2,1e4]

    filename='aia_image_2013.png'
    WRITE_PNG, filename, TVRD(/TRUE)

end