;+
; Name: eis_observed_stats
; 
; Purpose:  This function accepts flare_start, flare_peak and flare_end as
;           arguments, returning a struct containing information about whether
;           Hinode/EIS was observing the sun during the solar flare.
; 
; Calling sequence: eis_observed_stats(flare_start, flare_peak, flare_end)
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
;       eis_observed,           ; 1:        EIS observing sun during flare.
;                               ; 0:        EIS not observing sun during
;                               ;           flare.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       eis_frac_obs,           ; 0.0-1.0:  Fraction of the entire flare
;                               ;           observed by EIS.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       eis_frac_obs_rise,      ; 0.0-1.0:  Fraction of the flare rise phase
;                               ;           observed by EIS.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       eis_frac_obs_fall       ; 0.0-1.0:  Fraction of the flare fall phase
;                               ;           observed by EIS.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;   }
;   
; Examples:     eis_observed_stats('2014-03-29 17:35:00', '2014-03-29 17:48:00', '2014-03-29 17:54:00', 503.089	259.805)
;   
; Written: James Kavanagh-Cranston, 10-Nov-2023
;
;-

function ewq;, flare_start, flare_peak, flare_end, x_pos, y_pos

    status = fix_zdbase( /EIS )

    flare_spe = ['2014-03-29 17:35:00', '2014-03-29 17:48:00', '2014-03-29 17:54:00']

    flare_start = flare_spe[0]
    flare_peak = flare_spe[1]
    flare_end = flare_spe[2]

    x_pos = 503.089
    y_pos = 259.805

    ;+ SETTING FLARE TIME RANGES -;
    ; Extending time range +/- 4hr for EIS_LIST_RASTER
    time_range = [anytim(anytim(flare_start) - 14400, /vms), anytim(anytim(flare_end) + 14400, /vms)]

    flare_interval = [flare_start, flare_end]
    rise_interval = [flare_start, flare_peak]
    fall_interval = [flare_peak, flare_end]

    ; ; Calculating duration of entire flare and rise and fall phases.
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
        eis_observed = byte(-1)
        eis_frac_obs = float(-1.0)
        eis_frac_obs_rise = float(-1.0)
        eis_frac_obs_fall = float(-1.0)

        goto, to_return

    endif

    ;+ AQUIRING EIS RASTERS -;
    eis_list_raster, time_range[0], time_range[1], eis_rasters, eis_count, files = eis_files

    observed_times = []

    ; Placing raster start (date_obs) and end (date_end) times into an
    ; Array[2, x] where x is eis_count.
    for i = 0, (eis_count - 1) do begin
        observed_times = [[temporary(observed_times)], [eis_rasters[i].date_obs, eis_rasters[i].date_end]]
    endfor

    ; Converting to "yyyy-mm-dd hh:mm:ss" format.
    observed_times = anytim2utc(observed_times, /vms)

    ;+ DETERMINING OBSERVATION OF FLARE SEGMENTS -;
    flare_observed_interval = interval_intersection(flare_interval, observed_times)
    rise_observed_interval = interval_intersection(rise_interval, observed_times)
    fall_observed_interval = interval_intersection(fall_interval, observed_times)

    eis_observed = ~(typename(flare_observed_interval) eq "UNDEFINED")
    rise_observed = ~(typename(rise_observed_interval) eq "UNDEFINED")
    fall_observed = ~(typename(fall_observed_interval) eq "UNDEFINED")
    
    ;+ DETERMINING OBSERVATION FRACTIONS -;
    if eis_observed then begin
        eis_frac_obs = total(flare_observed_interval[1,*] - flare_observed_interval[0,*]) / flare_duration
        eis_frac_obs = float(eis_frac_obs)
    endif else eis_frac_obs = float(0.0)

    if rise_observed then begin
        eis_frac_obs_rise = total(rise_observed_interval[1,*] - rise_observed_interval[0,*]) / rise_duration
        eis_frac_obs_rise = float(eis_frac_obs_rise)
    endif else eis_frac_obs_rise = float(0.0)

    if fall_observed then begin
        eis_frac_obs_fall = total(fall_observed_interval[1,*] - fall_observed_interval[0,*]) / fall_duration
        eis_frac_obs_fall = float(eis_frac_obs_fall)
    endif else eis_frac_obs_fall = float(0.0)

    eis_rasters.xcen
    eis_rasters.ycen
    eis_rasters.fovx
    eis_rasters.fovy
    

    to_return:

    return, {$
        eis_observed: eis_observed, $
        eis_frac_obs: eis_frac_obs, $
        eis_frac_obs_rise: eis_frac_obs_rise, $
        eis_frac_obs_fall: eis_frac_obs_fall $
    }

end
