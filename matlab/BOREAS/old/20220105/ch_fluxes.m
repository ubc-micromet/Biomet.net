function ch_fluxes(dates)
close all
%C     =  cr_chamber_data([datenum(2003,6,13):datenum(2003,6,20)]);
C     =  cr_chamber_data(dates);


%defines time vector
month = ones(size(C(:,2))); 
hour  = floor(C(:,4) / 100);										
min   = C(:,4) - hour * 100;				
%sec   = zeros(size(C(:,2))); 
sec   = C(:,5); 


TV    = datenum(C(:,2),month,C(:,3),hour,min,sec);
TVL   = TV-8/24;

%defines variables
Air_T = C(:,6);
CO2   = C(:,8);
TS2   = C(:,9);
TS5   = C(:,10);

% calculate fluxes (regression method)
Pbar       = 101000;         % Pa
Vol        = 0.064;          % m3 
Sur        = 0.2165;         % m2 
R          = 8.3144;         % J mol-1 K-1
len_sample = 100;
nbr_sample = length(CO2)/300;
%xx         = [1:len_sample*nbr_sample]'; 
j          = [1:300:length(CO2)];
kk         = [1:length(CO2)];

for i        = 1:nbr_sample;
   ind       = find(kk >= j(i)+80 & kk <= j(i)+80+(len_sample-1));
   %ind       = find(tv >= k(i) & tv <= k(i)+len_sample);
   CO2_tmp   = CO2(ind);
   Air_T_tmp = Air_T(ind);
   tv_reg    = [0:len_sample-1]';
   tv1       = TV(ind);
   tv2       = TVL(ind);
   
   [p_CO2, R2_CO2, sigma_CO2, s_CO2, Y_hat_CO2] = polyfit1(tv_reg,CO2_tmp,1);
   dcdt_tmp  = p_CO2(1);
   dcdt(i)   = dcdt_tmp;
   
   Air_Temp(i) = mean(Air_T_tmp);
   rho         = Pbar / (R * (mean(Air_T_tmp) + 273.15));
   
   % ground CO2 (during first 15 seconds after closing of the chamber)
   ind2        = find(kk >= j(i)+65 & kk <= j(i)+80);
   gr_co2      = CO2(ind2);
   CO2_gr(i)   = mean(gr_co2);

   
   F(i)        = rho * Vol * dcdt_tmp / Sur;
   tt(i)       = mean(tv1);
   ttl(i)      = mean(tv2);  
end

% save output
%pth_out = 'd:\paul\cr\auto\';
%save_bor([pth_out 'co2_ground'],1,CO2_gr);
%save_bor([pth_out 'co2_fluxes'],1,F);
%save_bor([pth_out 'chamber_tv'],8,tt);

figure('unit','inches','PaperOrientation','Portrait','PaperPosition',[.3 2. 8. 6.5],...
   'position',[0.0521    0.3750    8.0833    5.4167]);
set(0,'DefaultTextFontName','Arial'); set(0,'DefaultAxesFontName','Arial');
set(gcf,'defaulttextfontsize',13); set(0,'DefaultAxesFontSize',13);

plot(ttl,F);
set(gca,'XTickLabel','');
datetick('x',6);

figure(2)
plot(TVL,CO2)
datetick('x',6)

