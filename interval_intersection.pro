;+
; Name: interval_intersection
; 
; Purpose:  Returns the overlapping intersections of time intervals. Written for
;           use with the Fermi fermi_get_gti and fermi_get_dn functions which
;           return an array of 2 element arrays containing the start and end
;           times for when Fermi is not in eclipse or SAA. Finding the
;           intersection of these arrays will return an array of 2 element
;           arrays describing the times at which Fermi observed the sun.
; 
; Input:    A and B are Array[2, x] where x is number of time ranges in each
;           array.
;          
; Input Keywords:
;
; Returns:  Array[2, x] where x is number of intersections
;   
; Examples: interval_intersection(non_saa_times, non_eclipse_times)
;   
; Written: James Kavanagh-Cranston, 08-Nov-2023
;
;-

function interval_intersection, A, B

    i = 0
    ii = 0
    result = []

    len_A = size(A, /n_elements) / size(A, /n_dimensions)
    len_B = size(B, /n_elements) / size(B, /n_dimensions)

    while (i lt len_A) and (ii lt len_B) do begin

        a_start = A[0, i]
        a_end = A[1, i]
        b_start = B[0, ii]
        b_end = B[1, ii]

        ; If there is overlap between the two time ranges.
        if (a_start le b_end) and (b_start le a_end) then begin

            ; Find the latest start time (time at which overlap begins).
            max_start = max([a_start, b_start])
            ; Find the earliest end time (time at which overlap ends).
            min_end = min([a_end, b_end])

            ; Append overlap time range to result.
            result = [[result], [max_start, min_end]]

        endif

        ; Step one time range ahead for either A or B.
        if (a_end le b_end) then i ++ else ii ++

    endwhile

    return, result

end
