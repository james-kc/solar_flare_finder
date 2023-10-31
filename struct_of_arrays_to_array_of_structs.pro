; Define a function to convert a structure of arrays to an array of structures
function struct_of_arrays_to_array_of_structs, input_struct

    num_entries = n_elements(input_struct.(0))
    num_fields = n_tags(input_struct)
    tags = tag_names(input_struct)
    
    data_array = []
    row_struct = {}
    
    for i = 0, (num_entries - 1) do begin  ; per row

        for j = 0, (num_fields - 1) do begin ; per col

            row_struct = create_struct( $
                row_struct, $
                create_struct( $
                    tags[j], $
                    input_struct.(j)[i] $
                ) $
            )

        endfor

        data_array = [data_array, [row_struct]]
        row_struct = {}

    endfor
    
    return, data_array

end
