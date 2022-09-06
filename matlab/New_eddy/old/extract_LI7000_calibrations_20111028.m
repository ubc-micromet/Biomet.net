function [cal_values_new,cal_values] = extract_LI7000_calibrations(dateIn,configIn,instrumentNum,overwriteCal_flag)
% [cal_values_new,cal_values] = extract_LI7000_calibrations(dateIn,configIn,instrumentNum,overwriteCal_flag)
%
% Read HF data for dateIn, configIn and instrumentNum and extract calibration values.
% 
% Inputs:
% dateIn            - Exact date and time for which cal is to be extracted (default now)
% configIn          - ini-file structure (default fr_get_init(fr_current_siteid,dateIn))
% instrumentNum     - LI7000 instrument number (default first LI7000 in ini-file)
% overwriteCal_flag - overwrite cal values if already present in cal file (default 0)
%
% Outputs:
% cal_values_new    - calibration info structure (see below) including cal for dateIn
% cal_values        - calibration info structure as saved (== cal_values_new if
%                     overwriteCal_flag==0)
%
% This function assumes that LI7000 instrument has 6 channels named 
% {'CO2','H2O','Tbench','Plicor','Aux','Diag'}
% The order of these channels does not matter.
% 
% For calibration extraction to work, a LI7000 must have the following
% entries in configIn.Instrument(nLI7000) (example for HJP75)
%  .Cal.time = datenum(0,0,0,7,1); % gets rounded to end of hhour
%  .Cal.ppm = 362;  % in ppm                     
%  .Cal.ind.HF_data =        [ 1250  1350]; % HF data to be saved
%  .Cal.ind.CAL0 =           [ 1600  1700]; %  Avg period for zero value
%  .Cal.ind.CAL1 =           [ 2100  2200]; %  Avg period for span value
%  .Cal.ind.Ambient_before = [  500   600]; %  Avg period for values before cal
%  .Cal.ind.Ambient_after  = [10000 10100]; %  Avg period for values after cal
% 
% The output structures both have the following entries
%  .TimeVector
%  .ppm
%  .measured.Cal0
%           .Cal1
%           .Cal2
%           .Ambient
%  .corrected.Cal0     % THESE VALUES ARE ONLY REPLACE IF overwriteCal_flag==1
%            .Cal1
%            .Cal2
%            .Ambient
%  .HF_data
%
% (c) Zoran & kai* -            File created:       Nov 29, 2005
%                               Last modification:  March 23, 2011

% Revisions:
% Mar 23, 2011
%   -modified end of cal1 determination: looks for min or max in xcorr
%   trace dependnding on whther cal 1is higher or lower than ambient co2
% Oct 28, 2010
%   -added 'auto' cal extraction using Haar wavelet cross correlation, code
%   developed by Zoran with modifications from Nick.
% Dec 5, 2008
% -added Ignore flag to cal_values structure (default = 0, i.e. use
% calibration); allows user to set flag to 1 so that bad calibrations will
% not be used (Nick)
% Feb 15, 2007
%   - changed the way dateIn is used.  Program will now automatically get
%   the calibration time from the xx_init_all and use it to find the half
%   hour for the day: floor(dateIn) to extract the calibrations from.
%   - added fr_round_time, when loading data file, to round up the hhour to the next full 30 min period
% Nov 29, 2005 - Major overhaul of ini-info and output structures

arg_default('dateIn',now);
arg_default('configIn',fr_get_init(fr_current_siteid,dateIn));
types = {configIn.Instrument(:).Type};
i7000 = find(strcmp(types,'7000'));
arg_default('instrumentNum',i7000(1));
arg_default('overwriteCal_flag',0);

if length(dateIn) > 1
    error Date argument cannot be a vector.  Scalars only.
end

dateIn   = fr_round_hhour(dateIn,2);        % Round to end of hhours

extTmp = configIn.ext;
extTmp(2) = 'c';            % replace "d" with "c" for calibration
calFileName = fullfile(configIn.hhour_path,['calibrations' extTmp configIn.Instrument(instrumentNum).FileID '.mat']);

% Commented out on Feb 15, 2007 by Zoran.  From now on the extractions will be
% done based on the info from the calibration file (xx_init_all.m). See below.
% dv = datevec(dateIn);
% if fr_round_hhour(configIn.Instrument(instrumentNum).Cal.time,2) ...
%         ~= fr_round_hhour(dateIn-datenum(dv(1),dv(2),dv(3)),2)
%     disp([datestr(dateIn) ' is not a calibration hhour for instrument ' num2str(instrumentNum)]);
%     % Load old calibration data
%     cal_values_new = [];
%     try, load(calFileName); catch, cal_values = []; end
%     return
% end
dateIn = floor(dateIn)+configIn.Instrument(instrumentNum).Cal.time;  % Added Feb 15, 2007 (Z)

