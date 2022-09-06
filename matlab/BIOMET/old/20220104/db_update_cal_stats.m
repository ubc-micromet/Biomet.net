function OutputData = db_update_cal_stats(stats,pth)
%
% based on db_create_eddy   File created:       Aug  1, 2003
%                           Last modification:  Aug  1, 2003

%
% Revisions:
% 

pth_out = fr_valid_path_name(pth);          % check the path and create
if isempty(pth_out)                         
   error 'Directory does not exist!'
else
   pth = pth_out;
end
err_count = 0;
OutputData = [];
OutputData1 = [];
OutputData2 = [];
OutputData3 = [];

if isfield(stats,'Configuration') & ~isempty(stats.Configuration)
   config = stats.Configuration;
else
   % We should extract data from cal files
   % but right now there is no way to garantie 
   % that the most recent cal file is assecible
   %[CO2_cal, H2O_cal, cal_voltage, calTime,LicorNum] = ...
   %   fr_get_Licor_cal([pth 'calibrations]);
   
   % Use cal info in *\cal database
   disp(['No calibration information found - using database']);
   
   % Eddy Licor
   [CO2_cal_fl, H2O_cal_fl] = fr_get_Licor_cal_db(fr_current_siteid,stats.TimeVector,'Flux');
   % Profile Licor
   [CO2_cal_pr, H2O_cal_pr] = fr_get_Licor_cal_db(fr_current_siteid,stats.TimeVector,'Profile');
   % Chamber Licor
   [CO2_cal_ch, H2O_cal_ch] = fr_get_Licor_cal_db(fr_current_siteid,stats.TimeVector,'Chambers');
   
   for i = 1:length(stats.TimeVector)
      if ~isempty(CO2_cal_fl)
         config(i).CO2_Cal   = CO2_cal_fl(i,:);
         config(i).H2O_Cal   = H2O_cal_fl(i,:);
         config(i).licor     = NaN;
         config(i).span_conc = NaN;
      end
      if ~isempty(CO2_cal_pr)
         config(i).Profile.Licor.CO2_cal = CO2_cal_pr(i,:);
         config(i).Profile.Licor.H2O_cal = H2O_cal_pr(i,:);
         config(i).Profile.Licor.Num     = NaN;
         config(i).Profile.span_conc     = NaN;
      end
      if ~isempty(CO2_cal_ch)
         config(i).chamber.Licor.CO2_cal = CO2_cal_pr(i,:);
         config(i).chamber.Licor.H2O_cal = H2O_cal_pr(i,:);
         config(i).chamber.Licor.Num     = NaN;
         config(i).chamber.span_conc     = NaN;
      end
   end
end

%
% Extract and save Eddy calibration information
% This always exists, so no need to check
try,
   co2_span = extract_config(config,'CO2_Cal(1)');
   co2_off  = extract_config(config,'CO2_Cal(2)');
   h2o_span = extract_config(config,'H2O_Cal(1)');
   h2o_off  = extract_config(config,'H2O_Cal(2)');
   Num  = extract_config(config,'licor');
   span_conc = extract_config(config,'span_conc');
   
   FileNameMain = [pth 'Flux\cal_stats'];               % the full file name prefix
   OutputData1 = [co2_span co2_off h2o_span h2o_off Num span_conc]';
   x = DB_save(OutputData1,stats.TimeVector,FileNameMain);
catch,
   err_count = err_count + 1;
end

%
% Extract and save Profile calibration information
%
if isfield(config,'Profile')
   try,
      sys = 'Profile.Licor.';
      co2_span = extract_config(config,[sys 'CO2_cal(1)']);
      co2_off  = extract_config(config,[sys 'CO2_cal(2)']);
      h2o_span = extract_config(config,[sys 'H2O_cal(1)']);
      h2o_off  = extract_config(config,[sys 'H2O_cal(2)']);
      Num  = extract_config(config,[sys 'Num']);
      span_conc = extract_config(config,'Profile.span_conc');
      
      FileNameMain = [pth 'Profile\cal_stats'];               % the full file name prefix
      OutputData2 = [co2_span co2_off h2o_span h2o_off Num span_conc]';
      x = DB_save(OutputData2,stats.TimeVector,FileNameMain);
   catch,
      err_count = err_count + 1;
   end
end
%
% Extract and save Chamber Licor calibration information
%
if isfield(config,'chamber')
   try,
      sys = 'chamber.Licor.';
      co2_span = extract_config(config,[sys 'CO2_cal(1)']);
      co2_off  = extract_config(config,[sys 'CO2_cal(2)']);
      h2o_span = extract_config(config,[sys 'H2O_cal(1)']);
      h2o_off  = extract_config(config,[sys 'H2O_cal(2)']);
      Num  = extract_config(config,[sys 'Num']);
      span_conc = extract_config(config,'Profile.span_conc');
      
      FileNameMain = [pth 'Chambers\cal_stats'];               % the full file name prefix
      OutputData3 = [co2_span co2_off h2o_span h2o_off Num span_conc]';
      x = DB_save(OutputData3,stats.TimeVector,FileNameMain);
   catch,
      err_count = err_count + 1;
   end
end
OutputData = [OutputData1' OutputData2' OutputData3'];		
%--------------------------------------------------------
% Internal functions
%--------------------------------------------------------

function val = extract_config(config,field)

n = length(config);
val = NaN .* ones(n,1);
for i = 1:n
   eval(['val(i) = config(i).' field ';']);
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