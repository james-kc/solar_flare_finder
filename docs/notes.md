# Fermi

Link to a csv-like file with Fermi GBM observed solar flares.
This would be interesting to compare with my own method of determining observation. Flare list notes:

```
Solar flare identification strategy:                                                                               
  Using the daily CSPEC file,  we construct a measure of the net solar signal (called synthetic                    
  rate below) by                                                                                                   
  1) subtracting the summed rates in the anti-sunward detectors from those in the sunward                          
     detectors for two energy bands,                                                                               
  2) smoothing these two rates with a square wave to produce a value sensitive                                     
     to solar flares and multiplying them together, and                                                            
  3) multiplying that value by the short wavelength (0.5 - 4 Å) flux seen with                                     
     the GOES soft X-ray sensor.                                                                                   
  Time intervals with this measure of the solar flux greater than the value typical for a C2 flare are             
  identified as solar flares.                                                                                      
                                                                                                                   
Description of Columns:                                                                                            
  Flare -             Flare number constructed from start time of flare: yymmdd_hhmm where yy=year, mm=month,      
                      dd=day of month, hh=hour, and mm=minute, all two digits.                                     
  Start time -        Time when the synthetic rate exceeds the level corresponding to a C2 flare                   
  Peak time -         Time of maximum rate in the 12-25 keV band                                                   
  End time -          Time when the synthetic rate became less than the level corresponding to a C2 flare          
  Dur -               Duration of flare in seconds                                                                 
  Peak rate -         Maximum rate in the 12-25 keV band in counts/sec                                             
  Total counts -      Total counts in the 12-25 keV band                                                           
  Sunward Detectors - Four most sunward NaI detectors at the peak time (in 12-25 keV band) of the flare            
  Trigger -           Fermi Trigger Designation if flare caused a trigger.  If there is more than one trigger      
                      during flare, this is the one nearest to the peak time.                                      
  RHESSI Flare # -    The RHESSI flare designation if this flare was observed by RHESSI
```

https://hesperia.gsfc.nasa.gov/fermi/gbm/qlook/fermi_gbm_flare_list.txt

# Other Data Sources

HAPI server:

https://hapi-server.org/servers/