%-------------------------------------
% Open HF data file
%-------------------------------------
[fullFileName,fileName] = fr_find_data_file(dateIn,configIn,instrumentNum);

funName = ['fr_read_' configIn.Instrument(instrumentNum).FileType];                 % function name
try
    % Feb 15, 2007 (Z) added fr_round_time to round up the hhour to the
    % next full 30 min period
    [EngUnits_tmp,headers_tmp] = feval(funName,fr_round_time(dateIn,[],2),configIn,instrumentNum);          % call the function
  
    
catch
    disp(sprintf('Could not find file: %s',fileName));
    cal_values_new = [];
    try, load(calFileName); catch, cal_values = []; end
    return
end

if length(EngUnits_tmp) < configIn.Instrument(instrumentNum).Cal.ind.Ambient_after(2)
    cal_values_new = [];
    try, load(calFileName); catch, cal_values = []; end
    return
end

%-------------------------------------
% Extract calibration info
%-------------------------------------
% Find position of channels
[dum,ind,ind_chan] = intersect(upper({'CO2','H2O','Tbench','Plicor','Aux','Diag'}),...
    upper(configIn.Instrument(instrumentNum).ChanNames) );
[dum,ind_new] = sort(ind); % Intersect sorts the output, this can be used to undo the sort
ind_chan = ind_chan(ind_new);

Cal = configIn.Instrument(instrumentNum).Cal; % Just so the code be low is shorter...

% General cal info
cal_values_new.TimeVector = dateIn;
cal_values_new.SerNum     = configIn.Instrument(instrumentNum).SerNum;

