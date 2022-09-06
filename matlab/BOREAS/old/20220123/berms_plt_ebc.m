function berms_plt_ebc

Sites = {'pa'};

for i = 1
    pth = biomet_path('yyyy',char(Sites(i)),'clean\thirdstage');
    
    tv = read_bor([pth,'clean_tv'],8,[],2000,[],1);
    %ind_tv = find(
    le(:,i) = read_bor([pth,'le_mdv_main'],[],[],2000,[],1);
    h(:,i)  = read_bor([pth,'h_main'],[],[],2000,[],1);
    rn(:,i) = read_bor([pth,'radiation_net_main'],[],[],2000,[],1);
     g(:,i) = read_bor([pth,'energy_storage_main'],[],[],2000,[],1);
     
    plot_regression(rn-g,le+h)
    %line([212 214],[0 0],'LineStyle',':','Color','k')
 
end

return