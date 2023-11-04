;+
; Name: goes_flare_list
; 
; Purpose:  
; 
; Calling sequence: goes_flare_list(tstart, tend, csv_out=csv_out)
; 
; Input:
;   tstart -
;   tend -
;          
; Input Keywords:
;   csv_out -     
;
; Returns:
;   
; Examples:
;   goes_flare_list('2017-09-10', '2017-09-11')
;   
; Written: James Kavanagh-Cranston, 04-Nov-2023
;
;-

function goes_flare_list, tstart, tend, csv_out=csv_out

    a = ogoes()  ; Initialising goes object.

    print, tstart, tend

    gev = a->get_gev(tstart, tend, /struct)  ; Acquiring flare list for date range.

    ; help, gev  ; Temp line
    ; help, gev[0]  ; Temp line

    ; Removing duplicates
    dup = rem_dup(gev.gpeak)
    gev_no_dup = gev[dup]

    ; Remove A-class flares
    no_a_class_flares = where( strmid( gev_no_dup.class, 0, 1 ) ne 'A' )
    gev_result = gev_no_dup[ no_a_class_flares ]

    flare_count = n_elements(gev_result)  ; Number of flares observed within the time range.

    ; for i = 0, (flare_count - 1) do print, gev_result[i]  ; Printing the returned array of structs.

    print, "No. GOES flares in date range: " + string(flare_count)

    ; Writing output to csv
    if keyword_set(csv_out) then begin

        file_mkdir, 'flare_lists_csv'
        filename = "flare_lists_csv/gev_" + tstart + "_" + tend + ".csv"
        headers = tag_names(gev_result)
        write_csv, filename, gev_result, header=headers

        return, { $
            data:gev_result, $
            filename: filename $
        }

    endif else return, gev_result

end
