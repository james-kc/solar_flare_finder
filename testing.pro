pro testing
    a = ogoes()

    ; gev = a->get_gev('06-aug-2023', '08-aug-2023', /struct)  ; latest X-class flare
    gev = a->get_gev('14-feb-2011', '16-feb-2011', /struct)  ; X-class flare from lit-review

    help, gev
    ; tstart='07-Aug-2023 00:00'
    ; tend='08-Aug-2023 00:00'

    ; tstart='01-Jan-2019 00:00'
    ; tend='01-Jan-2020 00:00'
    ; a -> set, tstart=tstart, tend=tend

    ; gev = a -> get_gev(tstart, tend, /struct, /class_decode)
    ; gev = a->get_gev('23-jul-2002', '24-jul-2002', /struct, /class_decode)
    ; gev = a -> get_gev(/show)
    ; help, gev
    ; if (gev eq -1) then print, "** No GOES events recorded for time period. **" $
    ; else print, gev
    ; a -> plotman
    ; low = a -> getdata(/low)
    ; high = a -> getdata(/high)
    ; temp = a -> getdata(/temperature)
    ; times = a -> getdata(/times)
    ; utbase = a -> getdata(/utbase)
    ; utplot, times, low, utbase
    ; utplot, times, high, utbase
    ; utplot, times, temp, utbase
    ; utplot, times, deriv(times, low), utbase
end