if isfield(configIn.Instrument(instrumentNum).Cal,'ExtractType')
    if strcmp(upper(configIn.Instrument(instrumentNum).Cal.ExtractType),'MANUAL')
        % Extract means for the four cal periods using sample indexes from init_all
        % file
        tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.CAL0(1):Cal.ind.CAL0(2),ind_chan)));
        cal_values_new.measured.Cal0 = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
        cal_values_new.measured.Cal0.Cal_ppm = Cal.ppm(1);

        tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.CAL1(1):Cal.ind.CAL1(2),ind_chan)));
        cal_values_new.measured.Cal1 = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
        cal_values_new.measured.Cal1.Cal_ppm = Cal.ppm(2);

        tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.CAL2(1):Cal.ind.CAL2(2),ind_chan)));
        cal_values_new.measured.Cal2 = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
        cal_values_new.measured.Cal2.Cal_ppm = Cal.ppm(3);

        tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.Ambient_before(1):Cal.ind.Ambient_after(2),ind_chan)));
        cal_values_new.measured.Ambient_before = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
        tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.Ambient_after(1):Cal.ind.Ambient_after(2),ind_chan)));
        cal_values_new.measured.Ambient_after = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);

        % Extract HF data
        cal_values_new.HF_data = EngUnits_tmp(Cal.ind.HF_data(1):Cal.ind.HF_data(2),:);

    else % 'AUTO' cal extraction using Haar wavelet, Oct 28, 2010: Zoran's code/Nick's mods
        
        %% extract calibration settings from init_all
        lenavg         = configIn.Instrument(instrumentNum).Cal.ind.PointsToAverage;
        buf            = configIn.Instrument(instrumentNum).Cal.ind.PointsToSkip;
        HF_length      = configIn.Instrument(instrumentNum).Cal.ind.HF_data_length;
        
        %% Create a Haar wavelet
        do_plots = 0;
        N = 400;
        y=[-ones(N/2,1); ones(N/2,1)];

        %% Cross-correlate CO2 with the wavelet
        [c,l]=xcorr(EngUnits_tmp(:,1),y);

        %% Find the "zero" time offset based on the properties of xcorr
        sample_offset = length(EngUnits_tmp)-N/2;

        % Lag vector:
        lags_vector = (1:length(c)) - sample_offset;

        % get the index of lags greater than zero
        ind_new = find(lags_vector>0);
        lags_vector = lags_vector(ind_new);
        c = c(ind_new);

        %  and remove the trailing points (the wavelet length number of them)
        lags_vector = lags_vector(1:end - N);
        c = c(1:end-N);

        %% Find where CAL0 starts:
        [minCorr, ind_cal0] = min(c);

        %% Find where CAL1 starts:
        [minCorr, ind_cal1] = max(c(ind_cal0:end));
        ind_cal1 = ind_cal1 + ind_cal0;

        if ind_cal0 > lenavg+buf
            indAvgAmbient_before = ind_cal0-lenavg-buf:ind_cal0-buf;
        else
            indAvgAmbient_before = 1:ind_cal0;
        end

        indAvgCal0 = ind_cal1-lenavg-buf:ind_cal1-buf;

        
        %% Find where CAL1 ends:
        % Note: we need to know whether cal1 is higher or lower than
        % ambient CO2 at the time of the calibration in order to know
        % whether to look for another max or min in the xcorr trace
        
        ambco2=mean(EngUnits_tmp(indAvgAmbient_before,1));
        if configIn.cal1 > ambco2
          [minCorr, ind_cal2] = min(c(ind_cal1+N/2:end));
          ind_cal2 = ind_cal2 + ind_cal1+N/2;
        else
           [minCorr, ind_cal2] = max(c(ind_cal1+N/2:end));
          ind_cal2 = ind_cal2 + ind_cal1+N/2; 
        end

        % store duration of cal cycles
        %CAL0
        DurationCal0 = (ind_cal1-ind_cal0); % duration in samples
        %CAL1
        DurationCal1 = (ind_cal2-ind_cal1); % duration in samples

        
        indAvgCal1 = ind_cal2-lenavg-buf:ind_cal2-buf;

        indAvgCal2 = ind_cal2+buf:ind_cal2+buf+lenavg;

        if ind_cal2+buf+4*lenavg <= size(EngUnits_tmp,1)
            indAvgAmbient_after = ind_cal2+buf+3*lenavg:ind_cal2+buf+4*lenavg;
        else
            indAvgAmbient_after = ind_cal2+buf+3*lenavg:size(EngUnits_tmp,1);
        end

        % Extract means for the four cal periods using sample indexes from Haar
        % wavelet xcorr analysis
        tempCell = num2cell(mean(EngUnits_tmp(indAvgCal0,ind_chan)));
        cal_values_new.measured.Cal0 = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
        cal_values_new.measured.Cal0.Cal_ppm = Cal.ppm(1);
        cal_values_new.measured.Cal0.indAvg  = indAvgCal0;
        cal_values_new.measured.Cal0.indBegin = ind_cal0;
        cal_values_new.measured.Cal0.Duration = DurationCal0;

        tempCell = num2cell(mean(EngUnits_tmp(indAvgCal1,ind_chan)));
        cal_values_new.measured.Cal1 = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
        cal_values_new.measured.Cal1.Cal_ppm = Cal.ppm(2);
        cal_values_new.measured.Cal1.indAvg  = indAvgCal1;
        cal_values_new.measured.Cal1.indBegin = ind_cal1;
        cal_values_new.measured.Cal1.Duration = DurationCal1;

        tempCell = num2cell(mean(EngUnits_tmp(indAvgCal2,ind_chan)));
        cal_values_new.measured.Cal2 = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
        cal_values_new.measured.Cal2.Cal_ppm = Cal.ppm(3);
        cal_values_new.measured.Cal2.indAvg  = indAvgCal2;

        tempCell = num2cell(mean(EngUnits_tmp(indAvgAmbient_before,ind_chan)));
        cal_values_new.measured.Ambient_before = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
        cal_values_new.measured.Ambient_before.indAvg = indAvgAmbient_before;

        tempCell = num2cell(mean(EngUnits_tmp(indAvgAmbient_after,ind_chan)));
        cal_values_new.measured.Ambient_after = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
        cal_values_new.measured.Ambient_after.indAvg = indAvgAmbient_after;

        % Extract HF data
        cal_values_new.HF_data = EngUnits_tmp(ind_cal0-buf:ind_cal0-buf+HF_length,:);

        if do_plots
            % plot CO2 and H2O responses together with extracted cal values.
            figure(1)
            plot(EngUnits_tmp(:,1))
            ax=axis;
            line([ind_cal0 ind_cal0],ax(3:4),'color','r');
            line([ind_cal1 ind_cal1],ax(3:4),'color','m');
            line([ind_cal2 ind_cal2],ax(3:4),'color','g');

            hold on;
            plot(mean(cal_values_new.measured.Ambient_before.indAvg),cal_values_new.measured.Ambient_before.CO2,'ms','MarkerSize',10,'linewidth',3)
            plot(mean(cal_values_new.measured.Cal0.indAvg),cal_values_new.measured.Cal0.CO2,'ms','MarkerSize',10,'linewidth',3)
            plot(mean(cal_values_new.measured.Cal1.indAvg),cal_values_new.measured.Cal1.CO2,'ms','MarkerSize',10,'linewidth',3)
            plot(mean(cal_values_new.measured.Cal2.indAvg),cal_values_new.measured.Cal2.CO2,'ms','MarkerSize',10,'linewidth',3)
            plot(mean(cal_values_new.measured.Ambient_after.indAvg),cal_values_new.measured.Ambient_after.CO2,'ms','MarkerSize',10,'linewidth',3)
            title('CO2');
            hold off;

            figure(2)
            plot(EngUnits_tmp(:,2))
            ax=axis;
            line([ind_cal0 ind_cal0],ax(3:4),'color','r');
            line([ind_cal1 ind_cal1],ax(3:4),'color','m');
            line([ind_cal2 ind_cal2],ax(3:4),'color','g');

            hold on;
            plot(mean(cal_values_new.measured.Ambient_before.indAvg),cal_values_new.measured.Ambient_before.H2O,'ms','MarkerSize',10,'linewidth',3)
            plot(mean(cal_values_new.measured.Cal0.indAvg),cal_values_new.measured.Cal0.H2O,'ms','MarkerSize',10,'linewidth',3)
            plot(mean(cal_values_new.measured.Cal1.indAvg),cal_values_new.measured.Cal1.H2O,'ms','MarkerSize',10,'linewidth',3)
            plot(mean(cal_values_new.measured.Cal2.indAvg),cal_values_new.measured.Cal2.H2O,'ms','MarkerSize',10,'linewidth',3)
            plot(mean(cal_values_new.measured.Ambient_after.indAvg),cal_values_new.measured.Ambient_after.H2O,'ms','MarkerSize',10,'linewidth',3)
            title('H2O')
            hold off;
            pause;
        end
    end
