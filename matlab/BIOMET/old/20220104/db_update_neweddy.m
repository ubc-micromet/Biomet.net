function OutputData = db_update_neweddy(stats,pth,system_fieldname)
%
%
% (c) E. Humphreys          File created:       Feb 2003
%                           Last modification:  Jan 26, 2004
%

%
% Revisions: 
%   Jan 26, 2004 by kai* - Fixed bug that assumed that system licor was the first licor called 'EC Licor' since.
%                          Now, the instrument number of the second instrument in the system is extracted from 
%                          stats(1).Configuration DOES NOT WORK IF SYSTEM CHANGES DURING THE DAY!!!
%   Sept 7, 2003 - fixed bug that tried to use more than 1 value for 'SONICn' and 'IRGAn' in misc section
%   April 2003 - added system_fieldname option.  leave blank to default to 'MainEddy'
%            
warning off

if nargin < 2
   Systemfield   = stats(1).Configuration.System(1).FieldName;
else
   Systemfield  = system_fieldname;
end

AfterRotField = [stats(1).Configuration.System(1).Rotation '_Rotations'];
AfterRotField = [upper(AfterRotField(1)) AfterRotField(2:end)];

site          = stats(1).Configuration.site;

pth_out = fr_valid_path_name(pth);          % check the path and create
if isempty(pth_out)                         
    error 'Directory does not exist!'
else
    pth = pth_out;
end
err_count = 0;
OutputData = [];


%
% Extract and save Fluxes.LinDtr
%
try 
    FileNameMain = [pth 'flxld'];               % the full file name prefix
    OutputData1 = DB_vector(stats,[Systemfield '.' AfterRotField '.LinDtr.Fluxes.LE_L']);
    OutputData2 = DB_vector(stats,[Systemfield '.' AfterRotField '.LinDtr.Fluxes.Hs']);
    OutputData3 = DB_vector(stats,[Systemfield '.' AfterRotField '.LinDtr.Fluxes.Htc1']);
    OutputData4 = DB_vector(stats,[Systemfield '.' AfterRotField '.LinDtr.Fluxes.Htc2']);
    OutputData5 = DB_vector(stats,[Systemfield '.' AfterRotField '.LinDtr.Fluxes.Fc']);
    OutputData6 = DB_vector(stats,[Systemfield '.' AfterRotField '.LinDtr.Fluxes.LE_K']);
    OutputData7 = DB_vector(stats,[Systemfield '.' AfterRotField '.LinDtr.Fluxes.MiscVariables.B_L']);
    OutputData8 = DB_vector(stats,[Systemfield '.' AfterRotField '.LinDtr.Fluxes.MiscVariables.WUE']);
    OutputData9 = DB_vector(stats,[Systemfield '.' AfterRotField '.LinDtr.Fluxes.Ustar']);    
    OutputData10 = DB_vector(stats,[Systemfield '.' AfterRotField '.LinDtr.Fluxes.MiscVariables.Penergy']);    
    OutputData11 = DB_vector(stats,[Systemfield '.' AfterRotField '.LinDtr.Fluxes.MiscVariables.HR_coeff']);    
    OutputData12 = DB_vector(stats,[Systemfield '.' AfterRotField '.LinDtr.Fluxes.MiscVariables.B_K']);    
    
    OutputData = [];
    for i = 1:12;
        [n,m] = size(OutputData);
        eval(['[n1,m1] = size(OutputData' num2str(i) ');']);
        eval(['OutputData(n+1:n+n1,1:m1) = OutputData' num2str(i) ';']);
    end
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
    
catch
    err_count = err_count + 1;
end

%
% Extract and save Fluxes.AvgDtr
%
try 
    FileNameMain = [pth 'flxad'];               % the full file name prefix
    OutputData1 = DB_vector(stats,[Systemfield '.' AfterRotField '.AvgDtr.Fluxes.LE_L']);
    OutputData2 = DB_vector(stats,[Systemfield '.' AfterRotField '.AvgDtr.Fluxes.Hs']);
    OutputData3 = DB_vector(stats,[Systemfield '.' AfterRotField '.AvgDtr.Fluxes.Htc1']);
    OutputData4 = DB_vector(stats,[Systemfield '.' AfterRotField '.AvgDtr.Fluxes.Htc2']);
    OutputData5 = DB_vector(stats,[Systemfield '.' AfterRotField '.AvgDtr.Fluxes.Fc']);
    OutputData6 = DB_vector(stats,[Systemfield '.' AfterRotField '.AvgDtr.Fluxes.LE_K']);
    OutputData7 = DB_vector(stats,[Systemfield '.' AfterRotField '.AvgDtr.Fluxes.MiscVariables.B_L']);
    OutputData8 = DB_vector(stats,[Systemfield '.' AfterRotField '.AvgDtr.Fluxes.MiscVariables.WUE']);
    OutputData9 = DB_vector(stats,[Systemfield '.' AfterRotField '.AvgDtr.Fluxes.Ustar']);    
    OutputData10 = DB_vector(stats,[Systemfield '.' AfterRotField '.AvgDtr.Fluxes.MiscVariables.Penergy']);    
    OutputData11 = DB_vector(stats,[Systemfield '.' AfterRotField '.AvgDtr.Fluxes.MiscVariables.HR_coeff']);    
    OutputData12 = DB_vector(stats,[Systemfield '.' AfterRotField '.AvgDtr.Fluxes.MiscVariables.B_K']);    
    
    OutputData = [];
    for i = 1:12;
        [n,m] = size(OutputData);
        eval(['[n1,m1] = size(OutputData' num2str(i) ');']);
        eval(['OutputData(n+1:n+n1,1:m1) = OutputData' num2str(i) ';']);
    end
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
    
