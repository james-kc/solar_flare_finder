pro goes_testing
    a = ogoes()

    ; gev = a->get_gev('06-aug-2023', '08-aug-2023', /struct)  ; latest X-class flare
    ; gev = a->get_gev('14-feb-2011', '16-feb-2011', /struct)  ; X-class flare from lit-review
    gev = a->get_gev('01-may-2014', '01-jun-2014', /struct)  ; missing flare date range
    ; gev = a->get_gev('01-jan-2000', '01-nov-2023', /struct)  ; "all time"

    help, gev[0]
    
    flare_count = n_elements(gev)

    for i = 0, (flare_count - 1) do print, gev[i]
    print, "No. flares in date range: " + flare_count    

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
