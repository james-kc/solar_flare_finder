;+
; Name: fermi_observed_stats
; 
; Purpose:  This function accepts flare_start, flare_peak and flare_end as
;           arguments, returning a struct containing information about whether
;           FERMI was observing the sun during the solar flare.
; 
; Calling sequence: fermi_observed_stats(flare_start, flare_peak, flare_end)
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
;       fermi_observed,         ; 1:        FERMI observing sun during flare.
;                               ; 0:        FERMI not observing sun during
;                               ;           flare.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       fermi_frac_obs,         ; 0.0-1.0:  Fraction of the entire flare
;                               ;           observed by FERMI.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       fermi_frac_obs_rise,    ; 0.0-1.0:  Fraction of the flare rise phase
;                               ;           observed by FERMI.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       fermi_frac_obs_fall     ; 0.0-1.0:  Fraction of the flare fall phase
;                               ;           observed by FERMI.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;   }
;   
; Examples: fermi_observed_stats('2017-09-10 15:35:00', '2017-09-10 16:06:00', '2017-09-10 16:31:00')
;           fermi_observed_stats('2010-06-13 05:30:00', '2010-06-13 05:39:00', '2010-06-13 05:44:00')
;           fermi_observed_stats('2017-09-20 02:51:00', '2017-09-20 02:57:00', '2017-09-20 03:21:00')
;           fermi_observed_stats('2017-09-06 11:53:00', '2017-09-06 12:02:00', '2017-09-06 12:10:00')
;
;           fermi_observed_stats('2017-09-06 06:17:00', '2017-09-06 06:22:00', '2017-09-06 06:29:00')
;           fermi_observed_stats('2017-09-06 07:29:00', '2017-09-06 07:34:00', '2017-09-06 07:48:00')
;           fermi_observed_stats('2017-09-06 08:57:00', '2017-09-06 09:10:00', '2017-09-06 09:17:00')
;           fermi_observed_stats('2017-09-06 08:35:00', '2017-09-06 09:27:00', '2017-09-06 11:00:00')
;           fermi_observed_stats('2017-09-06 11:53:00', '2017-09-06 12:02:00', '2017-09-06 12:10:00')
;           fermi_observed_stats('2017-09-06 15:51:00', '2017-09-06 15:56:00', '2017-09-06 16:03:00')
;           fermi_observed_stats('2017-09-06 19:21:00', '2017-09-06 19:30:00', '2017-09-06 19:35:00')
;           fermi_observed_stats('2017-09-06 23:33:00', '2017-09-06 23:39:00', '2017-09-06 23:44:00')
;   
; Written: James Kavanagh-Cranston, 09-Nov-2023
;
;-

function fermi_observed_stats, $
    flare_start, $
    flare_peak, $
    flare_end, $
    verbose=verbose

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

    endif
    
    ; Handling case where (flare_start < flare_peak < flare_end) = False
    if ( $
        (flare_duration lt 0) or $
        (rise_duration lt 0) or $
        (fall_duration lt 0) $
    ) then begin
        
        ; Return an 'error' struct
        fermi_observed = byte(-1)
        fermi_frac_obs = float(-1.0)
        fermi_frac_obs_rise = float(-1.0)
        fermi_frac_obs_fall = float(-1.0)

        goto, to_return

    endif

    flare_day_start = STRMID(flare_start, 0, 10)
    flare_day_start = STRMID(flare_end, 0, 10)

    save_filename = `fermi_sav_files/${flare_day_start}_${flare_day_start}.sav`

    ; Attempting to restore from .sav file
    if file_test(save_filename) then begin

        if keyword_set(verbose) then print, "Restoring from .sav file."
        restore, save_filename
        if keyword_set(verbose) then print, "Restore complete."

    endif else begin

        ;+ ACQUIRING SAA & ECLIPSE TIMES -;
        if keyword_set(verbose) then print, "Acquiring non_saa_times..."
        non_saa_times = fermi_get_gti(time_range)

        if keyword_set(verbose) then print, "Acquiring non_eclipse_times..."
        non_eclipse_times = fermi_get_dn(time_range)

        ; Finding the time intervals where FERMI is not in SAA or in eclipse.
        observed_times = interval_intersection(non_saa_times, non_eclipse_times)
        
        ; Saving observed_times.
        save, filename=save_filename, observed_times
        if keyword_set(verbose) then print, ".sav file created."

    endelse

    ;+ DETERMINING OBSERVATION OF FLARE SEGMENTS -;
    flare_observed_interval = interval_intersection(flare_interval, observed_times)
    rise_observed_interval = interval_intersection(rise_interval, observed_times)
    fall_observed_interval = interval_intersection(fall_interval, observed_times)

    fermi_observed = ~(typename(flare_observed_interval) eq "UNDEFINED")
    rise_observed = ~(typename(rise_observed_interval) eq "UNDEFINED")
    fall_observed = ~(typename(fall_observed_interval) eq "UNDEFINED")

    ;+ DETERMINING OBSERVATION FRACTIONS -;
    if fermi_observed then begin
        fermi_frac_obs = (flare_observed_interval[1] - flare_observed_interval[0]) / flare_duration
        fermi_frac_obs = float(fermi_frac_obs)
    endif else fermi_frac_obs = float(0.0)

    if rise_observed then begin
        fermi_frac_obs_rise = (rise_observed_interval[1] - rise_observed_interval[0]) / rise_duration
        fermi_frac_obs_rise = float(fermi_frac_obs_rise)
    endif else fermi_frac_obs_rise = float(0.0)

    if fall_observed then begin
        fermi_frac_obs_fall = (fall_observed_interval[1] - fall_observed_interval[0]) / fall_duration
        fermi_frac_obs_fall = float(fermi_frac_obs_fall)
    endif else fermi_frac_obs_fall = float(0.0)
    
    to_return:

    return, {$
        fermi_observed: fermi_observed, $
        fermi_frac_obs: fermi_frac_obs, $
        fermi_frac_obs_rise: fermi_frac_obs_rise, $
        fermi_frac_obs_fall: fermi_frac_obs_fall $
    }

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