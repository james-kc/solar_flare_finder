function rsi_observed_stats, flare_start, flare_peak, flare_end
    ;+ This function accepts flare_start, flare_peak and flare_end as arguments,
    ;  returning a struct containing information about whether RHESSI was
    ;  observing the sun during the solar flare.
    ;-

    ; rsi_observed_stats('2017-09-10 15:35:00', '2017-09-10 16:06:00', '2017-09-10 16:31:00')
    ; rsi_observed_stats('2010-04-13 04:39:00', '2010-04-13 04:43:00', '2010-04-13 04:49:00')
    ; rsi_observed_stats('2010-04-30 19:28:00', '2010-04-30 19:34:00', '2010-04-30 19:38:00')
    ; rsi_observed_stats('2010-05-04 16:15:00', '2010-05-04 16:29:00', '2010-05-04 16:34:00')
    ; rsi_observed_stats('2016-09-08 07:32:00', '2016-09-08 07:35:00', '2016-09-08 07:39:00')

    ;+ SETTING FLARE TIME RANGES -;
    time_range = [flare_start, flare_end]
    that_day = [STRMID(time_range[0], 0, 10), STRMID(time_range[1], 0, 10) + " 23:59:59"]  ; Use this time range to plot data for the entire day flare occured on.

    ;+ CHECKING IF RHESSI DATA EXISTS FOR TIME RANGE -;
    hsi_obj = hsi_obs_summary(obs_time_interval = time_range)
    hsi_data = hsi_obj -> getdata()
    observed = ~array_equal(hsi_data.countrate, 0)  ; Checking if any data exists for time_range

    ;+ PLOTS FOR DEBUGGING -;
    hsi_obj -> plotman

    ; If data exists within time_range, continue to check if RHESSI was observing the sun during this time.
    if (observed eq 1) then begin

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
        plot, data_times, observed_flag, yrange=[-0.1, 1.1]

        ;+ CALCULATING STATS -;
        ; Calculating the number of elements equal to:
        ; - one minute
        elements_to_one_min = ceil(60 / flag_info.time_intv)
        ; - flare_start to flare_peak time
        seconds_to_flare_peak = anytim(flare_peak) - anytim(flare_start)
        elements_to_flare_peak = ceil(seconds_to_flare_peak / flag_info.time_intv)
        ; - 1 min before flare peak
        element_flare_peak_minus_min = elements_to_flare_peak - elements_to_one_min
        ; - 1 min after flare peak
        element_flare_peak_plus_min = elements_to_flare_peak + elements_to_one_min

        observed = ~array_equal(observed_flag, 0)  ; Was RHESSI observing the sun at any time during the flare?
        rsi_flare_triggered = ~array_equal(flare_flag, 0)  ; Did RHESSI detect the flare (flare trigger triggered)?
        frac_obs = total(observed_flag) / n_elements(observed_flag)  ; Fraction of time_range observed by RHESSI.
        flare_start_observed = ~array_equal(observed_flag[0:elements_to_one_min], 0)  ; Was RHESSI observing the sun at any time within 1 min of flare start?
        flare_peak_observed = ~array_equal(observed_flag[element_flare_peak_minus_min:element_flare_peak_plus_min], 0)  ; Was RHESSI observing the sun at any time +/- 1 min of flare peak?
        flare_end_observed = ~array_equal(observed_flag[-elements_to_one_min:-1], 0)  ; Was RHESSI observing the sun at any time within 1 min of flare end?

    endif else begin

        rsi_flare_triggered = 0
        frac_obs = 0.0
        flare_start_observed = 0
        flare_peak_observed = 0
        flare_end_observed = 0

    endelse

    return, {$
        observed: observed, $
        rsi_flare_triggered: rsi_flare_triggered, $
        frac_obs: frac_obs, $
        flare_start_observed: flare_start_observed, $
        flare_peak_observed: flare_peak_observed, $
        flare_end_observed: flare_end_observed $
    }

end
