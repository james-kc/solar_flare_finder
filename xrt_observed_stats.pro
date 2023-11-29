;+
; Name: xrt_observed_stats
; 
; Purpose:  This function accepts flare_start, flare_peak and flare_end as
;           arguments, returning a struct containing information about whether
;           Hinode/XRT was observing the sun during the solar flare.
; 
; Calling sequence: eis_observed_stats(flare_start, flare_peak, flare_end, flare_x_pos, flare_y_pos)
; 
; Input:
;   flare_start -   Time at which the flare started, e.g. '2023-10-01 14:44:00'
;   flare_peak -    Time at which the flare peaked, e.g. '2023-10-01 14:47:00'
;   flare_end -     Time at which the flare ended, e.g. '2023-10-01 14:50:00'
;   flare_x_pos -   X position of flare on Sun.
;   flare_y_pos -   Y position of flare on Sun.
;
; Returns struct:
;   {
;       xrt_observed,           ; 1:        XRT observing sun during flare.
;                               ; 0:        XRT not observing sun during
;                               ;           flare.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       xrt_rise_observed,      ; 1:        XRT observing sun during flare rise.
;                               ; 0:        XRT not observing sun during
;                               ;           flare rise.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       xrt_fall_observed,      ; 1:        XRT observing sun during flare fall.
;                               ; 0:        XRT not observing sun during
;                               ;           flare fall.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;   }
;   
; Examples:
;   xrt_observed_stats('2017-09-06 11:53:00', '2017-09-06 12:02:00', '2017-09-06 12:10:00', 527.439, -246.826)
;   xrt_observed_stats('2017-09-06 08:57:00', '2017-09-06 09:10:00', '2017-09-06 09:17:00', 501.171, -233.009)
;   
; Written: James Kavanagh-Cranston, 16-Nov-2023
;
;-

function xrt_observed_stats, $
    flare_start, $
    flare_peak, $
    flare_end, $
    flare_x_pos, $
    flare_y_pos, $
    return_pointing=return_pointing

    ;+ SETTING FLARE TIME RANGES -;
    ; Extending time range +60 min -30 min for XRT
    time_range = [anytim(flare_start) - 1800, anytim(flare_end) + 3600]

    flare_interval = [flare_start, flare_end]
    rise_interval = [flare_start, flare_peak]
    fall_interval = [flare_peak, flare_end]

    ; Calculating duration of entire flare and rise and fall phases.
    flare_duration = anytim(flare_interval[1]) - anytim(flare_interval[0])
    rise_duration = anytim(rise_interval[1]) - anytim(rise_interval[0])
    fall_duration = anytim(fall_interval[1]) - anytim(fall_interval[0])

    ;+ HANDLING EXCEPTIONS -;
    ; Handling case where flare_start = flare_peak
    if (flare_start eq flare_peak) then begin

        ; Subtract 1 min from flare_start
        flare_start = anytim(anytim(flare_start) - 60, /vms)

    endif

    ; Handling case where flare_peak = flare_end
    if (flare_peak eq flare_end) then begin

        ; Add 1 min to flare_end
        flare_end = anytim(anytim(flare_end) + 60, /vms)

    endif
    
    ; Handling case where (flare_start < flare_peak < flare_end) = False
    if ( $
        (flare_duration lt 0) or $
        (rise_duration lt 0) or $
        (fall_duration lt 0) $
    ) then begin
        
        ; Return an 'error' struct
        xrt_observed = byte(-1)
        xrt_rise_observed = byte(-1)
        xrt_fall_observed = byte(-1)

        goto, to_return

    endif

    ; Handling case where flare location unknown
    if ( $
        (typename(flare_x_pos) eq "UNDEFINED") or $
        (typename(flare_y_pos) eq "UNDEFINED") $
    ) then begin

        ; Return an 'error' struct
        xrt_observed = byte(-1)
        xrt_rise_observed = byte(-1)
        xrt_fall_observed = byte(-1)

        goto, to_return

    endif

    ;+ AQUIRING XRT OBS -;
    xrt_cat, time_range[0], time_range[1], xrt_out, xrt_files, /urls
    xrt_count = n_elements(xrt_out)

    ; If no observed times then return unobserved struct
    if (typename(xrt_out) eq "INT") then begin

        xrt_observed = byte(0)
        xrt_rise_observed = byte(0)
        xrt_fall_observed = byte(0)

        goto, to_return

    endif

    observed_times = []

    ; Placing raster start (anytim_dobs) and end (anytim_dobs + exptime) times into an
    ; Array[2, x] where x is xrt_count.
    for i = 0, (xrt_count - 1) do begin

        ; Determine if the flare is in view of XRT.
        valid_pointing = instr_pointing_valid( $
            flare_x_pos, $
            flare_y_pos, $
            xrt_out[i].xcen, $
            xrt_out[i].ycen, $
            xrt_out[i].fovx, $
            xrt_out[i].fovy $
        )

        ; If flare is in view, add time range to observed_times array.
        if valid_pointing then begin

            obs_start = xrt_out[i].anytim_dobs
            obs_end = xrt_out[i].anytim_dobs + xrt_out[i].exptime

            observed_times = [[temporary(observed_times)], [obs_start, obs_end]]

        endif

    endfor

    ; If no observed times then return unobserved struct
    if (typename(observed_times) eq "UNDEFINED") then begin

        xrt_observed = byte(0)
        xrt_rise_observed = byte(0)
        xrt_fall_observed = byte(0)

        goto, to_return

    endif

    ; Converting to "yyyy-mm-dd hh:mm:ss" format.
    observed_times = anytim(observed_times, /vms)

    ;+ DETERMINING OBSERVATION OF FLARE SEGMENTS -;
    flare_observed_interval = interval_intersection(flare_interval, observed_times)
    rise_observed_interval = interval_intersection(rise_interval, observed_times)
    fall_observed_interval = interval_intersection(fall_interval, observed_times)

    xrt_observed = ~(typename(flare_observed_interval) eq "UNDEFINED")
    xrt_rise_observed = ~(typename(rise_observed_interval) eq "UNDEFINED")
    xrt_fall_observed = ~(typename(fall_observed_interval) eq "UNDEFINED")

    to_return:

    if keyword_set(return_pointing) then begin

        return, {$
            xcen: xrt_out.xcen, $
            ycen: xrt_out.ycen, $
            fovx: xrt_out.fovx, $
            fovy: xrt_out.fovy $
        }

    endif else begin

        return, { $
            xrt_observed: xrt_observed, $
            xrt_rise_observed: xrt_rise_observed, $
            xrt_fall_observed: xrt_fall_observed $
        }

    endelse

end