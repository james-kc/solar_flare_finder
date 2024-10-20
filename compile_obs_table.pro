;+
; Name: compile_obs_table
; 
; Purpose:  This function takes the joined_flare_list and determines if
;           particular solar observing instruments were observing the sun
;           at any time during the solar flare.
; 
; Calling sequence: compile_obs_table
;   
; Output:   instr_observed_flare_list.csv
;   
; Written: James Kavanagh-Cranston, 02-Nov-2023
;
;-

pro compile_obs_table

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

    total_flares = max(joined_flare_list.index)

    output = []

    foreach flare, joined_flare_list do begin

        print, ""
        print, `*** BEGINNING FLARE ${flare.index}/${total_flares} ***`
        print, ""

        print, "Calculating RHESSI output..."
        rsi_output = rsi_observed_stats( $
            flare.flare_start, $
            flare.flare_peak, $
            flare.flare_end $
        )

        print, "Calculating FERMI output..."
        fermi_output = fermi_observed_stats( $
            flare.flare_start, $
            flare.flare_peak, $
            flare.flare_end $
        )

        print, "Calculating EVE/MEGS-A & MEGS-B output..."
        eve_output = eve_observed_stats( $
            flare.flare_start, $
            flare.flare_peak, $
            flare.flare_end $
        )

        print, "Calculating EIS output..."
        eis_output = eis_observed_stats( $
            flare.flare_start, $
            flare.flare_peak, $
            flare.flare_end, $
            flare.aia_xcen, $
            flare.aia_ycen $
        )

        print, "Calculating XRT output..."
        xrt_output = xrt_observed_stats( $
            flare.flare_start, $
            flare.flare_peak, $
            flare.flare_end, $
            flare.aia_xcen, $
            flare.aia_ycen $
        )

        print, "Calculating SOT output..."
        sot_output = sot_observed_stats( $
            flare.flare_start, $
            flare.flare_peak, $
            flare.flare_end, $
            flare.aia_xcen, $
            flare.aia_ycen $
        )

        print, "Calculating IRIS output..."
        iris_output = iris_observed_stats( $
            flare.flare_start, $
            flare.flare_peak, $
            flare.flare_end, $
            flare.aia_xcen, $
            flare.aia_ycen $
        )

        print, ""
        print, `*** FLARE ${flare.index}/${total_flares} COMPLETE ***`
        print, ""

        obs_cols = create_struct(flare, rsi_output)
        obs_cols = create_struct(obs_cols, fermi_output)
        obs_cols = create_struct(obs_cols, eve_output)
        obs_cols = create_struct(obs_cols, eis_output)
        obs_cols = create_struct(obs_cols, xrt_output)
        obs_cols = create_struct(obs_cols, sot_output)
        obs_cols = create_struct(obs_cols, iris_output)

        ; help, obs_cols  ; Debugging struct types
        output = [temporary(output), obs_cols]

    endforeach
    
    foreach read_row, output do begin

        print, read_row

    endforeach

    print, tag_names(output)

    write_csv, 'instr_observed_flare_list.csv', output, header=tag_names(output)

end