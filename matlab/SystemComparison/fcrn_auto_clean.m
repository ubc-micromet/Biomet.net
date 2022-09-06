function tv_exclude = fcrn_auto_clean(Stats_all,system_names,tv_exclude);

[N1,tv] = get_stats_field(Stats_all,[char(system_names(1)) '.MiscVariables.NumOfSamples']);
[N2,tv] = get_stats_field(Stats_all,[char(system_names(2)) '.MiscVariables.NumOfSamples']);
N1_max = fcrn_nanmedian(N1);
N2_max = fcrn_nanmedian(N2);
ind_n1 = find(N1./N1_max<0.97);
ind_n2 = find(N2./N2_max<0.97);

% Find calibration times:
[co2_min1,tv] = get_stats_field(Stats_all,[char(system_names(1)) '.Three_Rotations.Min(5)']);
[h2o_min1,tv] = get_stats_field(Stats_all,[char(system_names(1)) '.Three_Rotations.Min(6)']);
[co2_min2,tv] = get_stats_field(Stats_all,[char(system_names(2)) '.Three_Rotations.Min(5)']);
[h2o_min2,tv] = get_stats_field(Stats_all,[char(system_names(2)) '.Three_Rotations.Min(6)']);

ind_cal1 = find(co2_min1 < 340 | h2o_min1 < 1); 
ind_cal2 = find(co2_min2 < 340 | h2o_min2 < 1);

% Find crazy fluxes
[Fc1,tv] = get_stats_field(Stats_all,[char(system_names(1)) '.Three_Rotations.AvgDtr.Fluxes.Fc']);
[Fc2,tv] = get_stats_field(Stats_all,[char(system_names(2)) '.Three_Rotations.AvgDtr.Fluxes.Fc']);
[LE1,tv] = get_stats_field(Stats_all,[char(system_names(1)) '.Three_Rotations.AvgDtr.Fluxes.LE_L']);
[LE2,tv] = get_stats_field(Stats_all,[char(system_names(2)) '.Three_Rotations.AvgDtr.Fluxes.LE_L']);
[Us1,tv] = get_stats_field(Stats_all,[char(system_names(1)) '.Three_Rotations.AvgDtr.Fluxes.Ustar']);
[Us2,tv] = get_stats_field(Stats_all,[char(system_names(2)) '.Three_Rotations.AvgDtr.Fluxes.Ustar']);

ind_fc1 = find(Fc1 < -50 | Fc1 > 30 );
ind_fc2 = find(Fc2 < -50 | Fc2 > 30 );
ind_le1 = find(LE1 < -200 | LE1 > 1000 );
ind_le2 = find(LE2 < -200 | LE2 > 1000 );
ind_us1 = find(Us1 > 15);
ind_us2 = find(Us2 > 15);

ind_nan = find(isnan(Fc1.*Fc2));

[tv_dum,ind_man] = intersect(fr_round_hhour(tv),fr_round_hhour(tv_exclude));

%----------------------------------------------------
% Create exclusion time vector
%----------------------------------------------------

ind_ex = unique([ind_n1; ind_n2; ind_cal1; ind_cal2; ind_nan; ind_man; ...
        ind_fc1; ind_fc2; ind_le1; ind_le2; ind_us1; ind_us2]);
tv_exclude = unique([tv(ind_ex); tv_exclude]);

% Display report
disp(['No of total pts:' num2str(length(Stats_all))]);
disp('No of pts excluded:')
disp(sprintf('N\t\t %i',length(unique([ind_n1; ind_n2]))));
disp(sprintf('Cal\t\t %i',length(unique([ind_cal1; ind_cal2]))));
disp(sprintf('Fluxes\t %i',length(unique([ind_fc1; ind_fc2; ind_le1; ind_le2; ind_us1; ind_us2]))));
disp(sprintf('Nan\t\t %i',length(ind_nan)));
disp(sprintf('Manual\t %i',length(ind_man)));
disp(sprintf('Total\t %i',length(ind_ex)));
disp(sprintf('\nGood\t %i',length(setdiff(1:length(Stats_all),ind_ex))));

