;+
; Name: instr_pointing_valid
; 
; Purpose:  Returns 1 or 0 if the pointing and FOV information matches with the
;           flare location.
; 
; Input:
;   flare_x - X position of flare.
;   flare_y - Y position of flare.
;   instr_x - X position instrument is pointing.
;   instr_y - Y position instrument is pointing.
;   instr_fov_x - FOV of the instrument in X direction.
;   instr_fov_y - FOV of the instrument in Y direction.
;          
; Input Keywords:
;
; Returns:  Returns 1 if flare in view of instrument, 0 if not.
;   
; Examples: 
;   
; Written: James Kavanagh-Cranston, 13-Nov-2023
;
;-

function instr_pointing_valid, $
    flare_x, $
    flare_y, $
    instr_x, $
    instr_y, $
    instr_fov_x, $
    instr_fov_y

    instr_x_p = instr_x + (instr_fov_x / 2)
    instr_x_n = instr_x - (instr_fov_x / 2)

    instr_y_p = instr_y + (instr_fov_y / 2)
    instr_y_n = instr_y - (instr_fov_y / 2)

    if ( $
        (instr_x_n le flare_x) and $
        (flare_x le instr_x_p) and $
        (instr_y_n le flare_y) and $
        (flare_y le instr_y_p) $
    ) then return, byte(1) else return, byte(0)

end