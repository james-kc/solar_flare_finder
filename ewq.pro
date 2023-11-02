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

    saa_flag = fermi_get_gti(time_range)
    eclipse_flag = fermi_get_dn(time_range)

    foreach time, saa_flag do print, anytim(time, /vms)
end