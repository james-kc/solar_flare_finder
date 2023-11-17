;+
; Name: iris_observed_stats
; 
; Purpose:  This function accepts flare_start, flare_peak and flare_end as
;           arguments, returning a struct containing information about whether
;           IRIS was observing the sun during the solar flare.
; 
; Calling sequence: iris_observed_stats(flare_start, flare_peak, flare_end, flare_x_pos, flare_y_pos)
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
;       iris_observed,          ; 1:        IRIS observing sun during flare.
;                               ; 0:        IRIS not observing sun during
;                               ;           flare.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       iris_frac_obs,          ; 0.0-1.0:  Fraction of the entire flare
;                               ;           observed by IRIS.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       iris_frac_obs_rise,     ; 0.0-1.0:  Fraction of the flare rise phase
;                               ;           observed by IRIS.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       iris_frac_obs_fall      ; 0.0-1.0:  Fraction of the flare fall phase
;                               ;           observed by IRIS.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;   }
;
;   Note for iris_frac_*:   This metric is a maximum possible observation of the
;                           flare. Depending on the rastering, it is still
;                           possible for the flare to be unobserved when a 
;                           flare is within FOV of final rastered image.
;   
; Examples:
;   iris_observed_stats('2014-03-29 17:35:00', '2014-03-29 17:48:00', '2014-03-29 17:54:00', 503.089, 259.805)
;   iris_observed_stats('2017-09-06 08:57:00', '2017-09-06 09:10:00', '2017-09-06 09:17:00', 501.171, -233.009)
;   
; Written: James Kavanagh-Cranston, 17-Nov-2023
;
;-

function iris_observed_stats, $
    flare_start, $
    flare_peak, $
    flare_end, $
    flare_x_pos, $
    flare_y_pos

    ;+ SETTING FLARE TIME RANGES -;
    time_range = [anytim(flare_start), anytim(flare_end)]

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
    ; flare_spe = ['2012-09-06 08:57:00', '2012-09-06 09:10:00', '2012-09-06 09:17:00']

    endif
    
    ; Handling case where (flare_start < flare_peak < flare_end) = False
    if ( $
        (flare_duration lt 0) or $
        (rise_duration lt 0) or $
        (fall_duration lt 0) $
    ) then begin
        
        ; Return an 'error' struct
        iris_observed = byte(-1)
        iris_frac_obs = float(-1.0)
        iris_frac_obs_rise = float(-1.0)
        iris_frac_obs_fall = float(-1.0)

        goto, to_return

    endif

    ; Handling case where flare location unknown
    if ( $
        (typename(flare_x_pos) eq "UNDEFINED") or $
        (typename(flare_y_pos) eq "UNDEFINED") $
    ) then begin

        ; Return an 'error' struct
        iris_observed = byte(-1)
        iris_frac_obs = float(-1.0)
        iris_frac_obs_rise = float(-1.0)
        iris_frac_obs_fall = float(-1.0)

        goto, to_return

    endif

    ;+ AQUIRING IRIS RASTERS -;
    iris_rasters = iris_obs2hcr(time_range[0], time_range[1])
    iris_count = n_elements(iris_rasters)

    ; If no observed times then return unobserved struct
    if (typename(iris_rasters) eq "INT") then begin

        iris_observed = byte(0)
        iris_frac_obs = float(0.0)
        iris_frac_obs_rise = float(0.0)
        iris_frac_obs_fall = float(0.0)

        goto, to_return

    endif

    observed_times = []

    ; Placing raster start (date_obs) and end (date_end) times into an
    ; Array[2, x] where x is iris_count.
    for i = 0, (iris_count - 1) do begin

        ; Determine if the flare is in view of IRIS.
        valid_pointing = instr_pointing_valid( $
            flare_x_pos, $
            flare_y_pos, $
            iris_rasters[i].xcen, $
            iris_rasters[i].ycen, $
            iris_rasters[i].xfov, $
            iris_rasters[i].yfov $
        )

        ; If flare is in view, add time range to observed_times array.
        if valid_pointing then begin
            observed_times = [[temporary(observed_times)], [iris_rasters[i].starttime, iris_rasters[i].stoptime]]
        endif

    endfor

    ; If no observed times then return unobserved struct
    if (typename(observed_times) eq "UNDEFINED") then begin

        iris_observed = byte(0)
        iris_frac_obs = float(0.0)
        iris_frac_obs_rise = float(0.0)
        iris_frac_obs_fall = float(0.0)

        goto, to_return

    endif

    ;+ DETERMINING OBSERVATION OF FLARE SEGMENTS -;
    flare_observed_interval = interval_intersection(flare_interval, observed_times)
    rise_observed_interval = interval_intersection(rise_interval, observed_times)
    fall_observed_interval = interval_intersection(fall_interval, observed_times)

    iris_observed = ~(typename(flare_observed_interval) eq "UNDEFINED")
    rise_observed = ~(typename(rise_observed_interval) eq "UNDEFINED")
    fall_observed = ~(typename(fall_observed_interval) eq "UNDEFINED")
    
    ;+ DETERMINING OBSERVATION FRACTIONS -;
    if iris_observed then begin
        iris_frac_obs = total(flare_observed_interval[1,*] - flare_observed_interval[0,*]) / flare_duration
        iris_frac_obs = float(iris_frac_obs)
    endif else iris_frac_obs = float(0.0)

    if rise_observed then begin
        iris_frac_obs_rise = total(rise_observed_interval[1,*] - rise_observed_interval[0,*]) / rise_duration
        iris_frac_obs_rise = float(iris_frac_obs_rise)
    endif else iris_frac_obs_rise = float(0.0)

    if fall_observed then begin
        iris_frac_obs_fall = total(fall_observed_interval[1,*] - fall_observed_interval[0,*]) / fall_duration
        iris_frac_obs_fall = float(iris_frac_obs_fall)
    endif else iris_frac_obs_fall = float(0.0)

    to_return:

    return, {$
        iris_observed: iris_observed, $
        iris_frac_obs: iris_frac_obs, $
        iris_frac_obs_rise: iris_frac_obs_rise, $
        iris_frac_obs_fall: iris_frac_obs_fall $
    }

end
