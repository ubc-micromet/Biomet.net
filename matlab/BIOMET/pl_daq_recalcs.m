function pl_daq_recalcs(siteID,year,DOYs,pth_oldcal,pth_newcal,flux_plots)

% plot select traces from a set of recalculated mat files

% file created: Nick, sometime in 2006

% Revisions:
% Jan 20, 2009
%   -added some pauses to the plot display

arg_default('flux_plots',1);

switch upper(siteID)
    case 'BS'
       fileExt = '.hb.mat';
       GMTshift = 6/24;
   case 'PA'
       fileExt = '.hp.mat';
       GMTshift = 6/24;
   case 'CR'
       fileExt = '.hc.mat';
       GMTshift = 8/24;
end

% DOY range

st = min(DOYs);                                      % first day of measurements
ed = max(DOYs);                                    % last day of measurements (approx.)

% read in and extract time vector

yearOffset = datenum(year,1,1,0,0,0)-1;
[DecDOY,TimeVector] = fr_join_trace('stats.TimeVector',st+yearOffset,ed+yearOffset,fileExt,pth_newcal);

t = DecDOY - GMTshift + 1;                          % convert decimal time to
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later                                                    
ind = find( t >= st & t <= ed +1 );                  % extract the requested period
t = t(ind);
TimeVector = TimeVector(ind);

if exist('fig')
    fig = fig+1;
else
   fig = 1;
end

% extract and plot eddy CO2 trace

figure(fig);
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(1,[11],:))';
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(1,[6],:))';
end
   % to plot avg, min and max, first index should be 1:3
[DecDOY,co2_oldcal] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth_oldcal);
[DecDOY,co2_newcal] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth_newcal);

plot(t,co2_oldcal(ind,:),'r' ,t,co2_newcal(ind,:),'b');
grid on; zoom on; xlabel('DOY'); ylabel('\mumol mol^{-1} of dry air');
axis([t(1) t(end) 320 450]);
title([ siteID ' Eddy CO_{2} recalcs: ' num2str(year)]);
legend('oldcal,oldbiomet,oldinitall','newcal,newbiomet,newinitall');

pause;

fig=fig+1;figure(fig);
plot_regression(co2_oldcal(ind,:), co2_newcal(ind,:), [], [], 'ortho');
title('Eddy CO2 comparision');
zoom on;
xlabel('CO2 (old calc) (\mumol mol^-1)');
ylabel('CO2 (new calc) (\mumol mol^-1)');

pause;

% extract and plot profile CO2 trace

fig = fig+1; figure(fig);
traceName = 'stats.Profile.co2.Avg';
[DecDOY,co2_prof_old] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth_oldcal);
[DecDOY,co2_prof_new] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth_newcal);
plot(t,co2_prof_old(ind,end),'r',t,co2_prof_new(ind,end),'b');
grid on; zoom on; xlabel('DOY'); ylabel('ppm')
axis([t(1) t(end) 320 500]);
title('CO_2 profile')
legend('oldcal','newcal');

pause;

fig=fig+1;figure(fig);
plot_regression(co2_prof_old(ind,end), co2_prof_new(ind,end), [], [], 'ortho');
title('Profile CO2 comparision');
zoom on;
xlabel('CO2 (old calc) (\mumol mol^-1)');
ylabel('CO2 (new calc) (\mumol mol^-1)');

pause;

if flux_plots
    %-----------------------------------------------
    % CO2 flux
    
    fig = fig+1;figure(fig);clf
    traceName = 'stats.Fluxes.AvgDtr(:,[5])';
    [DecDOY,Fc_old] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth_oldcal);
    [DecDOY,Fc_new] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth_newcal);
    plot(t,Fc_old(ind,:),'r',t,Fc_new(ind,:),'b');grid on;zoom on;xlabel('DOY'); 
    axis([t(1) t(end) -30 10])
    title('F_c')
    ylabel('\mumol m^{-2} s^{-1}')
    
    pause;
    
    fig=fig+1;figure(fig);
    plot_regression(Fc_old(ind,:), Fc_new(ind,:), [], [], 'ortho');
    title('F_{C} comparision');
    zoom on;
    xlabel('F_{C} (old calc) (\mumol m^-2 s^-1)');
    ylabel('F_{C} (new calc) (\mumol m^-2 s^-1)');
    
    pause;
    
    %-----------------------------------------------
    % Sensible heat
    %
    fig = fig+1;figure(fig);clf
    %traceName = 'stats.Fluxes.AvgDtr(:,[2 3 4])';
    traceName = 'stats.Fluxes.AvgDtr(:,[2 3])';
    [DecDOY,Hs_old] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth_oldcal);
    [DecDOY,Hs_new] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth_newcal);
    plot(t,Hs_old(ind,:),t,Hs_new(ind,:));grid on;zoom on;xlabel('DOY')
    axis([t(1) t(end) -200 600])
    title('Sensible heat')
    ylabel('(Wm^{-2})')
    %legend('Gill_{old}','Tc1_{old}','Tc2_{old}','Gill_{new}','Tc1_{new}','Tc2_{new}',-1)
    legend('Gill_{old}','Tc1_{old}','Gill_{new}','Tc1_{new}',-1)
    
    pause;
    
    fig=fig+1;figure(fig);
    plot_regression(Hs_old(ind,:), Hs_new(ind,:), [], [], 'ortho');
    title('H_{s} comparision');
    zoom on;
    xlabel('H_{s} (old calc) (W m^-2 )');
    ylabel('H_{s} (new calc) (W m^-2 )');
    
    pause;
    
    %-----------------------------------------------
    % Latent heat
    %
    fig = fig+1;figure(fig);clf
    traceName = 'stats.Fluxes.AvgDtr(:,[1])';
    [DecDOY,LE_old] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth_oldcal);
    [DecDOY,LE_new] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth_newcal);
    plot(t,LE_old(ind,:),t,LE_new(ind,:));grid on;zoom on;xlabel('DOY')
    axis([t(1) t(end) -200 600])
    title('Latent heat')
    ylabel('(Wm^{-2})')
    %legend('Gill_{old}','Tc1_{old}','Tc2_{old}','Gill_{new}','Tc1_{new}','Tc2_{new}',-1)
    legend('LE_{old}','LE_{new}',-1)
    
    pause;
    
    fig=fig+1;figure(fig);
    plot_regression(LE_old(ind,:), LE_new(ind,:), [], [], 'ortho');
    title('LE comparision');
    zoom on;
    xlabel('LE (old calc) (W m^-2 )');
    ylabel('LE (new calc) (W m^-2 )');
    
end