catch
    err_count = err_count + 1;
end

%
% Extract and save Angles
%
try 
    FileNameMain = [pth 'angle'];               % the full file name prefix
    OutputData1 = DB_vector(stats,[Systemfield '.' AfterRotField '.Angles.Eta']);
    OutputData2 = DB_vector(stats,[Systemfield '.' AfterRotField '.Angles.Theta']);
    OutputData3 = DB_vector(stats,[Systemfield '.' AfterRotField '.Angles.Beta']);
    
    OutputData = [];
    for i = 1:3;
        [n,m] = size(OutputData);
        eval(['[n1,m1] = size(OutputData' num2str(i) ');']);
        eval(['OutputData(n+1:n+n1,1:m1) = OutputData' num2str(i) ';']);
    end
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
 catch
    err_count = err_count + 1;
end
%
% Extract and save Misc
%
try 
   %find an Instrument field which has data
   ind = [];
   for i = 1:48; 
      if ~isempty(stats(i).Instrument); ind = i; break; end
   end
   
   if ~isempty(ind);      
      
      %find which Instrument no is the EC IRGA
      for i = 1:length(stats(ind).Instrument);
         if ~isempty(char(stats(ind).Instrument(i).Name))
            Instrument_names(i) = {stats(ind).Instrument(i).Name};
         else
            Instrument_names(i) = {'None'};
         end      
      end
      for i = 1:length(stats(1).Configuration.System);
         if ~isempty(char(stats(1).Configuration.System(i).FieldName))
            System_names(i) = {stats(1).Configuration.System(i).FieldName};
         else
            System_names(i) = {'None'};
         end      
      end
      
      % Old way - did not work if main IRGA was not first instrument named 'EC IRGA'
      % IRGAn  = STRMATCH('EC IRGA',char(Instrument_names),'exact');
      % Find second instrument in 'MainEddy
      MAINEDDYn = STRMATCH(system_fieldname,char(System_names),'exact');
      IRGAn  = stats(1).Configuration.System(MAINEDDYn).Instrument(2);
      SONICn = STRMATCH('EC Anemometer',char(Instrument_names),'exact');
      
      FileNameMain = [pth 'misc'];               % the full file name prefix
      OutputData1 = DB_vector(stats,'MiscVariables.BarometricP');
      OutputData3 = DB_vector(stats,['Instrument(' num2str(SONICn(1)) ').MiscVariables.NumOfSamples']);
      OutputData4 = DB_vector(stats,['Instrument(' num2str(IRGAn(1)) ').MiscVariables.NumOfSamples']);  
      OutputData5 = DB_vector(stats,[Systemfield '.MiscVariables.NumOfSamples']);  
      OutputData6 = DB_vector(stats,['Instrument(' num2str(SONICn(1)) ').MiscVariables.CupWindSpeed']);
      OutputData7 = DB_vector(stats,['Instrument(' num2str(SONICn(1)) ').MiscVariables.CupWindSpeed3D']);
      OutputData8 = DB_vector(stats,['Instrument(' num2str(SONICn(1)) ').MiscVariables.WindDirection']);
      OutputData9 = DB_vector(stats, [Systemfield '.' 'Delays.Calculated']);
      %OutputData10= DB_vector(stats,'MiscVariables.IRGA1problemflag');
      switch site
        case 'CR'
            OutputData2 = DB_vector(stats,['Instrument(' num2str(IRGAn(1)) ').Avg(4)']);  %IRGA pressure              
            OutputData10 = NaN.*ones(size(OutputData7));      %max diagnostic              
            OutputData11 = NaN.*ones(size(OutputData7));      %irga diagnostic 
        case 'YF'
            OutputData2 = DB_vector(stats,['Instrument(' num2str(IRGAn(1)) ').Avg(5)']);    %IRGA pressure              
            OutputData10 = DB_vector(stats,['Instrument(' num2str(SONICn(1)) ').Max(5)']);  %max diagnostic              
            OutputData11 = DB_vector(stats,['Instrument(' num2str(IRGAn(1)) ').Max(6)']);                      %irga diagnostic 
        case 'OY'
            OutputData2 = DB_vector(stats,['Instrument(' num2str(IRGAn(1)) ').Avg(4)']);   %IRGA pressure              
            OutputData10 = DB_vector(stats,['Instrument(' num2str(SONICn(1)) ').Max(5)']); %max diagnostic
            if eval(['length(stats(1).Instrument(' num2str(IRGAn(1)) ').Max)'])>4              
            OutputData11 = NaN.*ones(size(DB_vector(stats,['Instrument(' num2str(IRGAn(1)) ').Max(5)'])));    %irga diagnostic               
            else
            OutputData11 = [];
            end
        otherwise
            OutputData2 = NaN.*ones(size(OutputData7));        %IRGA pressure              
            OutputData10 = NaN.*ones(size(OutputData7));       %max diagnostic              
            OutputData11 = NaN.*ones(size(OutputData7));       %irga diagnostic 
      end      
      OutputData = [];
      for i = 1:11;
         [n,m] = size(OutputData);
         eval(['[n1,m1] = size(OutputData' num2str(i) ');']);
         eval(['OutputData(n+1:n+n1,1:m1) = OutputData' num2str(i) ';']);
      end
      x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
   end
   
