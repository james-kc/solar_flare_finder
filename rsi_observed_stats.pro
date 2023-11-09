;+
; Name: rsi_observed_stats
; 
; Purpose:  This function accepts flare_start, flare_peak and flare_end as
;           arguments, returning a struct containing information about whether
;           RHESSI was observing the sun during the solar flare.
; 
; Calling sequence: rsi_observed_stats(flare_start, flare_peak, flare_end, $
;                   /debug, /verbose)
; 
; Input:
;   flare_start -   Time at which the flare started, e.g. '2023-10-01 14:44:00'
;   flare_peak -    Time at which the flare peaked, e.g. '2023-10-01 14:47:00'
;   flare_end -     Time at which the flare ended, e.g. '2023-10-01 14:50:00'
;          
; Input Keywords:
;   debug -     Plots RHESSI data and flags for debugging purposes.
;   verbose -   Prints flare start, peak and end times as well as array element
;               information.
;
; Returns struct:
;   {
;       rsi_observed,           ; 1:        RHESSI observing sun during flare.
;                               ; 0:        RHESSI not observing sun during
;                               ;           flare.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       rsi_flare_triggered,    ; 1:        Flare present on RHESSI flare list.
;                               ; 0:        Flare not present on RHessi flare
;                               ;           list.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       rsi_frac_obs,               ; 0.0-1.0:  Fraction of the entire flare
;                               ;           observed by RHESSI.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       rsi_frac_obs_rise,          ; 0.0-1.0:  Fraction of the flare rise phase
;                               ;           observed by RHESSI.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       rsi_frac_obs_fall           ; 0.0-1.0:  Fraction of the flare fall phase
;                               ;           observed by RHESSI.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;   }
;   
; Examples:
;   rsi_observed_stats('2017-09-10 15:35:00', '2017-09-10 16:06:00', $
;   '2017-09-10 16:31:00')
;
;   rsi_observed_stats('2010-06-13 05:30:00', '2010-06-13 05:39:00', $
;   '2010-06-13 05:44:00')
;   
; Written: James Kavanagh-Cranston, 02-Nov-2023
;
;-

