;+
; Name: xrt_observed_stats
; 
; Purpose:  This function accepts flare_start, flare_peak and flare_end as
;           arguments, returning a struct containing information about whether
;           Hinode/XRT was observing the sun during the solar flare.
; 
; Calling sequence: xrt_observed_stats(flare_start, flare_peak, flare_end)
; 
; Input:
;   flare_start -   Time at which the flare started, e.g. '2023-10-01 14:44:00'
;   flare_peak -    Time at which the flare peaked, e.g. '2023-10-01 14:47:00'
;   flare_end -     Time at which the flare ended, e.g. '2023-10-01 14:50:00'
;          
; Input Keywords:
;   verbose -   Prints running information.
;
; Returns struct:
;   {
;       xrt_observed,           ; 1:        XRT observing sun during flare.
;                               ; 0:        XRT not observing sun during
;                               ;           flare.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       xrt_frac_obs,           ; 0.0-1.0:  Fraction of the entire flare
;                               ;           observed by XRT.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       xrt_frac_obs_rise,      ; 0.0-1.0:  Fraction of the flare rise phase
;                               ;           observed by XRT.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       xrt_frac_obs_fall       ; 0.0-1.0:  Fraction of the flare fall phase
;                               ;           observed by XRT.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;   }
;   
; Examples: xrt_observed_stats('2017-09-06 11:53:00', '2017-09-06 12:02:00', '2017-09-06 12:10:00', 527.439, -246.826)
;   
; Written: James Kavanagh-Cranston, 10-Nov-2023
;
;-

pro xrt_observed_stats;, flare_start, flare_peak, flare_end, x_pos, y_pos

    flare_spe = ['2017-09-06 23:33:00', '2017-09-06 23:39:00', '2017-09-06 23:44:00']

    flare_start = flare_spe[0]
    flare_peak = flare_spe[1]
    flare_end = flare_spe[2]

    x_pos = 527.439
    y_pos = -246.826

    ;+ SETTING FLARE TIME RANGES -;
    ; Extending time range +60 min -30 min for XRT
    time_range = [anytim(flare_start) - 1800, anytim(flare_end) + 3600] ;; Extend GOES start/end times by 30/60 

    ; flare_interval = [flare_start, flare_end]
    ; rise_interval = [flare_start, flare_peak]
    ; fall_interval = [flare_peak, flare_end]

    ; ; Calculating duration of entire flare and rise and fall phases.
    ; flare_duration = anytim(flare_interval[1]) - anytim(flare_interval[0])
    ; rise_duration = anytim(rise_interval[1]) - anytim(rise_interval[0])
    ; fall_duration = anytim(fall_interval[1]) - anytim(fall_interval[0])

    ;+ AQUIRING EIS RASTERS -;
    ; eis_list_raster, time_range[0], time_range[1], eis_rasters, eis_count, files = eis_files

    ; sot_cat, flare_start, flare_end, /level0, sot_out, sot_files, tcount = sot_count, /urls

    xrt_cat, flare_start, flare_end, xrt_out, xrt_files, /urls

    ; print, xrt_out.xcen
    ; print, xrt_out.ycen

    my_mask = where(xrt_out.xcen lt 580)

    obs_x = xrt_out.xcen
    obs_y = xrt_out.ycen

    x2_plot = xrt_out.xcen + (xrt_out.fovx / 2)
    y2_plot = xrt_out.ycen + (xrt_out.fovy / 2)

    x_plot = obs_x[my_mask]
    y_plot = obs_y[my_mask]

    x0 = xrt_out.xcen - xrt_out.fovx / 2.
    x1 = xrt_out.xcen + xrt_out.fovx / 2.
    y0 = xrt_out.ycen - xrt_out.fovx / 2.
    y1 = xrt_out.ycen + xrt_out.fovx / 2.
    ; draw_boxcorn, x0, y0, x1, y1, /data, color = 6
    ; legend, 'XRT FOV', textcolor = 6, position = [ -1100, -900 ], /data, box = 0

    plot, x0, y0, psym=1
    oplot, x1, y1, psym=1

    ; plot, xrt_out.xcen, xrt_out.ycen, psym=1

    ; image = TVRD()
    ; TVLCT, r, g, b, /Get
    ; write_png, 'test.png', tvrd( /true )

    ; plot, x2_plot, y2_plot, psym=1, $
    ;     xtitle = 'xcen', $
    ;     ytitle = 'ycen'

    ; oplot, x_plot, y_plot, psym=2

    
    ; if (eis_count ne 0) then begin
    ; endif

end