else % if ExtractType not specified assume manual extraction
    % Extract means for the four cal periods using sample indexes from init_all
    % file
    tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.CAL0(1):Cal.ind.CAL0(2),ind_chan)));
    cal_values_new.measured.Cal0 = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
    cal_values_new.measured.Cal0.Cal_ppm = Cal.ppm(1);

    tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.CAL1(1):Cal.ind.CAL1(2),ind_chan)));
    cal_values_new.measured.Cal1 = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
    cal_values_new.measured.Cal1.Cal_ppm = Cal.ppm(2);

    tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.CAL2(1):Cal.ind.CAL2(2),ind_chan)));
    cal_values_new.measured.Cal2 = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
    cal_values_new.measured.Cal2.Cal_ppm = Cal.ppm(3);

    tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.Ambient_before(1):Cal.ind.Ambient_after(2),ind_chan)));
    cal_values_new.measured.Ambient_before = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);
    tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.Ambient_after(1):Cal.ind.Ambient_after(2),ind_chan)));
    cal_values_new.measured.Ambient_after = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor','Aux','Diag'},2);

    % Extract HF data
    cal_values_new.HF_data = EngUnits_tmp(Cal.ind.HF_data(1):Cal.ind.HF_data(2),:);
end
cal_values_new.corrected = cal_values_new.measured;

%-------------------------------------
% Save calibration info
%-------------------------------------
% Load old calibration data
try
    load(calFileName);
catch
    cal_values = cal_values_new;
    save(calFileName,'cal_values');
    disp([calFileName ' does not exist. Creating it now...']);
    return
end

if isfield(cal_values,'Ignore')
    % -------ignore cal flag: Nick inserted Nov 21, 2007 ------
    cal_values_new.Ignore = 0; % default: set to include calibration
    %----------------------------------------------------------
end

% Insert new cal info into appropriate place in cal_values
ind = find (cal_values_new.TimeVector == get_stats_field(cal_values,'TimeVector')); 
if ~isempty(ind)
    if overwriteCal_flag ~= 0 
        % Copy measured values to entries that will be used in actual calibrations
        cal_values(ind)=cal_values_new;
        disp([datestr(dateIn) ' - instrument ' num2str(instrumentNum) ' - calibration overwritten']);
    else
        disp([datestr(dateIn) ' - instrument ' num2str(instrumentNum) ' - calibration already present']);
    end
else
    ind = find (cal_values_new.TimeVector > get_stats_field(cal_values,'TimeVector')); 
    N = size(cal_values,2);
    if isempty(ind)
        % new value goes first
        cal_values = [cal_values_new cal_values];
    elseif ind(end) == N
        % new value goes last
        cal_values = [cal_values cal_values_new];
    else
        % new value goes in the middle
        cal_values = [cal_values(ind) cal_values_new cal_values(ind(end)+1:end)];
    end
    disp([datestr(dateIn) ' - instrument ' num2str(instrumentNum) ' - new calibration']);

end
save(calFileName,'cal_values');