function [cal_values_new,cal_values] = extract_LI6262_calibrations(dateIn,configIn,instrumentNum,overwriteCal_flag)
% [cal_values_new,cal_values] = extract_LI6262_calibrations(dateIn,configIn,instrumentNum,overwriteCal_flag)
%  based on extract_LI7000_calibrations
% Read HF data for dateIn, configIn and instrumentNum and extract calibration values.
% 
% Inputs:
% dateIn            - Exact date and time for which cal is to be extracted (default now)
% configIn          - ini-file structure (default fr_get_init(fr_current_siteid,dateIn))
% instrumentNum     - LI6262 instrument number
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
% For calibration extraction to work, a LI6262 must have the following
% entries in configIn.Instrument(nIRGA) (example for HJP75)
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
% Zoran & Nick - Jun 26, 2008

% Revisions:
% 

arg_default('dateIn',now);
arg_default('configIn',fr_get_init(fr_current_siteid,dateIn));
arg_default('overwriteCal_flag',0);

if length(dateIn) > 1
    error Date argument cannot be a vector.  Scalars only.
end

dateIn   = fr_round_hhour(dateIn,2);        % Round to end of hhours

extTmp = configIn.ext;
extTmp(2) = 'c';            % replace "d" with "c" for calibration
calFileName = fullfile(configIn.hhour_path,['calibrations' extTmp num2str(instrumentNum) '.mat']);

dv = datevec(dateIn);
%dv_cal = datevec(configIn.Instrument(instrumentNum).Cal.time);
if fr_round_hhour(configIn.Instrument(instrumentNum).Cal.time,2) ...
        ~= fr_round_hhour(dateIn-datenum(dv(1),dv(2),dv(3)),2)
    disp([datestr(dateIn,0) ' is not a calibration hhour for instrument ' num2str(instrumentNum)]);
    %dateIn = datenum(dv(1),dv(2),dv(3),dv_cal(4),dv_cal(5),dv_cal(6));
    %disp(['Calibration hhour info from ini file is ' datestr(dateIn,0) ]);
    % Load old calibration data
    cal_values_new = [];
    try, load(calFileName); catch, cal_values = []; end
   % return
end

%-------------------------------------
% Read HF data 
%-------------------------------------
try
    if ~strcmp(upper(configIn.Instrument(instrumentNum).FileType), 'INSTRUMENT')
        funName = ['fr_read_' configIn.Instrument(instrumentNum).FileType];                 % function name
        [EngUnits_tmp,headers_tmp] = feval(funName,dateIn,configIn,instrumentNum);          % call the function
        % run the data through polynomials
        if isfield(configIn.Instrument(instrumentNum),'Poly') & ~isempty(configIn.Instrument(instrumentNum).Poly)
            for j=1:configIn.Instrument(instrumentNum).NumOfChans;
                p = configIn.Instrument(instrumentNum).Poly(j,:);
                Instrument_data(instrumentNum).EngUnits(:,j) = polyval(p,Instrument_data(instrumentNum).EngUnits(:,j));
            end
        end
        
    else
        % for 'INSTRUMENT' type 
        % first load the data from the parent instrument.
        % Find parent instrument number
        parentInstrumentNum = str2num(configIn.Instrument(instrumentNum).FileID);
  
        % load data from the parent instrument
        funName = ['fr_read_' configIn.Instrument(parentInstrumentNum).FileType];                 % function name
        [parentInstrumentData,headers_tmp] = feval(funName,dateIn,configIn,parentInstrumentNum);          % call the function

        % run the data through polynomials
        if isfield(configIn.Instrument(parentInstrumentNum),'Poly') & ~isempty(configIn.Instrument(parentInstrumentNum).Poly)
            for j=1:configIn.Instrument(parentInstrumentNum).NumOfChans;
                p = configIn.Instrument(parentInstrumentNum).Poly(j,:);
                parentInstrumentData(:,j) = polyval(p,parentInstrumentData(:,j));
            end
        end
        
  
        % find where the 6262 data is (what channels)
        chanNums = configIn.Instrument(instrumentNum).ChanNumbers;
        % and extract them
        EngUnits_tmp = parentInstrumentData(:,chanNums);
    end
catch
  disp('Could not load data file for cal extractions');  %disp(sprintf('Could not find file: %s',fileName));
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
[dum,ind,ind_chan] = intersect(upper({'co2','h2o','Tcell','Pcell'}),...
    upper(configIn.Instrument(instrumentNum).ChanNames) );
[dum,ind_new] = sort(ind); % Intersect sorts the output, this can be used to undo the sort
ind_chan = ind_chan(ind_new);

Cal = configIn.Instrument(instrumentNum).Cal; % Just so the code be low is shorter...

% General cal info
cal_values_new.TimeVector = dateIn;
cal_values_new.SerNum     = configIn.Instrument(instrumentNum).SerNum;

% Extract means for the four cal periods
tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.CAL0(1):Cal.ind.CAL0(2),ind_chan)));
cal_values_new.measured.Cal0 = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor'},2);
cal_values_new.measured.Cal0.Cal_ppm = Cal.ppm(1);

tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.CAL1(1):Cal.ind.CAL1(2),ind_chan)));
cal_values_new.measured.Cal1 = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor'},2);
cal_values_new.measured.Cal1.Cal_ppm = Cal.ppm(2);

tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.CAL2(1):Cal.ind.CAL2(2),ind_chan)));
cal_values_new.measured.Cal2 = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor'},2);
cal_values_new.measured.Cal2.Cal_ppm = Cal.ppm(3);

tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.Ambient_before(1):Cal.ind.Ambient_before(2),ind_chan)));
cal_values_new.measured.Ambient_before = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor'},2);
tempCell = num2cell(mean(EngUnits_tmp(Cal.ind.Ambient_after(1):Cal.ind.Ambient_after(2),ind_chan)));
cal_values_new.measured.Ambient_after = cell2struct(tempCell,{'CO2','H2O','Tbench','Plicor'},2);

cal_values_new.corrected = cal_values_new.measured;

% Extract HF data
cal_values_new.HF_data = EngUnits_tmp(Cal.ind.HF_data(1):Cal.ind.HF_data(2),:);

% Set an ignore flag to 0 (don't ignore)

cal_values_new.Ignore = 0;

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

% Insert new cal info into appropriate place in cal_values
ind = find (cal_values_new.TimeVector == get_stats_field(cal_values,'TimeVector')); 
if ~isempty(ind)
    if overwriteCal_flag ~= 0 
        % Copy measured values to entries that will be used in actual calibrations
        cal_values(ind)=cal_values_new;
        disp([datestr(dateIn) ' - instrument ' num2str(instrumentNum) ' - overwrite calibration']);
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