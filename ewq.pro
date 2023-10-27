function jul_to_geo_str, julian_date

    CALDAT, julian_date, month, day, year
    georgian_date = strtrim(year, 2) + "-" + strtrim(month, 2) + "-" + strtrim(day, 2)
    
    return, georgian_date

end

pro ewq

    ;+ TIME RANGE OF FLARE; [FLARE_START, FLARE_END] -;
    ; time_range = ['2010-07-01 20:54:00', '2010-07-01 21:01:00']  ; B1.0
    ; time_range = ['2010-07-09 19:26:00', '2010-07-09 20:16:00']  ; C3.4
    time_range = ['2017-09-10 15:35:00', '2017-09-10 16:31:00']  ; X8.2
    ; time_range = ['2017-09-06 11:53:00', '2017-09-06 12:10:00']  ; X9.3
    that_day = [STRMID(time_range[0], 0, 10), STRMID(time_range[1], 0, 10) + " 23:59:59"]  ; Use this time range to plot data for the entire day flare occured on.

    ;+ RHESSI DATA PLOTS FOR DEBUGGING -;
    hsi_server
    hsi_obj = obj_new('hsi_obs_summary')
    hsi_obj -> set, obs_time_interval = time_range
    hsi_obj -> plotman

    ;+ FLAGS -;
    flag_obj = hsi_obs_summ_flag(obs_time_interval = time_range)
    flag_data = flag_obj -> getdata()  ; Required for acquiring flag info below.

    flag_info = flag_obj -> get(/info)  ; Contains ut_ref for each element of flag_data.
    eclipse_flag = flag_obj -> get(flag_name = 'ECLIPSE_FLAG'); flag_data: 0 0 0 0 1 1 1 1 1 0 0 0.
    saa_flag = flag_obj -> get(flag_name = 'SAA_FLAG'); flag_data: 0 0 0 0 1 1 1 1 1 0 0 0.
    flare_flag = flag_obj -> get(flag_name = 'FLARE_FLAG'); flag_data: 0 0 0 0 1 1 1 1 1 0 0 0.
    
    ;+ PLOTS FOR DEBIGGING -;
    ; flag_obj -> plot, flag_name='ECLIPSE_FLAG'
    ; flag_obj -> plot, flag_name='SAA_FLAG'
    ; flag_obj -> plot, flag_name='FLARE_FLAG'

    ;+ FRACTION ECLIPSED OR SAA -;
    frac_non_obs = total(eclipse_flag or saa_flag) / n_elements(eclipse_flag)  ; Fraction of time_range not observed by RHESSI.
    frac_obs = 1 - frac_non_obs  ; Fraction of time_range observed by RHESSI.

    ; TODO: MAYBE HAVE BOOL VARIABLES FOR FLARE_START_OBSERVED, FLARE_PEAK_OBSERVED, FLARE_END_OBSERVED

    rsi_flare_triggered = ~array_equal(flare_flag, 0)
    if (rsi_flare_triggered eq 1) then rsi_flare_triggered_str = "True" else rsi_flare_triggered_str = "False"

    print, "Fraction of flare observed: ", frac_obs
    print, "RHESSI flare triggered: ", rsi_flare_triggered_str


end