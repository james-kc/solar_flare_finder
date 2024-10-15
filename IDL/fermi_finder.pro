
pro fermi_finder

;   gev_start = '2014-02-03T15:40:00'
;   gev_peak = '2014-02-03T15:43:00'
;   gev_end = '2014-02-03T15:48:00'

  flare_spe = ['2013-11-09 06:22:00', '2013-11-09 06:38:00', '2013-11-09 06:47:00']

  gev_start = flare_spe[0]
  gev_peak = flare_spe[1]
  gev_end = flare_spe[2]

  gtr_ext = [ anytim( gev_start ) - 1800., anytim( gev_end ) + 3600. ] ;; Extend GOES start/end times by 30/60 minutes
  gtr_ext = anytim( gtr_ext, /vms )
  
  gbm_cat = gbm_read_cat()
  gbm_flare = where( gbm_cat.utpeak[ 1 ] ge anytim( gev_start ) and gbm_cat.utpeak[ 1 ] le anytim( gev_end ) )
  sunward_det = 'n'+num2str( where( gbm_cat[ gbm_flare ].cosines[ *, 1 ] eq max( gbm_cat[ gbm_flare ].cosines[ *, 1 ] ) ) )
  ;time_range = ['23-Oct-2012 02:54', '23-Oct-2012 03:42']
  ;gbm_find_data,date=time_range, pattern='cspec', det='b0', /copy, file=file
  gbm_find_data, date = gtr_ext, pattern = 'cspec', det = sunward_det, /copy, file = file
  obj = ospex( spex_specfile=file, /no_gui )
  obj->set, spex_accum_time = time_range
  ;gbmstruct = obj->getdata(spex_units='flux')
  gbmstruct = obj->getdata( spex_units='rate' )
  ;eband = [[200.,1000],[1000.,2000.]]
  eband = [ [ 6., 12. ], [ 12., 25 ], [ 25., 50 ],[ 50.,100. ], [ 100., 300 ], [ 300., 800 ] ]
                                ;eband = [ [ 10., 14. ], [ 14., 25. ],
                                ;[ 25., 50. ], [ 50., 100. ], [ 100.,
                                ;300. ] ;; from the RHESSI browser
                                ;plots - change legend
  gbm = obj->bin_data( data = gbmstruct, intervals = eband, units_str = obj->getunits( class='spex_data' ) )
  tgbm = obj->getaxis( /ut, /mean )

  hsi_obj = hsi_obs_summary()
  hsi_obj -> set, obs_time_interval = gtr_ext
  hsi_data = hsi_obj -> getdata( /corrected ) ; to retrieve the count rate data
  hsi_time = hsi_obj -> getdata( /time )
  ephem = hsi_obj -> getdata(class='hsi_ephemeris')  ; to retrieve ephemeris data


  goes = ogoes()
  goes -> set, tstart = gtr_ext[ 0 ], tend = gtr_ext[ 1 ]
  gdata = goes -> getdata( /struct )
  window, 2, xsize = 1000., ysize = 500., retain = 2
  !p.charsize = 2.
  !p.multi = [ 0, 1, 3 ]
  ;; Plot GOES
  utplot, gdata.tarray, gdata.yclean[ *, 0 ], gdata.utbase, /ylog, ys = 9, timerange = gtr_ext, position = [ 0.1, 0.6, 0.9, 0.85 ], $
          yr = [ 1e-9, 1e-2 ], xtickformat = "(A1)", xtitle = ' ', /xs, ytitle = gdata.sat + ' !C !C X-ray Flux (W m!U-2!N)'
  outplot, gdata.tarray, gdata.yclean[ *, 1 ], line = 1
  goes -> set, euv = 3
  euv_data = goes-> getdata( /struct )
  q = where( euv_data.yclean ne -99999. )
  axis, /yaxis, /save, yr = [ 0.006, 0.01 ], color = 125, ylog = 0, ytitle = gdata.sat + ' Lya (W m!U-2!N)'
  outplot, euv_data.tarray[ q ], euv_data.yclean[ q, 0 ], color = 125, line = 2
  ;cgaxis, 0.85, /yaxis, /save, yr = [ 1e-3,1e8 ], color = 255, /norm, charsize = 1., ylog = 1
  linecolors
  ;; Plot RHESSI
  hsi_linecolors
  max_ind = 3
  hsi_labels = [ 'Det 1,3,4,5,6,9', '6-12 keV', '12-25 keV', '25-50 keV', '50-100 keV', '100-300 keV', '300-800 keV', '800-7000 keV', '7000-20000 keV' ]
  hsi_colors = [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ]
  hsi_obj -> plot, /xs, /corrected, dim1_colors = hsi_colors[ 0:max_ind ], dim1_line = 0, psym = 10, /flare, /saa, /night, $
                   /no_timestamp, legend = 0, position = [ 0.1, 0.35, 0.9, 0.60 ], flag_colors = [ 7, 6, 2 ], ytickformat = 'tick_label_exp', $
                   yrange = [ 1e-1, 1e6 ], ystyle = 1, dim1_use = indgen( max_ind )+1, title = ' ', xtickformat = "(A1)", xtitle = ' ', $
                   ytitle = 'RHESSI Corrected Count !C !C Rate (s!U-1!N detector!U-1!N)'
   legend, hsi_labels[ 0:max_ind ], /top, /left, box = 0, charsize = 1., textcolor = [ 255, indgen( max_ind )+2 ]
  ;for j = 0, 5 do outplot, hsi_time - hsi_time[ 0 ], hsi_data.countrate[ j ], color = j+1
  ;; Plot Fermi
  ;cgaxis, 0.95, /yaxis, /save, yr = [ 1e2,1e12 ], color = 255, /norm, charsize = 1, ylog = 1
   utplot, anytim( tgbm, /vms ), gbm[ 0, * ], color = 255, position = [ 0.1, 0.1, 0.9, 0.35 ], timerange = gtr_ext, yr = [ 1e1, 1e5 ], $
           /ylog, /xs, ytitle = 'Fermi/GBM (Counts s!U-1!N)'
  for i = 1, 5 do outplot, anytim( tgbm, /vms ), gbm[ i, * ], col=i+1
  legend, [ 'Det '+sunward_det, '6-12 keV','12-25 keV','25-50 keV','50-100 keV','100-300 keV','300-800 keV' ], $
          textcolor = [ 255, 255, 2, 3, 4, 5, 6 ], /top, /left, box = 0, charsize= 1.
  !p.multi = 0
  !p.charsize = 1.
  stop
end






