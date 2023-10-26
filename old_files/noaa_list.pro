;+
; PROCEDURE: noaa_list
;
; PURPOSE: Retrieve NOAA flare lists from the https://www.ncei.noaa.gov/data/goes-space-environment-monitor/access/science/xrs/goes15/xrsf-l2-flsum_science/ 
; directory.
;
; USEAGE: Attempts to wget files within the /year/month/ directory according to standard nomenclature. Wget is aborted once 
; a limit on successive failed wget commands is reached.
;
; INPUT KEYWORDS:
;   year - Year in the form 2014
;   month - Month in the form 05
;
; KEYWORDS:
;
; RESTRICTIONS: 
;
; AUTHOR:     James Kavanagh-Cranston (QUB) Nov 2023
;-


pro noaa_list, year, month

  ; Creating folder for downloaded .nc files.
  file_mkdir, 'downloaded_files'

  year_str = strtrim(year, 2)
  if (month lt 10) then month_str = "0" + strtrim(month, 2) else month_str = strtrim(month, 2)

  web_link_base = 'https://www.ncei.noaa.gov/data/goes-space-environment-monitor/access/science/xrs/goes15/xrsf-l2-flsum_science/' + year_str + "/" + month_str + "/"
  file_name = "sci_xrsf-l2-flsum_g15_d" + year_str + month_str

  ; Add flags to control the wget command.
  do_wget = 1 ; Control the execution of the wget command.
  failed_wgets = 0  ; Initialising number of consecutive failed wget commands.
  wget_failure_limit = 5  ; Setting the limit of consecutive failures of the wget command.
  flare_no = 0  ; Initialising the flare number for file nomenclature.

  ; Setting up error handling.
  catch, Error_status

  if Error_status NE 0 THEN BEGIN
    PRINT, 'Error index: ', Error_status
    PRINT, 'Error message: ', !ERROR_STATE.MSG

    ; Handle the error by halting wget loop.
    failed_wgets ++

    file_delete, save_file  ; Deleting empty wget file.

    if (failed_wgets ge wget_failure_limit) then do_wget = 0

  endif

  ; Main wget while loop.
  while do_wget do begin

    ; Incrementing the number of flares found within the dir.
    flare_no ++
    flare_no_str = string(flare_no)

    ; Handling flare_no < 10 where a '0' must be prefixed as
    ; standard nomenclature is 01, 02, 03, ...
    if (flare_no lt 10) then begin

      append = "0" + strtrim(flare_no_str, 2) + "_v1-0-0.nc"
      current_link = web_link_base + file_name  + append

    endif else begin  ; For cases where flare_no >= 10.

      append = strtrim(flare_no_str, 2) + "_v1-0-0.nc"
      current_link = web_link_base + file_name + append

    endelse

    ; Creating string to use as save filename .
    save_file = "downloaded_files/" + file_name + append
    
    ; Wget command saving output to save_file.
    _ = wget(current_link, filename=save_file)

    ; Commands after this point run only if the wget command was successful.

    ; Printing source link and save file
    print, current_link + " -> " + save_file
    
    ; Reset failed_wgets variable allowing for a consecutive limit of "wget_failure_limit".
    failed_wgets = 0
    
  endwhile

  print, "Finished downloading files."

end
