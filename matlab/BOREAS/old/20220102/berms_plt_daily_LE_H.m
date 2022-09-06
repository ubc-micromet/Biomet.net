function berms_plt_daily_LE_H

Sites = {'pa','bs','jp'};


for i = 1:3
    pth = biomet_path('yyyy',char(Sites(i)),'clean\thirdstage');
    
    tv = read_bor([pth,'clean_tv'],8,[],2000:2003,[],1);
    rad_site  = read_bor([pth,'ppfd_downwelling_main'],[],[],2000:2003,[],1);
    
    le_site = read_bor([pth,'le_mdv_main'],[],[],2000:2003,[],1);
    ind_nan = find(isnan(le_site) | rad_site<=0);
    le_site(ind_nan) = 0;

    h_site  = read_bor([pth,'h_mdv_main'],[],[],2000:2003,[],1);
    ind_nan = find(isnan(h_site) | rad_site<=0);
    h_site(ind_nan) = 0;
    
    le_daily  = runmean(le_site,48,48);
    h_daily   = runmean(h_site,48,48);

    le(:,:,i)  = reshape(le_daily([1:365 367:end]),365,4);
    h(:,:,i) = reshape(h_daily([1:365 367:end]),365,4);

    tv_local = 0.5:1:365;
    
    subplot('Position',subplot_position(3,2,2*i-1))
    plot(tv_local,le(:,1,i),'b',...    
     tv_local,h(:,1,i),'r')
    %line([212 214],[0 0],'LineStyle',':','Color','k')
    subplot_label(gca,3,2,2*i-1,0:30:365,[-50:50:200],1)
    
    subplot('Position',subplot_position(3,2,2*i))
    plot(tv_local,le(:,4,i),'b',...    
     tv_local,h(:,4,i),'r')
    %line([212 214],[0 0],'LineStyle',':','Color','k')
    subplot_label(gca,3,2,2*i,0:30:365,[-50:50:200],1)

end

return