pro KOI_142_output
  set_plot,'ps'
  device,filen='RV_KOI_142.eps',/encapsulated,/inches,xsize=10.0,ysize = 8.0,$
         /color,bits_per_pixel=8,/isolatin,/helvetica
  !p.font=0
  !p.thick=6 & !x.thick=5 & !y.thick=5 & !p.charthick=5 & syms=2.0
  !p.charsize=2.0

readcol,"Times",planet,epoch,time,rsky,vsky,format ='l,l,d,d,d'
readcol,"RV_out",t_rv_calc,rv_calc,format='d,d'
readcol,"RV_out2",t_rv_calc_all,rv_calc_all,format='d,d'
readcol,"RV_data_KOI142",t_rv_data,rv_data,uncertainty,format='d,d,d'
; RV data from Barros et al. 2013
offset = -20.4547
; change units from AU/day to km/s:
AU = 149597871.0 ;in km
day = 3600.0*24.0; in seconds
rv_calc = rv_calc*AU/day+offset
rv_calc_all = rv_calc_all*AU/day+offset

plotsym,0,/fill

plot,t_rv_data,rv_data,psym=2,ytitle = 'RV (km/s)',xtitle = 'BJD_UTC-2456000',xrange=[460,620],xstyle=1,yrange=[-20.54,-20.35]
oploterror,t_rv_data,rv_data,uncertainty,psym=2
oplot,t_rv_calc_all,rv_calc_all,psym=-3,color=fsc_color("red")
oplot,t_rv_calc,rv_calc,psym=8,color=fsc_color("red")
device,/close

k = where(epoch lt 114 AND planet eq 0) ;roughly the number observed in Nesvorny et al. 2013 paper), only look at KOI142b
BFL = linfit(epoch[k],time[k])
TTV = time[k]-epoch[k]*BFL[1]-BFL[0]

device,filen='TTVS_KOI_142.eps',/encapsulated,/inches,xsize=10.0,ysize = 8.0,$
         /color,bits_per_pixel=8,/isolatin,/helvetica


plot,epoch[k],TTV*24.0*60.0,psym=-8,xtitle = 'Transit Epoch',ytitle = 'TTV (min)',position = [0.2,0.2,0.9,0.9],charsize = 2
device,/close


     set_plot,'x'
     !p.thick=1 & !x.thick=1 & !y.thick=1 & !p.charthick=1
     !p.charsize=2

stop
end