catch
   err_count = err_count + 1;
end
%
% Extract and save AvgMinMax values after rotation
%
try,
    FileNameMain = [pth 'avgar'];               % the full file name prefix
   
    OutputData1 = DB_vector(stats, [Systemfield '.' AfterRotField '.Avg']);   
    OutputData2 = DB_vector(stats, [Systemfield '.' AfterRotField '.Min']);   
    OutputData3 = DB_vector(stats, [Systemfield '.' AfterRotField '.Max']);   
    OutputData4 = DB_vector(stats, [Systemfield '.' AfterRotField '.Std']);   
    
    [n,m] = size(OutputData1);
    OutputData(1:4:4.*n,:) = OutputData1;
    OutputData(2:4:4.*n,:) = OutputData2;
    OutputData(3:4:4.*n,:) = OutputData3;
    OutputData(4:4:4.*n,:) = OutputData4;
    
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
catch,
    err_count = err_count + 1;
end
%
% Extract and save AvgMinMax values before rotation
%
try,
    FileNameMain = [pth 'avgbr'];               % the full file name prefix
   
    OutputData1 = DB_vector(stats, [Systemfield '.' 'Zero_Rotations.Avg']);   
    OutputData2 = DB_vector(stats, [Systemfield '.' 'Zero_Rotations.Min']);   
    OutputData3 = DB_vector(stats, [Systemfield '.' 'Zero_Rotations.Max']);   
    OutputData4 = DB_vector(stats, [Systemfield '.' 'Zero_Rotations.Std']);   
    
    [n,m] = size(OutputData1);
    OutputData(1:4:4.*n,:) = OutputData1;
    OutputData(2:4:4.*n,:) = OutputData2;
    OutputData(3:4:4.*n,:) = OutputData3;
    OutputData(4:4:4.*n,:) = OutputData4;
    
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
catch,
    err_count = err_count + 1;
end
%
% Extract and save BeforeRot.Cov.LinDtr
%
try
    OutputData = DB_matrix_to_vector(stats, [Systemfield '.Zero_Rotations.LinDtr.Cov']);
    FileNameMain = [pth 'covbl'];               % the full file name prefix
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save BeforeRot.Cov.AvgDtr
%
try
    OutputData = DB_matrix_to_vector(stats, [Systemfield '.Zero_Rotations.LinDtr.Cov']);
    FileNameMain = [pth 'covba'];               % the full file name prefix
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save AfterRot.Cov.LinDtr
%
try
    OutputData = DB_matrix_to_vector(stats, [Systemfield '.' AfterRotField '.LinDtr.Cov']);
    FileNameMain = [pth 'coval'];               % the full file name prefix
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save AfterRot.Cov.AvgDtr
%
try
    OutputData = DB_matrix_to_vector(stats, [Systemfield '.' AfterRotField '.AvgDtr.Cov']);
    FileNameMain = [pth 'covaa'];               % the full file name prefix
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save Turbulence statistics
%
try 
    FileNameMain = [pth 'skew'];               % the full file name prefix
    OutputData = DB_vector(stats,[Systemfield '.Turbulence_Statistics.Skewness']);
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
 catch
    err_count = err_count + 1;