%----------------------------------------------------
% If no output is requested plot graphs to show which data
% got delete
%----------------------------------------------------
if nargout == 0
    
    yy = datevec(tv(1));
    doy = tv - datenum(yy(1),1,0);
    
    figure('Name','No of points');
    plot(doy,[N1 N2],...
        [doy(1) doy(end)],0.97*[N1_max N1_max],'b',...
        [doy(1) doy(end)],0.97*[N2_max N2_max],'g',...
        [doy(ind_ex); doy(ind_ex)],[N1(ind_ex); N2(ind_ex)],'k.',...
        doy(ind_n1),N1(ind_n1),'r.',...
        doy(ind_n2),N2(ind_n2),'c.');
    legend({'N1','N2','Min N1','Min N2','Other Excluded','N1 excluded','N2 excluded'},4);
    ylabel('No of samples');
    xlabel('DOY')
    
    figure('Name','Calibrations');
    plot(doy,[co2_min1 co2_min2],...
        [doy(1) doy(end)],[340 340],'k',...
        [doy(ind_ex); doy(ind_ex)],[co2_min1(ind_ex); co2_min2(ind_ex)],'k.',...
        doy(ind_cal1),co2_min1(ind_cal1),'r.',...
        doy(ind_cal2),co2_min2(ind_cal2),'c.');
    legend({'CO2_min1','CO2_min2','Min CO2','Other Excluded','Cal1 excluded','Cal2 excluded'},4);
    ylabel('CO2 Minimum  (ppm)');
    xlabel('DOY')
    
    figure('Name','Fluxes');
    subplot('Position',subplot_position(3,1,1));
    plot(doy,[Fc1 Fc2],...
        [doy(1) doy(end)],[-50 -50],'k',...
        [doy(1) doy(end)],[30 30],'k',...
        [doy(ind_ex); doy(ind_ex)],[Fc1(ind_ex); Fc2(ind_ex)],'k.',...
        doy(ind_fc1),Fc1(ind_fc1),'r.',...
        doy(ind_fc2),Fc2(ind_fc2),'c.');
    set(gca,'XTickLabel','');    
    ylabel('Fc (\mumol m^{-2} s^{-1})');
    
    subplot('Position',subplot_position(3,1,2));
    plot(doy,[LE1 LE2],...
        [doy(1) doy(end)],[-200 -200],'k',...
        [doy(1) doy(end)],[1000 1000],'k',...
        [doy(ind_ex); doy(ind_ex)],[LE1(ind_ex); LE2(ind_ex)],'k.',...
        doy(ind_le1),LE1(ind_le1),'r.',...
        doy(ind_le2),LE2(ind_le2),'c.');
    set(gca,'XTickLabel','');    
    ylabel('LE (W/m^2)');
    
    subplot('Position',subplot_position(3,1,3));
    plot(doy,[Us1 Us2],...
        [doy(1) doy(end)],[15 15],'k',...
        [doy(ind_ex); doy(ind_ex)],[Us1(ind_ex); Us2(ind_ex)],'k.',...
        doy(ind_us1),Us1(ind_us1),'r.',...
        doy(ind_us2),Us2(ind_us2),'c.');
    ylabel('Ustar (m/s)');
    xlabel('DOY')
   
    figure('Name','Fluxes - manual cleaning');
    subplot('Position',subplot_position(3,1,1));
    plot(doy,[Fc1 Fc2],...
        [doy(1) doy(end)],[-50 -50],'k',...
        [doy(1) doy(end)],[30 30],'k',...
        [doy(ind_ex); doy(ind_ex)],[Fc1(ind_ex); Fc2(ind_ex)],'k.',...
        doy(ind_man),Fc1(ind_man),'r.',...
        doy(ind_man),Fc2(ind_man),'c.');
    set(gca,'XTickLabel','');    
    ylabel('Fc (\mumol m^{-2} s^{-1})');
    
    subplot('Position',subplot_position(3,1,2));
    plot(doy,[LE1 LE2],...
        [doy(1) doy(end)],[-200 -200],'k',...
        [doy(1) doy(end)],[1000 1000],'k',...
        [doy(ind_ex); doy(ind_ex)],[LE1(ind_ex); LE2(ind_ex)],'k.',...
        doy(ind_man),LE1(ind_man),'r.',...
        doy(ind_man),LE2(ind_man),'c.');
    set(gca,'XTickLabel','');    
    ylabel('LE (W/m^2)');
    
    subplot('Position',subplot_position(3,1,3));
    plot(doy,[Us1 Us2],...
        [doy(1) doy(end)],[15 15],'k',...
        [doy(ind_ex); doy(ind_ex)],[Us1(ind_ex); Us2(ind_ex)],'k.',...
        doy(ind_man),Us1(ind_man),'r.',...
        doy(ind_man),Us2(ind_man),'c.');
    ylabel('Ustar (m/s)');
    xlabel('DOY')
   
end