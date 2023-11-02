pro ewq

    save_filename = 'joined_flare_list.sav'

    ; Attempting to restore from .sav file
    if file_test(save_filename) then begin

        print, "Restoring from .sav file."
        restore, save_filename
        print, "Restore complete."

    endif else begin

        ; Reading in joined flare list
        joined_csv_filename = 'flare_lists_csv/joined_her_2010-4-10_2019-5-31+gev_2010-04-11_2019-06-01.csv'
        joined_flare_list = read_csv_w_headers(joined_csv_filename)

        ; Changing output from struct with array values to array of structs
        joined_flare_list = struct_of_arrays_to_array_of_structs(joined_flare_list)
        
        save, filename=save_filename, joined_flare_list

    endelse

    ; joined_flare_list = joined_flare_list[1748:1770]  ; Temp shortening of flare list

    ; help, joined_flare_list[0]

    output = []

    foreach flare, joined_flare_list do begin

        print, ""
        print, `*** BEGINNING FLARE ${flare.index} ***`
        print, ""

        rsi_output = rsi_observed_stats( $
            flare.flare_start, $
            flare.flare_peak, $
            flare.flare_end $
        )

        print, ""
        print, `*** FLARE ${flare.index} COMPLETE ***`
        print, ""

        ; help, create_struct(flare, rsi_output)  ; Debugging struct types
        output = [output, create_struct(flare, rsi_output)]

    endforeach
    
    foreach read_row, output do begin

        print, read_row

    endforeach

    write_csv, 'instr_observed_flare_list.csv', output, header=tag_names(output)

end