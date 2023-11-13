;+
; Name: eve_observed_stats
; 
; Purpose:  This function accepts flare_start, flare_peak and flare_end as
;           arguments, returning a struct containing information about whether
;           SDO/EVE MEGS-A and MEGS-B were observing the sun during the solar
;           flare.
; 
; Calling sequence: eve_observed_stats(flare_start, flare_peak, flare_end)
; 
; Input:
;   flare_start -   Time at which the flare started, e.g. '2023-10-01 14:44:00'
;   flare_peak -    Time at which the flare peaked, e.g. '2023-10-01 14:47:00'
;   flare_end -     Time at which the flare ended, e.g. '2023-10-01 14:50:00'
;
; Returns struct:
;   {
;       megsa_observed,         ; 1:        MEGS-A observing sun during flare.
;                               ; 0:        MEGS-A not observing sun during
;                               ;           flare.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       megsb_observed,         ; 1:        MEGS-B observing sun during flare.
;                               ; 0:        MEGS-B not observing sun during
;                               ;           flare.
;                               ; 255:      Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       megsb_frac_obs,         ; 0.0-1.0:  Fraction of the entire flare
;                               ;           observed by MEGS-B.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       megsb_frac_obs_rise,    ; 0.0-1.0:  Fraction of the flare rise phase
;                               ;           observed by MEGS-B.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;       megsb_frac_obs_fall     ; 0.0-1.0:  Fraction of the flare fall phase
;                               ;           observed by MEGS-B.
;                               ; -1:       Malformed flare_start -> flare_peak
;                               ;           -> flare_end sequence.
;   }
;   
; Examples: eve_observed_stats('2011-11-05 21:23:00', '2011-11-05 21:40:00', '2011-11-05 22:42:00')
;   
; Written: James Kavanagh-Cranston, 09-Nov-2023
;
;-
function eve_observed_stats, flare_start, flare_peak, flare_end

    ;+ SETTING FLARE TIME RANGES -;
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
        megsa_observed = byte(-1)
        megsb_observed = byte(-1)
        megsb_frac_obs = float(-1.0)
        megsb_frac_obs_rise = float(-1.0)
        megsb_frac_obs_fall = float(-1.0)

        goto, to_return

    endif

    ;;;;;;;;;;;;
    ;+ MEGS-A -;
    ;;;;;;;;;;;;

    ; Assume that MEGS-A was observing continuously from launch
    ; until midnight on 26 May 2014
    megsa_lifetime = ['2010-04-30', '2014-05-27']

    ; Determine if solar flare ocurred during the MEGS-A lifetime.
    megsa_observed_interval = interval_intersection(flare_interval, megsa_lifetime)
    megsa_observed = ~(typename(megsa_observed_interval) eq "UNDEFINED")

    ;;;;;;;;;;;;
    ;+ MEGS-B -;
    ;;;;;;;;;;;;

    ;+ READING MEGS-B EXPOSURE HOURS -;

    ; TODO: CHECK IF CSV FILE ALREADY DOWNLOADED AND USE THAT INSEAD OF RE-DOWNLOADING
    ; Read in the ascii file of all SDO/EVE MEGS-B exposure times.
    sock_copy, 'http://lasp.colorado.edu/eve/data_access/evewebdata/interactive/megsb_daily_exposure_hours.csv', $
    'megsb_daily_exposure_hours.dat', out_dir = "~/eve_data", /clobber

    readcol, '~/eve_data/megsb_daily_exposure_hours.dat', date, day_of_yr, exposed_hrs, delim = ',', skipline = 1, format = 'A,I,A'

    ;+ PARSING MEGS-B OBSERVATION TIMES CSV FILE  -;
    ; Removing days where MEGS-B did not observe; where exposed_hrs = -1.
    exposed_day = where( exposed_hrs ne -1 )
    exposed_hrs = exposed_hrs[exposed_day]
    date = date[exposed_day]
    
    eve_count = n_elements(exposed_hrs)

    megsb_observed_times = []

    ; Parsing exposed_hrs array to create megsb_observed_times Array[2, x]
    for i = 0, (eve_count - 1) do begin

        foreach obs_range, str_sep(exposed_hrs[i], ' ') do begin

            ; Creating Array[2] with start and end hour for observation.
            ; e.g: 14-17  ->  [14, 17]
            ; indicating a 4hr observation.
            obs_range = str2arr(obs_range, delimit = '-')

            ; Handle cases where single hour observed; file states "17"
            ; In this case, 17  ->  [17, 17]
            if (n_elements(obs_range) eq 1) then begin
                obs_range = [obs_range, obs_range]
            endif

            obs_start = obs_range[0]
            obs_end = obs_range[1]

            ; Creating string for observation start and end datetime.
            start_dt = `${date[i]} ${obs_start}:00:00`
            end_dt = `${date[i]} ${obs_end}:00:00`

            ; Rounding to nearest hour, adding 1hr to end_dt to include final
            ; hour of observation.
            start_dt = anytim(start_dt)
            end_dt = anytim(end_dt) + 3600

            ; Appending observation start and end datetimes to
            ; megsb_observed_times array.
            megsb_observed_times = [ $
                [temporary(megsb_observed_times)], [start_dt, end_dt] $
            ]

        endforeach

    endfor

    ;+ DETERMINING OBSERVATION OF FLARE SEGMENTS -;
    flare_observed_interval = interval_intersection(flare_interval, megsb_observed_times)
    rise_observed_interval = interval_intersection(rise_interval, megsb_observed_times)
    fall_observed_interval = interval_intersection(fall_interval, megsb_observed_times)

    megsb_observed = ~(typename(flare_observed_interval) eq "UNDEFINED")
    megsb_rise_observed = ~(typename(rise_observed_interval) eq "UNDEFINED")
    megsb_fall_observed = ~(typename(fall_observed_interval) eq "UNDEFINED")

    ;+ DETERMINING OBSERVATION FRACTIONS -;
    if megsb_observed then begin
        megsb_frac_obs = (flare_observed_interval[1] - flare_observed_interval[0]) / flare_duration
        megsb_frac_obs = float(megsb_frac_obs)
    endif else megsb_frac_obs = float(0.0)

    if megsb_rise_observed then begin
        megsb_frac_obs_rise = (rise_observed_interval[1] - rise_observed_interval[0]) / rise_duration
        megsb_frac_obs_rise = float(megsb_frac_obs_rise)
    endif else megsb_frac_obs_rise = float(0.0)

    if megsb_fall_observed then begin
        megsb_frac_obs_fall = (fall_observed_interval[1] - fall_observed_interval[0]) / fall_duration
        megsb_frac_obs_fall = float(megsb_frac_obs_fall)
    endif else megsb_frac_obs_fall = float(0.0)

    to_return:

    return, {$
        megsa_observed: megsa_observed, $
        megsb_observed: megsb_observed, $
        megsb_frac_obs: megsb_frac_obs, $
        megsb_frac_obs_rise: megsb_frac_obs_rise, $
        megsb_frac_obs_fall: megsb_frac_obs_fall $
    }

end