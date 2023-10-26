; Full outer join of the HEK and GOES flare lists

function goes_her_flare_list, gev, her

    ;+
    ; gev cols:
    ; GSTART	GEND	GPEAK	CLASS	LOC	NOAA_AR
    ;
    ; her cols:
    ; GEV_START	GEV_PEAK	GEV_END	GOES_CLASS	AIA_LOC	AIA_XCEN	AIA_YCEN
    ;-

    ; Initialize an array to store the result of the join
    result_data = []

    ; Perform the join. Matching her flares to goes flares
    for i = 0, (n_elements(gev) - 1) do begin

        gev_flare = gev[i]
        matching_her = where( $
            (her.gev_peak eq gev_flare.gpeak) and $
            (her.goes_class eq gev_flare.class) $
        )

        if n_elements(matching_her) GT 0 then begin

            joined_data = { $
                    flare_start: gev_flare.gstart, $
                    flare_peak: gev_flare.gpeak, $
                    flare_end: gev_flare.gend, $
                    class: gev_flare.class, $
                    aia_loc: her[matching_her[0]].aia_loc, $
                    aia_xcen: her[matching_her[0]].aia_xcen, $
                    aia_ycen: her[matching_her[0]].aia_ycen, $
                    gev_loc: gev_flare.loc, $
                    noaa_ar: gev_flare.noaa_ar $
                }

            result_data = [result_data, joined_data]

        endif else begin  ; This is if there is not a corresponding her flare

            joined_data = { $
                    flare_start: gev_flare.gstart, $
                    flare_peak: gev_flare.gpeak, $
                    flare_end: gev_flare.gend, $
                    class: gev_flare.class, $
                    aia_loc: "", $
                    aia_xcen: "", $
                    aia_ycen: "", $
                    gev_loc: gev_flare.loc, $
                    noaa_ar: gev_flare.noaa_ar $
                }

            result_data = [result_data, joined_data]

        endelse

    endfor

    ; Matching goes flares to her flares
    for i = 0, (n_elements(her) - 1) do begin

        her_flare = her[i]
        matching_gev = where( $
            (gev.gpeak eq her_flare.gev_peak) and $
            (gev.class eq her_flare.goes_class) $
        )

        if n_elements(matching_gev) GT 0 then begin

            joined_data = { $
                    flare_start: gev[matching_gev[0]].gstart, $
                    flare_peak: gev[matching_gev[0]].gpeak, $
                    flare_end: gev[matching_gev[0]].gend, $
                    class: gev[matching_gev[0]].class, $
                    aia_loc: her_flare.aia_loc, $
                    aia_xcen: her_flare.aia_xcen, $
                    aia_ycen: her_flare.aia_ycen, $
                    gev_loc: gev[matching_gev[0]].loc, $
                    noaa_ar: gev[matching_gev[0]].noaa_ar $
                }

            result_data = [result_data, joined_data]

        endif else begin  ; This is if there is not a corresponding gev flare

            joined_data = { $
                    flare_start: her_flare.gev_start, $
                    flare_peak: her_flare.gev_peak, $
                    flare_end: her_flare.gev_end, $
                    class: her_flare.goes_class, $
                    aia_loc: her_flare.aia_loc, $
                    aia_xcen: her_flare.aia_xcen, $
                    aia_ycen: her_flare.aia_ycen, $
                    gev_loc: "", $
                    noaa_ar: "" $
                }

            result_data = [result_data, joined_data]

        endelse

    endfor

    ; Removing duplicates
    dup = rem_dup(result_data.flare_peak)
    result_data_no_dup = result_data[dup]

    ; Remove A-class flares
    no_a_class_flares = where( strmid( result_data_no_dup.class, 0, 1 ) ne 'A' )
    result = result_data_no_dup[ no_a_class_flares ]

    ; Print the result
    print, result

end
