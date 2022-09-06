function berms_plt_cum_P_E

Sites = {'pa','bs','jp'};

for i = 1:3
    pth = biomet_path('yyyy',char(Sites(i)),'BERMS\al3');

    P_site(:,i)  = read_bor([pth,'ManualCumulative_Precip'],[],[],2000:2003,[],1);

    pth = biomet_path('yyyy',char(Sites(i)),'clean\thirdstage');
    
    tv = read_bor([pth,'clean_tv'],8,[],2000:2003,[],1);
    %ind_tv = find(
    Ta_site(:,i) = read_bor([pth,'air_temperature_main'],[],[],2000:2003,[],1);
    le_site(:,i) = read_bor([pth,'le_mdv_main'],[],[],2000:2003,[],1);
     
    E_site = le_site ./ lambda(Ta_site) * 1800;
    
    P_daily = runmean(P_site,48,48);
    E_daily = runmean(E_site,48,48).*48;
    ind_nan = find(isnan(E_daily));
    E_daily(ind_nan) = 0;
    if length(ind_nan)>10
        disp([num2str(length(ind_nan)) ' days of data missing'])
    end
        
    P(:,:,i) = reshape(P_daily([1:365 367:end],i),365,4);
    E(:,:,i) = reshape(E_daily([1:365 367:end],i),365,4);
 
end

return