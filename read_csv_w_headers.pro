function read_csv_w_headers, filename
    ;+ This function takes a csv filename and returns a struct containing the
    ;  information contained within the csv file. This function uses the built-
    ;  in read_csv function to acquire "original_struct" which has tag names
    ;  field01, field02, etc as well as a header array containing column name
    ;  strings. These are then used to create an "output_struct" with the column
    ;  names as struct tags.
    ;-

    ; read_csv returns a struct with tag names: field01, field02, ...
    ; when header=header is passed, read_csv will also create a variable,
    ; header, containing an array of the column names.
    original_struct = read_csv(filename, header=header)

    output_struct = {}

    ; for loop creating a new struct with the correct col names. 
    for i = 0, (n_tags(original_struct) - 1) do begin

        ; handling pandas output with index col has "" as col name.
        if header[i] eq "" then begin

            output_struct = create_struct( $
                output_struct, $
                create_struct("index", original_struct.(i)) $
            )

        endif else begin  ; handling all other col names.

            output_struct = create_struct( $
                output_struct, $
                create_struct(header[i], original_struct.(i)) $
            )

        endelse

    endfor

    return, output_struct

end
