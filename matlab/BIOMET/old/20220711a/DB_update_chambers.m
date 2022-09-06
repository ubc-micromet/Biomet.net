function OutputData = DB_update_chambers(Stats,pth)
%Function that is called by DB_main_update_chambers and update chamber database files
%
%syntax : OutputData = db_update_chambers(stats,pth)
%
%dgg 2002.02.15
%
%Revisions:
% Mar 15, 2005 kai* - Got rid of siteFlag input to make list of 
%                     arguments conform to what db_incremental_update expects.
%                     siteFlag was used to decide whether to extract vwc. Now
%                     there is a simple check of the existance of this field.

pth_out = fr_valid_path_name(pth);                  % check the path and create
if isempty(pth_out)                         
   error 'Directory does not exist!'
else
   pth = pth_out;
end
err_count = 0;
OutputData = [];

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutLong.flux ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.fluxOutLong.flux';
   FileNameMain = [pth 'efflux_long'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutShort.flux ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.fluxOutShort.flux';
   FileNameMain = [pth 'efflux_short'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutLong.dcdt ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.fluxOutLong.dcdt';
   FileNameMain = [pth 'dcdt_long'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutShort.dcdt ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.fluxOutShort.dcdt';
   FileNameMain = [pth 'dcdt_short'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutLong.r2 ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.fluxOutLong.r2';
   FileNameMain = [pth 'r2_long'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutShort.r2 ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.fluxOutShort.r2';
   FileNameMain = [pth 'r2_short'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutLong.se ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.fluxOutLong.se';
   FileNameMain = [pth 'se_long'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutShort.se ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.fluxOutShort.se';
   FileNameMain = [pth 'se_short'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.evOutLong.ev ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.evOutLong.ev';
   FileNameMain = [pth 'ev_long'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.evOutShort.ev ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.evOutShort.ev';
   FileNameMain = [pth 'ev_short'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutLong.wv ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.fluxOutLong.wv';
   FileNameMain = [pth 'wv_long'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutShort.initialCO2 ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.fluxOutShort.initialCO2';
   FileNameMain = [pth 'initialCO2'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutShort.wv ---

try,       
   OutputData = Stats.Chambers.Fluxes_Stats.fluxOutShort.wv';
   FileNameMain = [pth 'wv_short'];                    % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Climate_Stats.temp_air (chamber air temperature) ---

try,
   OutputData = Stats.Chambers.Climate_Stats.temp_air';
   FileNameMain = [pth 'temp_air'];                 % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Climate_Stats.temp_2cm (2 cm soil temperature) ---

try,       
   OutputData = Stats.Chambers.Climate_Stats.temp_soil';
   FileNameMain = [pth 'temp_soil'];                 % the full file name prefix
   x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Climate_Stats.vwc ---
try,       
   if isfield(Stats.Chambers.Climate_Stats,'vwc')
      OutputData = Stats.Chambers.Climate_Stats.vwc';
      FileNameMain = [pth 'vwc'];                 % the full file name prefix
      x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
   end
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Climate_Stats.ppfd ---
try,       
   if isfield(Stats.Chambers.Climate_Stats,'ppfd')
      OutputData = Stats.Chambers.Climate_Stats.ppfd';
      FileNameMain = [pth 'par'];                 % the full file name prefix
      x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
   end
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutLong.parBC (par branch chamber)---
try,       
   if isfield(Stats.Chambers.Fluxes_Stats.fluxOutLong,'parBC')
      OutputData = Stats.Chambers.Fluxes_Stats.fluxOutLong.parBC(:,7)';
      FileNameMain = [pth 'parBC'];                 % the full file name prefix
      x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
   end
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutLong.TaIns (Ta inside branch chamber)---
try,       
   if isfield(Stats.Chambers.Fluxes_Stats.fluxOutLong,'TaIns')
      OutputData = Stats.Chambers.Fluxes_Stats.fluxOutLong.TaIns(:,7)';
      FileNameMain = [pth 'Ta_insBC'];                 % the full file name prefix
      x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
   end
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Fluxes_Stats.fluxOutLong.TaOut (Ta outside branch chamber)---
try,       
   if isfield(Stats.Chambers.Fluxes_Stats.fluxOutLong,'TaOut')
      OutputData = Stats.Chambers.Fluxes_Stats.fluxOutLong.TaOut(:,7)';
      FileNameMain = [pth 'Ta_outBC'];                 % the full file name prefix
      x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
   end
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% --- Extract and save Stats.Chambers.Climate_Stats.soil_CO2_conc ---

try,       
   if isfield(Stats.Chambers.Climate_Stats,'misc')
      s = fieldnames(Stats.Chambers.Climate_Stats.misc);
      ind = find(strncmp(s,'Soil_CO2',8));
      OutputData = [];
      for i = 1:length(ind)
         eval(['OutputData(i,:) = Stats.Chambers.Climate_Stats.misc.' char(s(ind(i))) ''' ;']);
      end
      FileNameMain = [pth 'soil_CO2_conc'];                 % the full file name prefix
      x = DB_save(OutputData,Stats.Chambers.Time_vector_HH,FileNameMain);
   end
catch,
   err_count = err_count + 1;
end

if err_count > 0 
   disp(sprintf('%d errors occured!'))
end

% =================
% LOCAL FUNCTIONS
% =================

function x = file_err_chk(fid)
if fid == -1
   error 'File opening error'
end

% --- DB_matrix_to_vector ---

function OutputData = DB_matrix_to_vector(matIn)

OutputData = [];
dims = size(matIn);
if length(dims) == 3
   for i=1:dims(2)
      OutputData((i-1)*dims(1)+1:i*dims(1),:) = squeeze(matIn(:,i,:));
   end
elseif length(dims) > 3
   error 'Too many dimensions!'
end

% --- DB_covs_to_vector ---

function OutputData = DB_covs_to_vector(matIn)

[n,m,junk] = size(matIn);
if m ~= n
   error 'Matrix is not symetrical'
end
OutputData = [];
k = 0;
for i=1:m
   if i == 1
      OutputData(k+1:k+i,:) = squeeze(matIn(i,1:i,:))';
   else
      OutputData(k+1:k+i,:) = squeeze(matIn(i,1:i,:));
   end
   k = k+i;
end

% --- DB_Save ---

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
[ind1,ind2] = db_fit_in(round(100*t),round(100*TimeVector));  % find the data range (ind2) that fits    
% in the database range ind1
[n,m] = size(OutputData);
if all(diff(ind2)) == 1
   for i=1:n
      fileName = [FileNameMain num2str(i)];
      fid = fopen(fileName,'rb+');
      if fid ~= -1
         status = fseek(fid,4*(ind1(1)-1),'bof');
         if status == 0
            status = fwrite(fid,OutputData(i,ind2),'float32');  
         else                                              % store only elements with indexes = ind2
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