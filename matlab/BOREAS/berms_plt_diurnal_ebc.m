function berms_plt_diurnal_ebc

Sites = {'pa','bs','jp'};

for i = 1:3
    pth = biomet_path('yyyy',char(Sites(i)),'clean\thirdstage');
    
    tv = read_bor([pth,'clean_tv'],8,[],2000:2003,[],1);
    %ind_tv = find(
    le(:,i) = read_bor([pth,'le_mdv_main'],[],[],2000:2003,[],1);
    h(:,i)  = read_bor([pth,'h_main'],[],[],2000:2003,[],1);
    rn(:,i) = read_bor([pth,'radiation_net_main'],[],[],2000:2003,[],1);
     g(:,i) = read_bor([pth,'energy_storage_main'],[],[],2000:2003,[],1);
     
    ind_tv = find(tv-6/24 > datenum(2000,1,212) & tv-6/24 <= datenum(2000,1,214));
    tv_local = tv(ind_tv)-6/24 - datenum(2000,1,0);
    subplot('Position',subplot_position(3,2,2*i-1))
    plot(tv_local,le(ind_tv,i),'b',...    
     tv_local,h(ind_tv,i),'r',...
     tv_local,rn(ind_tv,i),'y',...
     tv_local,g(ind_tv,i),'k')
    line([212 214],[0 0],'LineStyle',':','Color','k')
    subplot_label(gca,3,2,2*i-1,212:0.5:214,[-200 0 400 800],1)
    
    ind_tv = find(tv-6/24 > datenum(2003,1,212) & tv-6/24 <= datenum(2003,1,214));
    tv_local = tv(ind_tv)-6/24 - datenum(2003,1,0);
    subplot('Position',subplot_position(3,2,2*i))
    plot(tv_local,le(ind_tv,i),'b',...    
     tv_local,h(ind_tv,i),'r',...
     tv_local,rn(ind_tv,i),'y',...
     tv_local,g(ind_tv,i),'k')
       line([212 214],[0 0],'LineStyle',':','Color','k')
    subplot_label(gca,3,2,2*i,212:0.5:214,[-200 0 400 800],1)
 
end

return