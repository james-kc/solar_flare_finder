;+
; Name: fermi_observed_stats
; 
; Purpose:  
; 
; Calling sequence: 
; 
; Input:
;          
; Input Keywords:
;
; Returns struct:
;   {
;       observed,               ; 1:        FERMI observing sun during flare.
;                               ; 0:        FERMI not observing sun during
;                               ;           flare.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       rsi_flare_triggered,    ; 1:        Flare present on FERMI flare list.
;                               ; 0:        Flare not present on FERMI flare
;                               ;           list.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       frac_obs,               ; 0.0-1.0:  Fraction of the entire flare
;                               ;           observed by FERMI.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       frac_obs_rise,          ; 0.0-1.0:  Fraction of the flare rise phase
;                               ;           observed by FERMI.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       frac_obs_fall           ; 0.0-1.0:  Fraction of the flare fall phase
;                               ;           observed by FERMI.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;   }
;   
; Examples:
;   
; Written: James Kavanagh-Cranston, 02-Nov-2023
;
;-

pro ewq;, flare_start, flare_peak, flare_end

    ; flare_spe = ['2017-09-10 15:35:00', '2017-09-10 16:06:00', '2017-09-10 16:31:00']
    flare_spe = ['2010-06-13 05:30:00', '2010-06-13 05:39:00', '2010-06-13 05:44:00']
    ; flare_spe = ['2017-09-20 02:51:00', '2017-09-20 02:57:00', '2017-09-20 03:21:00']

    flare_start = flare_spe[0]
    flare_peak = flare_spe[1]
    flare_end = flare_spe[2]

    time_range = [anytim(flare_start), anytim(flare_end)]

    save_filename = `${flare_start}_${flare_end}.sav`

    ; Attempting to restore from .sav file
    if file_test(save_filename) then begin

        print, "Restoring from .sav file."
        restore, save_filename
        print, "Restore complete."

    endif else begin

        ;+ ACQUIRING SAA & ECLIPSE TIMES -;
        non_saa_times = fermi_get_gti(time_range)
        non_eclipse_times = fermi_get_dn(time_range)
        observed_times = interval_intersection(non_saa_times, non_eclipse_times)

        ;+ ACQUIRING GOOD DATA -;
        gbm_find_data, date=time_range, dir="~/hessi", file=file
        
        save, filename=save_filename, observed_times, file

    endelse

    flare_interval = [flare_start, flare_end]
    rise_interval = [flare_start, flare_peak]
    fall_interval = [flare_peak, flare_end]

    intervals = [ $
        [flare_interval], $
        [rise_interval], $
        [fall_interval] $
    ]

    help, observed_times
    obs = interval_intersection(intervals, observed_times)
    help, obs

    ;+ PLOTTING RHESSI LIGHT CURVES -;
    ; hsi_server
    ; hsi_obj = hsi_obs_summary(obs_time_interval = time_range)
    ; hsi_obj -> plotman, /corrected

    ;+ PLOTTING FERMI LIGHT CURVES -;
    ; o = ospex(spex_specfile=file)

    ; peep_file = file[8]
    ; peep_file = file[7]

    ; print, peep_file
    ; o -> set, spex_specfile=peep_file
    ; o -> plot_time, spex_units='flux'

end