function rsi_observed_stats, $
    flare_start, $
    flare_peak, $
    flare_end, $
    debug=debug, $
    verbose=verbose

    ; rsi_observed_stats('2017-09-10 15:35:00', '2017-09-10 16:06:00', '2017-09-10 16:31:00')
    ; rsi_observed_stats('2010-04-13 04:39:00', '2010-04-13 04:43:00', '2010-04-13 04:49:00')
    ; rsi_observed_stats('2010-04-30 19:28:00', '2010-04-30 19:34:00', '2010-04-30 19:38:00')
    ; rsi_observed_stats('2010-05-04 16:15:00', '2010-05-04 16:29:00', '2010-05-04 16:34:00')
    ; rsi_observed_stats('2016-09-08 07:32:00', '2016-09-08 07:35:00', '2016-09-08 07:39:00')
    ; rsi_observed_stats('2010-06-12 00:30:00', '2010-06-12 00:57:00', '2010-06-12 01:02:00')
    ; rsi_observed_stats('2010-06-11 23:56:00', '2010-06-12 00:02:00', '2010-06-12 00:04:00')
    ; rsi_observed_stats('2010-06-12 00:30:00', '2010-06-12 00:33:00', '2010-06-12 00:33:00')
    ; rsi_observed_stats('2010-06-13 05:30:00', '2010-06-13 05:39:00', '2010-06-13 05:44:00')
    ; rsi_observed_stats('2011-04-11 23:40:00', '2011-04-11 00:00:00', '2011-04-12 00:03:00')
    ; rsi_observed_stats('2017-09-06 11:53:00', '2017-09-06 12:02:00', '2017-09-06 12:10:00')

    ; rsi_observed_stats('2010-06-12 00:30:00', '2010-06-12 00:57:00', '2010-06-12 01:02:00')
    ; rsi_observed_stats('2014-06-03 03:58:00', '2014-06-03 04:09:00', '2014-06-03 04:17:00')
    ; rsi_observed_stats('2010-06-13 05:30:00', '2010-06-13 05:39:00', '2010-06-13 05:44:00')

    ; rsi_observed_stats('2012-09-17 11:35:00', '2012-09-17 11:46:00', '2012-09-17 12:01:00')
    ; rsi_observed_stats('2014-01-31 04:46:00', '2014-01-31 05:05:00', '2014-01-31 05:17:00')
    ; rsi_observed_stats('2017-09-20 02:51:00', '2017-09-20 02:57:00', '2017-09-20 03:21:00')



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
    if ~( $
        (anytim(flare_start) lt anytim(flare_peak)) and $
        (anytim(flare_peak) lt anytim(flare_end)) $
    ) then begin

        ; Return an 'error' struct
        rsi_observed = byte(-1)
        rsi_flare_triggered = byte(-1)
        rsi_frac_obs = -1.0
        rsi_frac_obs_rise = -1.0
        rsi_frac_obs_fall = -1.0

        goto, to_return

    endif

    ;+ SETTING FLARE TIME RANGES -;
    time_range = [flare_start, flare_end]
    that_day = [STRMID(time_range[0], 0, 10), STRMID(time_range[1], 0, 10) + " 23:59:59"]  ; Use this time range to plot data for the entire day flare occured on.

    ;+ CHECKING IF RHESSI DATA EXISTS FOR TIME RANGE -;
    hsi_server
    hsi_obj = hsi_obs_summary(obs_time_interval = time_range)
    hsi_data = hsi_obj -> getdata()

    if ~tag_exist(hsi_data, "countrate") then begin

        rsi_observed = byte(0)
        rsi_flare_triggered = byte(0)
        rsi_frac_obs = 0.0
        rsi_frac_obs_rise = 0.0
        rsi_frac_obs_fall = 0.0

        goto, to_return

    endif

    rsi_observed = ~array_equal(hsi_data.countrate, 0)  ; Checking if any data exists for time_range

    ;+ PLOTS FOR DEBUGGING -;
    if keyword_set(debug) then hsi_obj -> plotman, /corrected

    ; If data exists within time_range, continue to check if RHESSI was observing the sun during this time.
    if (rsi_observed eq 1) then begin

        ;+ FLAGS -;
        flag_obj = hsi_obs_summ_flag(obs_time_interval = time_range)
        flag_data = flag_obj -> getdata()  ; Required for acquiring flag info below.

        flag_info = flag_obj -> get(/info)  ; Contains ut_ref for each element of flag_data.
        eclipse_flag = flag_obj -> get(flag_name = 'ECLIPSE_FLAG'); flag_data: 0 0 0 0 1 1 1 1 1 0 0 0.
        saa_flag = flag_obj -> get(flag_name = 'SAA_FLAG'); flag_data: 0 0 0 0 1 1 1 1 1 0 0 0.
        flare_flag = flag_obj -> get(flag_name = 'FLARE_FLAG'); flag_data: 0 0 0 0 1 1 1 1 1 0 0 0.
        
        observed_flag = ~(saa_flag or eclipse_flag) 
        data_times = flag_obj -> get(/time_array)

        ;+ PLOTS FOR DEBUGGING -;
        ; flag_obj -> plot, flag_name='ECLIPSE_FLAG'
        ; flag_obj -> plot, flag_name='SAA_FLAG'
        ; flag_obj -> plot, flag_name='FLARE_FLAG'
        if keyword_set(debug) then begin
            plot, data_times, observed_flag, yrange=[-0.1, 1.1]
        endif

        ;+ CALCULATING STATS -;
        ; Calculating the number of elements between flare_start and flare_peak
        ; times.
        seconds_to_flare_peak = anytim(flare_peak) - anytim(flare_start)
        elements_to_flare_peak = ceil(seconds_to_flare_peak / flag_info.time_intv)

        if keyword_set(verbose) then begin
            print, `Flare Start: ${flare_start}`
            print, `Flare Peak: ${flare_peak}`
            print, `Flare End: ${flare_end}`
            print, `Elements to flare peak: ${elements_to_flare_peak}`
            print, `Total Number of Elements: ${n_elements(observed_flag)}`
        endif

        rsi_observed = ~array_equal(observed_flag, 0)  ; Was RHESSI observing the sun at any time during the flare?
        rsi_flare_triggered = ~array_equal(flare_flag, 0)  ; Did RHESSI detect the flare (flare trigger triggered)?
        rsi_frac_obs = total(observed_flag) / n_elements(observed_flag)  ; Fraction of time_range observed by RHESSI.

        rsi_frac_obs_rise = total(observed_flag[0:elements_to_flare_peak]) / n_elements(observed_flag[0:elements_to_flare_peak])
        rsi_frac_obs_fall = total(observed_flag[elements_to_flare_peak:-1]) / n_elements(observed_flag[elements_to_flare_peak:-1])

    endif else begin

        rsi_flare_triggered = byte(0)
        rsi_frac_obs = 0.0
        rsi_frac_obs_rise = 0.0
        rsi_frac_obs_fall = 0.0

    endelse

    to_return:

    return, {$
        rsi_observed: rsi_observed, $
        rsi_flare_triggered: rsi_flare_triggered, $
        rsi_frac_obs: rsi_frac_obs, $
        rsi_frac_obs_rise: rsi_frac_obs_rise, $
        rsi_frac_obs_fall: rsi_frac_obs_fall $
    }

end
