;+
; Name: sot_observed_stats
; 
; Purpose:  This function accepts flare_start, flare_peak and flare_end as
;           arguments, returning a struct containing information about whether
;           Hinode/SOT was observing the sun during the solar flare.
; 
; Calling sequence: sot_observed_stats(flare_start, flare_peak, flare_end, flare_x_pos, flare_y_pos)
; 
; Input:
;   flare_start -   Time at which the flare started, e.g. '2023-10-01 14:44:00'
;   flare_peak -    Time at which the flare peaked, e.g. '2023-10-01 14:47:00'
;   flare_end -     Time at which the flare ended, e.g. '2023-10-01 14:50:00'
;   flare_x_pos -   X position of flare on Sun.
;   flare_y_pos -   Y position of flare on Sun.
;          
; Input Keywords:
;   verbose -   Prints running information.
;
; Returns struct:
;   {
;       sot_observed,           ; 1:        SOT observing sun during flare.
;                               ; 0:        SOT not observing sun during
;                               ;           flare.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       sot_rise_observed,      ; 1:        SOT observing sun during flare rise.
;                               ; 0:        SOT not observing sun during
;                               ;           flare rise.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       sot_fall_observed,      ; 1:        SOT observing sun during flare fall.
;                               ; 0:        SOT not observing sun during
;                               ;           flare fall.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;   }
;   
; Examples:
;   sot_observed_stats('2014-03-29 17:35:00', '2014-03-29 17:48:00', '2014-03-29 17:54:00', 503.089, 259.805)
;   sot_observed_stats('2017-09-06 08:57:00', '2017-09-06 09:10:00', '2017-09-06 09:17:00', 501.171, -233.009)
;   sot_observed_stats('2017-09-06 15:51:00', '2017-09-06 15:56:00', '2017-09-06 16:03:00', 555.839, -228.344)
;   sot_observed_stats('2017-09-06 23:33:00', '2017-09-06 23:39:00', '2017-09-06 23:44:00', 607.781, -223.206)
;   sot_observed_stats('2017-09-06 07:29:00', '2017-09-06 07:34:00', '2017-09-06 07:48:00', 510.536, -279.901)
;   
; Written: James Kavanagh-Cranston, 16-Nov-2023
;
;-

function sot_observed_stats, $
    flare_start, $
    flare_peak, $
    flare_end, $
    flare_x_pos, $
    flare_y_pos

    ;+ SETTING FLARE TIME RANGES -;
    ; Extending time range +60 min -30 min for SOT
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
        sot_observed = byte(-1)
        sot_rise_observed = byte(-1)
        sot_fall_observed = byte(-1)

        goto, to_return

    endif

    ; Handling case where flare location unknown
    if ( $
        (typename(flare_x_pos) eq "UNDEFINED") or $
        (typename(flare_y_pos) eq "UNDEFINED") $
    ) then begin

        ; Return an 'error' struct
        sot_observed = byte(-1)
        sot_rise_observed = byte(-1)
        sot_fall_observed = byte(-1)

        goto, to_return

    endif

    ;+ AQUIRING SOT OBS -;
    sot_cat, time_range[0], time_range[1], /level0, sot_out, sot_files, tcount=sot_count, /urls

    ; If no observed times then return unobserved struct
    if (typename(sot_out) eq "INT") then begin

        sot_observed = byte(0)
        sot_rise_observed = byte(0)
        sot_fall_observed = byte(0)

        goto, to_return

    endif

    observed_times = []

    ; Placing raster start (date_obs) and end (date_end) times into an
    ; Array[2, x] where x is sot_count.
    for i = 0, (sot_count - 1) do begin

        ; Determine if the flare is in view of SOT.
        valid_pointing = instr_pointing_valid( $
            flare_x_pos, $
            flare_y_pos, $
            sot_out[i].xcen, $
            sot_out[i].ycen, $
            sot_out[i].fovx, $
            sot_out[i].fovy $
        )

        ; If flare is in view, add time range to observed_times array.
        if valid_pointing then begin

            obs_start = sot_out[i].anytim_dobs
            obs_end = sot_out[i].anytim_dobs + sot_out[i].exptime

            observed_times = [[temporary(observed_times)], [obs_start, obs_end]]

        endif

    endfor

    ; If no observed times then return unobserved struct
    if (typename(observed_times) eq "UNDEFINED") then begin

        sot_observed = byte(0)
        sot_rise_observed = byte(0)
        sot_fall_observed = byte(0)

        goto, to_return

    endif

    ; Converting to "yyyy-mm-dd hh:mm:ss" format.
    observed_times = anytim(observed_times, /vms)

    ;+ DETERMINING OBSERVATION OF FLARE SEGMENTS -;
    flare_observed_interval = interval_intersection(flare_interval, observed_times)
    rise_observed_interval = interval_intersection(rise_interval, observed_times)
    fall_observed_interval = interval_intersection(fall_interval, observed_times)

    sot_observed = ~(typename(flare_observed_interval) eq "UNDEFINED")
    sot_rise_observed = ~(typename(rise_observed_interval) eq "UNDEFINED")
    sot_fall_observed = ~(typename(fall_observed_interval) eq "UNDEFINED")


    to_return:

    return, { $
        sot_observed: sot_observed, $
        sot_rise_observed: sot_rise_observed, $
        sot_fall_observed: sot_fall_observed $
    }

end
