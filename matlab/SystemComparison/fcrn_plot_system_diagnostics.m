function h = fcrn_plot_diagnostics(Stats_all,SystemName)
% h = fcrn_plot_system_diagnostics(Stats_all,SystemName)
%
% Diagnostic plots for the system given

arg_default('SystemName','MainEddy');

plotting_setup

if isfield(Stats_all,'Configuration1')
    c = Stats_all(1).Configuration1;
    numSys = find(strcmp({c.System(:).FieldName},SystemName));
    if isempty(numSys)
        c = Stats_all(1).Configuration2;
        numSys = find(strcmp({c.System(:).FieldName},SystemName));
    end
else
    c = Stats_all(1).Configuration;
    numSys = find(strcmp({c.System(:).Name},SystemName));
end
numIns = c.System(numSys).Instrument;

strSys = num2str(numSys);
strIns = num2str(numIns');
%----------------------------------------------------
% Define variables to be extracted for both systems
%----------------------------------------------------
% This is the list of diagnostic variables that are 
% common to both system
variable_info = [...
        {'MiscVariables.OrigNumOfSamples','N_org',' '}',...
        {'MiscVariables.NumOfSamples','N',' '}',...
        {'Delays.Calculated(1)','del_CO2','samples'}',...
        {'Delays.Calculated(2)','del_H2O','samples'}',...
        {'Delays.Implemented(1)','del_CO2_used','samples'}',...
        {'Delays.Implemented(2)','del_H2O_used','samples'}',...
    ];
[n,m] = size(variable_info);

for i = 1:length(numIns)
       variable_info(:,(2*i-1)+m) = {['MiscVariables.Instrument(' strIns(i,:) ').Alignment(' strSys ').del1'],['align1_inst' strIns(i,:)],'samples'}';
       variable_info(:,2*i+m)     = {['MiscVariables.Instrument(' strIns(i,:) ').Alignment(' strSys ').del2'],['align2_inst' strIns(i,:)],'samples'}';
end

% For plotting replace the underscore
variable_info(4,:) = strrep(variable_info(2,:),'_','\_');

%----------------------------------------------------
% Extract variables for both systems
%----------------------------------------------------
[var_names_cp] = fcrn_extract_var('Stats_all',{SystemName},variable_info);

dv = datevec(tv(1));
doy = tv - datenum(dv(1),1,0);
doy_ticks = [floor(doy(1)):0.5:ceil(doy(end))];

%----------------------------------------------------
% Do comparison plots
%----------------------------------------------------
cur_sys = char(SystemName);

fsize_txorg = get(0,'DefaultTextFontSize');
fsize_axorg = get(0,'DefaultAxesFontSize'); 
set(0,'DefaultAxesFontSize',10) 
set(0,'DefaultTextFontSize',10);

h(1).name = ['Diagnostics_ ' cur_sys];
h(1).hand = figure;
set(h(1).hand,'Name',h(1).name);
set(h(1).hand,'NumberTitle','off');

% Number of samples
subplot('Position',subplot_position(3,1,1));
eval(['plot(doy,[N_org_' cur_sys ' N_' cur_sys ']);']);
subplot_label(gca,3,1,1,doy_ticks,3.4e4:0.2e4:3.8e4,2)
ylabel('N')

% Alignment delays
subplot('Position',subplot_position(3,1,2));
cc = 'bgrcmyk';
for i = 1:length(numIns)
    eval(['plot(doy,[align1_inst' strIns(i,:) '_' cur_sys '-align2_inst' strIns(i,:) '_' cur_sys '],[''o'' cc(i)]);']);
    hold on
    legend_str(i) = {c.Instrument(numIns(i)).Name};
end
eval(['subplot_label(gca,3,1,2,doy_ticks,-30:10:30,2)']);
legend(legend_str);
ylabel('Diff in alignmt CP irga (samples)')

% Sampling delays
subplot('Position',subplot_position(3,1,3));
eval(['plot(doy,del_CO2_' cur_sys ',''go'',doy,del_H2O_' cur_sys ',''bo'','...
        'doy,del_CO2_used_' cur_sys ',''g-'',doy,del_H2O_used_' cur_sys ',''b-'');']);
legend('CO2','H2O')
eval(['subplot_label(gca,3,1,3,doy_ticks,yticks([del_CO2_' cur_sys ' del_H2O_' cur_sys ']),2)']);
ylabel('CP delay (samples)')

zoom_together(gcf,'x','on')

return

