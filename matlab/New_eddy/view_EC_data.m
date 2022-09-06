function view_EC_data(dateIn)
% view_EC_data(dateIn) - loads and plots system HF data for a UBC EC system
%
% Note:  Current data (dateIn = now) is not available with 
%        UBC_GII software.  Only the historical data can be plotted
%        using this program (any 30-minute period before the current one)
%
% (c) Zoran Nesic               File created:       Sep 16, 2007
%                               Last modification:  Sep 16, 2007

% View_EC_data(now-1/48) % Previous h-hour data 
% View_EC_data(now-5/48) % Previous 5th h-hour

% suppress warnings
warning off MATLAB:divideByZero

% Get current site ID
SiteID = fr_current_siteID;

% Run the 30-minute EC data calculations with the option of getting back
% the high frequency data.  HF.System data is the data used for EC calculations.
% HF.Instrument data is the original data as stored in the HF files (before
% alignment, delay, re-sampling or any other modifications).
[Stats_New,HF_Data] = yf_calc_module_main(dateIn,SiteID,2);

% System sampling frequency, time vector...
numOfInstruments = length(HF_Data.Instrument);
Fs = Stats_New.Configuration.System.Fs;
PDQNum = 1;
sonicNum = Stats_New.MainEddy.SourceInstrumentNumber(1);    % sonic instrument number
IRGANum  = Stats_New.MainEddy.SourceInstrumentNumber(2);    % IRGA instrument number
nSystem = Stats_New.MainEddy.MiscVariables.NumOfSamples;    % number of system samples
nSonic = Stats_New.Instrument(sonicNum).MiscVariables.NumOfSamples;
nIRGA  = Stats_New.Instrument(IRGANum).MiscVariables.NumOfSamples;
timeVectorSystem = [1:nSystem]/Fs;                          % is seconds

% Instrument sampling frequency, time vector...
Sonic_Fs = Stats_New.Configuration.Instrument(sonicNum).Fs;
timeVectorSonic = [1:nSonic]/Sonic_Fs;                      % is seconds
IRGA_Fs = Stats_New.Configuration.Instrument(IRGANum).Fs;
timeVectorIRGA = [1:nIRGA]/IRGA_Fs;                         % is seconds

fig = 0;

