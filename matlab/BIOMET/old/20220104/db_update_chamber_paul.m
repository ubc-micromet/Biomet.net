function OutputData = db_update_chamber_paul(stats,pth)
%
% based on db_create_eddy   File created:       Sep 15, 2003
%                           Last modification:  Sep 15, 2003

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

Chambers = stats.Chambers;
%
% Extract and save 
%
file_names = {'co2_after','co2_before','stdCO2','r2','dcdt','delta_dcdt','flux','delta_flux','temp1','temp2','tair','pbar'};

for i = 1:length(file_names)
   try,
      eval(['OutputData = Chambers.' char(file_names(i)) ';']);
      FileNameMain = [pth char(file_names(i))];               % the full file name prefix
      x = DB_save(OutputData',Chambers.TimeVector,FileNameMain);
   catch,
      err_count = err_count + 1;
   end
end

return

%===============================================================
% LOCAL FUNCTIONS
%===============================================================

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