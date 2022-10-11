% read_bor_notes_micromet
%
%
%
% Based on read_bor_primer
%
% Zoran Nesic           File created:       Oct  4, 2022
%                       Last modification:  Oct  4, 2022
%


% This file is intended to serve as a manual (learning through examples)
% of how to read data from the Biomet/Micromet data base.
%
%
% Run it one section at the time (not the entire file)

%% Load one trace and plot it
pth = biomet_path(2022,'DSM','MET');            % find data base path for year = 2022, DSM site
pth = biomet_path([],'DSM','MET');              % or: find data base path for the current year, DSM site
tv = read_bor(fullfile(pth,'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object (use for all new stuff)
[DOY,year] = fr_get_doy(tv,0);                  % calculate DOY (Campbell format) from tv
x = read_bor(fullfile(pth,'MET_CNR4_Net_Avg')); % load MET_CNR4_Net_Avg trace from DSM/MET folder
plot(tv_dt,x)                                   % plot data
grid on;zoom on

%% compare two traces
pth = biomet_path(2022,'DSM','Clean/SecondStage'); % load Second Stage clean NET radiation trace
y = read_bor(fullfile(pth,'NETRAD_1_1_1'));     % no need to reload tv_dt, same data period is used
plot(tv_dt,[x y])                               % compare clean vs original
legend('Measured','Cleaned')
grid on;zoom on

%% extract a data period
indPeriod = find(tv_dt> "May 1, 2022" & tv_dt <= "Aug 1, 2022");
plot(tv_dt(indPeriod),[x(indPeriod) y(indPeriod)])  % compare clean vs original for May-Jul
legend('Measured','Cleaned')
grid on;zoom on

%% Multiple years
yearsIn = 2019:2022;                                    % loading multiple years in one go
pth = biomet_path('yyyy','BB','MET');                   % find data base path for multiple years, BB2 site
tv = read_bor(fullfile(pth,'clean_tv'),8,[],yearsIn);   % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');           % convert to Matlab's datetime object (use for all new stuff)
x = read_bor(fullfile(pth,'MET_HMP_T_2m_Avg'),[],[],yearsIn); % load MET_CNR4_Net_Avg trace from BB2/MET folder
plot(tv_dt,x)                                           % plot data
grid on; zoom on;

%% There is also a GUI program for looking at the traces
guiPlotTraces




