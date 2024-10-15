PRO extract_fermi_gbm_ql_data, cspec_path

  gbm_qlook, cspec_path, data, synrate
  timstr = data.utm

  timstrings = strarr(n_elements(timstr))

  print, ">>>>>>>>>> PROCESSING TIMES..." 

  for i=0, (n_elements(timstr)-1) do begin

    utmod = anytim2utc(timstr[i])
    utcfrommod = int2utc(utmod)
    thour = utcfrommod.hour
    tminute = utcfrommod.minute
    tsecond = utcfrommod.second
     if utcfrommod.hour lt 10 then begin
        thour = strcompress(("0" + string(utcfrommod.hour)), /remove_all)
     endif
     if utcfrommod.minute lt 10 then begin
        tminute = strcompress(("0" + string(utcfrommod.minute)), /remove_all)
     endif
     if utcfrommod.second lt 10 then begin
        tsecond = strcompress(("0" + string(utcfrommod.second)), /remove_all)
     endif
     out_utc = string(utcfrommod.year) + "-" + string(utcfrommod.month) + "-" + string(utcfrommod.day) $
               + "T" + string(thour) + ":" + string(tminute) + ":" $
               + string(tsecond) + "." + string(utcfrommod.millisecond)
     timstrings[i] = strcompress(out_utc, /remove_all)

  endfor

  print,  "____________________________________________________________"

  print, "********** PROCESSING COMPLETE"
  print,  "____________________________________________________________"

  print, ">>>>>>>>>> GETTING RATES IN EACH ENERGY RANGE..."

  rates = data.rate

  er6to12 = rates[0,*]
  er12to25 = rates[1,*]
  er25to50 = rates[2,*]
  er50to100 = rates[3,*]
  er100to300 = rates[4,*]

  csvn = cspec_path + "/fermi_FL" + string(utcfrommod.YEAR) + string(utcfrommod.month) + string(utcfrommod.day-1) + "_qld.csv"

  outarr = {time:timstrings, er6to12:er6to12, er12to25:er12to25, er25to50:er25to50, er50to100:er50to100, er100to300:er100to300 }
  csv_output = outarr
  headers = ['time', 'rate6_12', 'rate12_25', 'rate25_50', 'rate50_100', 'rate100_300']
  csv_name = STRCOMPRESS(csvn, /remove_all)
  write_csv, csv_name, csv_output, header=headers

  print, ">>>>>>>>>> SAVING CSV: " + STRCOMPRESS(csvn, /remove_all)

  print,  "____________________________________________________________"

  print, "********** FILE PROCESSING COMPLETE **********"
  
end