end
try 
    FileNameMain = [pth 'kurt'];               % the full file name prefix
    OutputData = DB_vector(stats,[Systemfield '.Turbulence_Statistics.Kurtosis']);
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
 catch
    err_count = err_count + 1;
end
%
% Extract and save Stationarity values 
%
try,
    FileNameMain = [pth 'stationary'];               % the full file name prefix
   
    OutputData1 = DB_vector(stats, [Systemfield '.Stationarity.NR']);   
    OutputData2 = DB_vector(stats, [Systemfield '.Stationarity.RE']);   
    
    OutputData = [];
    for i = 1:2;
        [n,m] = size(OutputData);
        eval(['[n1,m1] = size(OutputData' num2str(i) ');']);
        eval(['OutputData(n+1:n+n1,1:m1) = OutputData' num2str(i) ';']);
    end
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);

catch,
    err_count = err_count + 1;
end

%
% Extract and save Spike values
%
try 
    FileNameMain = [pth 'spikes'];               % the full file name prefix
    OutputData = DB_vector(stats,[Systemfield '.Spikes']);
    x = DB_save(OutputData,[stats(:).TimeVector],FileNameMain);
 catch
    err_count = err_count + 1;
 end
 
 
if err_count > 0 
    disp(sprintf('%d errors occured!',err_count))
end
%===============================================================
% LOCAL FUNCTIONS
%===============================================================
function x = file_err_chk(fid)
    if fid == -1
        error 'File opening error'
    end
    
%----------------------------------------------------------------
% DB_vector
%
function OutputData = DB_vector(statsIn,wildcard) %only works for array or single value inputs

[n,L] = size(statsIn);

%pick the first hhour structure with data to initialize OutputData
ind = [];
for i = 1:48; 
   try
      if ~isempty(getfield(statsIn,{i},wildcard)); ind = i; end
   end
   if ~isempty(ind); break; end;
end
OutputData = NaN*ones([L size(getfield(statsIn,{ind},wildcard))]);

for i = 1:L
   try
      [n_tmp, m_tmp] = size(getfield(statsIn,{i},wildcard));
      OutputData(i,:) = reshape(getfield(statsIn,{i},wildcard),1,max([n_tmp m_tmp]));
   end
end 
OutputData = squeeze(OutputData)';
    
    
%----------------------------------------------------------------
% DB_matrix_to_vector
%
function OutputData = DB_matrix_to_vector(statsIn,wildcard)

[n,L] = size(statsIn);
%pick the first hhour structure with data to initialize OutputData
ind = [];
for i = 1:48; 
   try
      if ~isempty(getfield(statsIn,{i},wildcard)); ind = i; end
   end
   if ~isempty(ind); break; end;
end

dims  = size(getfield(statsIn,{ind},wildcard));
OutputData = NaN*ones([dims(1).*dims(2) L]);

for i = 1:L
   try
    matIn = getfield(statsIn,{i},wildcard);
    dims = size(matIn);
    if length(dims) == 2
    for j=1:dims(2)
        OutputData((j-1)*dims(1)+1:j*dims(1),i) = matIn(:,j);
    end
    elseif length(dims) > 3
    error 'Too many dimensions!'
 end
 end
end


%----------------------------------------------------------------
% DB_Save
%
function x = DB_save(OutputData,TimeVector,FileNameMain);

x = 0;
if isempty(OutputData) 
    return
end

if FileNameMain(end) ~= '.'
    FileNameMain = [FileNameMain '.'];
end

timeVectorFileName = [FileNameMain(1:end-1) '_tv'];
if ~exist(timeVectorFileName)
    error 'Wrong file name/subdirectory!'
end
t = read_bor(timeVectorFileName,8);
[ind1,ind2] = db_fit_in(round(100*t),round(100*TimeVector));        % find the data range (ind2) that fits    
                                                                    % in the data base range ind1
[n,m] = size(OutputData);
if all(diff(ind2)) == 1
    for i=1:n
        fileName = [FileNameMain num2str(i)];
        fid = fopen(fileName,'rb+');
        if fid ~= -1
            status = fseek(fid,4*(ind1(1)-1),'bof');
            if status == 0
                status = fwrite(fid,OutputData(i,ind2),'float32');  % store only elements with indexes = ind2
            else
                disp('Error doing FSEEK')
            end
        else
            disp(['Error opening: ' fileName]);
        end
        fclose(fid);
    end
    x = 1;
else
    error 'data points have to be equaly spaced!'
    x = 0;
end