
pro fermi_test

  ; time_range = ['23-Oct-2012 02:54', '23-Oct-2012 03:42']
  ; time_range = ['2010-06-13 05:30:00', '2010-06-13 05:44:00']
  ; time_range = ['2017-09-20 02:51:00', '2017-09-20 03:21:00']

  ; time_range = ['2017-09-10 15:35:00', '2017-09-10 16:31:00']
  ; time_range = ['2010-04-13 04:39:00', '2010-04-13 04:49:00']
  ; time_range = ['2010-04-30 19:28:00', '2010-04-30 19:38:00']
  ; time_range = ['2010-05-04 16:15:00', '2010-05-04 16:34:00']
  ; time_range = ['2016-09-08 07:32:00', '2016-09-08 07:39:00']
  ; time_range = ['2010-06-12 00:30:00', '2010-06-12 01:02:00']
  ; time_range = ['2010-06-11 23:56:00', '2010-06-12 00:04:00']
  ; time_range = ['2010-06-12 00:30:00', '2010-06-12 00:33:00']
  ; time_range = ['2010-06-13 05:30:00', '2010-06-13 05:44:00']
  ; time_range = ['2011-04-11 23:40:00', '2011-04-12 00:03:00']
  time_range = ['2017-09-06 11:53:00', '2017-09-06 12:10:00']


  ;gbm_find_data,date=time_range, pattern='cspec', det='b0', /copy, file=file, dir='~/spex'.
  gbm_find_data,date=time_range, pattern='cspec', det='n4', /copy, file=file, dir='~/spex'

  obj = ospex(spex_specfile=file, /no_gui)
  obj->set, spex_accum_time = time_range

  ; gbmstruct = obj->getdata(spex_units='flux')
  gbmstruct = obj->getdata(spex_units='rate')

  ;eband = [[200.,1000],[1000.,2000.]]
  eband = [ [ 6., 12. ], [ 12., 25 ], [ 25., 50 ],[ 50.,100. ], [ 100., 300 ], [ 300., 800 ] ]
                                ;eband = [ [ 10., 14. ], [ 14., 25. ],
                                ;[ 25., 50. ], [ 50., 100. ], [ 100.,
                                ;300. ] ;; from the RHESSI browser
                                ;plots - change legend

  gbm = obj->bin_data(data=gbmstruct,intervals=eband,units_str=obj->getunits(class='spex_data'))
  tgbm = obj->getaxis(/ut,/mean)
  linecolors

  utplot, anytim(tgbm,/ext), gbm[0,*], yra=[ .1,1e6],/ylog

  for i = 1, 5 do outplot, anytim(tgbm,/ext), gbm[i,*], col=i+1

  legend, [ 'det: n4', '6-12 keV','12-25 keV','25-50 keV','50-100 keV','100-300 keV','300-800 keV' ], color = [ 0, 255, 2, 3, 4, 5, 6 ], /top, /left, line = 0

end

