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

    flare_start = '2017-09-10 15:35:00'
    flare_peak = '2017-09-10 16:06:00'
    flare_end = '2017-09-10 16:31:00'

    time_range = [anytim(flare_start), anytim(flare_end)]
    time_range = '2017-09-10'

    save_filename = 'ewq.sav'

    ; Attempting to restore from .sav file
    if file_test(save_filename) then begin

        print, "Restoring from .sav file."
        restore, save_filename
        print, "Restore complete."

    endif else begin

        ;+ ACQUIRING SAA & ECLIPSE TIMES -;
        non_saa_times = fermi_get_gti(time_range)
        non_eclipse_times = fermi_get_dn(time_range)
        observed_times = [[non_saa_times], [non_eclipse_times]]

        ;+ ACQUIRING GOOD DATA -;
        gbm_find_data, date=time_range, dir="~/hessi", file=file
        
        save, filename=save_filename, observed_times, file

    endelse

    gbm_qlook, file, data, synrate


    
    ; timstr = data.utm
    ; extract_fermi_gbm_ql_data, file[0:-2]

    ; for i = 0, 24 do print, (observed_times[0, i+1] - observed_times[1, i]) / 60.
    ; i = 20
    ; print, observed_times[0, i], observed_times[1, i]


    ; observed_times_dims = size(observed_times, /dimensions)

    ; for i = 0, (observed_times_dims[1] - 1) do begin

    ;     print, anytim(observed_times[0, i], /vms), " -> ", anytim(observed_times[1, i], /vms), " Valid: ", anytim(observed_times[0, i]) lt anytim(observed_times[1, i])

    ; endfor

    ; lat_maxlike_plot, time_range
end