pro plotter

    ; time_range = ['2010-06-12 00:30:00', '2010-06-12 01:02:00']
    ; time_range = ['2014-06-03 03:58:00', '2014-06-03 04:17:00']
    time_range = ['2017-09-10 15:35:00', '2017-09-10 16:31:00']
    
    hsi_server
    hsi_obj = hsi_obs_summary(obs_time_interval = time_range)

    hsi_obj -> plotman, /corrected

end