% Plot wind data
fig = fig+1;
figure (fig)
plot(timeVectorSystem,HF_Data.System.EngUnits(:,1:3))
cupWindSpeedHF = sqrt((sum([HF_Data.System.EngUnits(:,1:3)'].^2)))';
line(timeVectorSystem,cupWindSpeedHF,'color','c')
title(sprintf('Sonic wind speeds. (N = %d/%d)',nSystem,nSonic))
xlabel('Seconds')
ylabel('m/s')
set(fig,'numbertitle','off','Name','Wind speeds')
zoom on
legend('u','v','w','cup',-1)

% Plot wind direction data
fig = fig+1;
figure (fig)
plot(0:10:360,Stats_New.Instrument(sonicNum).MiscVariables.WindDirection_Histogram)
title('Sonic wind directions')
xlabel('Degrees North')
ylabel('Number of points')
set(fig,'numbertitle','off','Name','Wind directions')
zoom on

% Plot temperature data
fig = fig+1;
figure (fig)
plot(timeVectorSystem,HF_Data.System.EngUnits(:,4),timeVectorSonic,HF_Data.Instrument(sonicNum).EngUnits(:,4))
title('Sonic air temperature')
xlabel('Seconds')
ylabel('\circC')
set(fig,'numbertitle','off','Name','Sonic Temperature')
zoom on
legend('Corrected','Measured')

% Plot IRGA co2 data
fig = fig+1;
figure (fig)
plot(timeVectorSystem,HF_Data.System.EngUnits(:,5))
title(sprintf('CO2. (N = %d/%d)',nSystem,nIRGA))
xlabel('Seconds')
ylabel('ppm - mixing ratio')
set(fig,'numbertitle','off','Name','CO2')
zoom on

% Plot IRGA h2o data
fig = fig+1;
figure (fig)
plot(timeVectorSystem,HF_Data.System.EngUnits(:,6))
title(sprintf('H2O. (N = %d/%d)',nSystem,nIRGA))
xlabel('Seconds')
ylabel('mmol/mol - mixing ratio')
set(fig,'numbertitle','off','Name','H2O')
zoom on

% Plot IRGA Temperature data
fig = fig+1;
figure (fig)
plot(timeVectorIRGA,HF_Data.Instrument(IRGANum).EngUnits(:,3))
title(sprintf('IRGA Tbench/Plicor (N = %d)',nIRGA))
xlabel('Seconds')
ylabel('\circC')
set(fig,'numbertitle','off','Name','Tbench')
zoom on

% Plot IRGA Pressure data
fig = fig+1;
figure (fig)
clf
[ax,h1,h2] = plotyy(timeVectorIRGA,HF_Data.Instrument(IRGANum).EngUnits(:,4),timeVectorIRGA,polyval([0.02 -5],HF_Data.Instrument(IRGANum).EngUnits(:,5)));
title(sprintf('IRGA Tbench/Plicor (N = %d)',nIRGA))
xlabel('Seconds')
set(get(ax(1),'YLabel'),'string','Licor Pressure (kPa)')
set(get(ax(2),'YLabel'),'string','Gauge Pressure (kPa)')
set(fig,'numbertitle','off','Name','IRGA pressures')
zoom on

LGRNum = [];
% Check if LGR data is available and plot it too
for instNum=1:numOfInstruments
    if strcmpi(Stats_New.Configuration.Instrument(instNum).Type, 'LGR_CH4N2O')
        LGRNum = instNum;
        % If LGR_CH4N2O is found, plot its data too
        LGR_Fs = Stats_New.Configuration.Instrument(LGRNum).Fs;
        timeVectorLGR =HF_Data.Instrument(LGRNum).EngUnits(:,end)- ...
                        HF_Data.Instrument(LGRNum).EngUnits(:,1); % is seconds
        nLGR  = Stats_New.Instrument(LGRNum).MiscVariables.NumOfSamples;
        
        % Plot IRGA h2o data
        fig = fig+1;
        figure (fig)
        plot(timeVectorSystem,HF_Data.System.EngUnits(:,6:7))
        title({sprintf('H2O_{LI-7000}. (N = %d/%d)',nSystem,nIRGA),...
               sprintf('H2O_{LGR}. (N = %d/%d)',nSystem,nLGR)})
        legend('LI-7000','LGR')
        xlabel('Seconds')
        ylabel('mmol/mol - mixing ratio')
        set(fig,'numbertitle','off','Name','H2O')
        zoom on
        
        % Plot IRGA n2o data
        fig = fig+1;
        figure (fig)
        plot(timeVectorSystem,HF_Data.System.EngUnits(:,8))
        title(sprintf('N_2O. (N = %d/%d)',nSystem,nLGR))
        xlabel('Seconds')
        ylabel('mmol/mol - mixing ratio')
        set(fig,'numbertitle','off','Name','N2O')
        zoom on
        
        % Plot IRGA ch4 data
        fig = fig+1;
        figure (fig)
        plot(timeVectorSystem,HF_Data.System.EngUnits(:,9))
        title(sprintf('CH_4. (N = %d/%d)',nSystem,nLGR))
        xlabel('Seconds')
        ylabel('mmol/mol - mixing ratio')
        set(fig,'numbertitle','off','Name','CH4')
        zoom on
    end
end
    

disp('==========================')
disp('Data points collected')
fprintf('System: %d\n',nSystem)
fprintf('Sonic:  %d\n',nSonic)
fprintf('IRGA:   %d\n',nIRGA)
disp('Fluxes:')
fprintf('Fc     = %8.2f\n',Stats_New.MainEddy.Three_Rotations.LinDtr.Fluxes.Fc)
fprintf('Hs     = %8.2f\n',Stats_New.MainEddy.Three_Rotations.LinDtr.Fluxes.Hs)
fprintf('LE     = %8.2f\n',Stats_New.MainEddy.Three_Rotations.LinDtr.Fluxes.LE_L)
if ~isempty(LGRNum)
    fprintf('LE_LGR = %8.2f\n',Stats_New.MainEddy.Three_Rotations.LinDtr.Fluxes.LE_LGR)
    fprintf('F_n2o  = %8.2f\n',Stats_New.MainEddy.Three_Rotations.LinDtr.Fluxes.F_n2o)
    fprintf('F_ch4  = %8.2f\n',Stats_New.MainEddy.Three_Rotations.LinDtr.Fluxes.F_ch4)
end
fprintf('u*     = %8.2f\n',Stats_New.MainEddy.Three_Rotations.LinDtr.Fluxes.Ustar)
disp('Delay times:');
disp(Stats_New.MainEddy.Delays);
disp('==========================')