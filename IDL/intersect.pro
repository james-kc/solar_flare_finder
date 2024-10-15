;+
; Name: intersect
; 
; Purpose:  Returns 1 or 0 depending on whether time-range A intersects with any
;           time ranges contained within B.
; 
; Input:    A is Array[2], containing a start and end time of a
;           particular time range. B is Array[2, x] where x is the number of
;           time intervals present within B.
;          
; Input Keywords:
;
; Returns:  1 or 0 depending on whether A intersects with any of B.
;   
; Examples: intersect(flare_interval, observed_times)
;   
; Written: James Kavanagh-Cranston, 09-Nov-2023
;
;-

function intersect, A, B

    A = anytim(A)
    B = anytim(B)

    i = 0

    len_B = size(B, /n_elements) / size(B, /n_dimensions)

    ; Looping through B array.
    while (i lt len_B) do begin

        a_start = A[0]
        a_end = A[1]
        b_start = B[0, i]
        b_end = B[1, i]

        ; If there is overlap between the two time ranges.
        if (a_start le b_end) and (b_start le a_end) then return, 1

        i ++

    endwhile

    return, 0

end
