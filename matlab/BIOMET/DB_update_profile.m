function OutputData = DB_update_profile(stats,pth)
% Function that is called by DB_main_update_profile and update profile database
%
% syntax : OutputData = db_update_profile(stats,pth)
%
% Created by David Gaumont-Guay 2001.06.08
% Revisions: none

pth_out = fr_valid_path_name(pth);                  % check the path and create
if isempty(pth_out)                         
    error 'Directory does not exist!'
else
    pth = pth_out;
end
err_count = 0;
OutputData = [];

% --- Extract and save stats.Profile.co2.Avg ---

try,
       
    OutputData = stats.Profile.co2.Avg';
    FileNameMain = [pth 'co2_avg'];                 % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
catch,
    err_count = err_count + 1;
end

if err_count > 0 
    disp(sprintf('%d errors occured!'))
end

% --- Extract and save prOut.h2o.avg ---

try,
       
    OutputData = stats.Profile.h2o.Avg';
    FileNameMain = [pth 'h2o_avg'];                 % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
catch,
    err_count = err_count + 1;
end

if err_count > 0 
    disp(sprintf('%d errors occured!'))
end

% --- Extract and save Tbench.h2o.avg ---

try,
       
    OutputData = stats.Profile.Tbench.Avg';
    FileNameMain = [pth 'Tbench_avg'];                 % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
catch,
    err_count = err_count + 1;
end

if err_count > 0 
    disp(sprintf('%d errors occured!'))
end

% --- Extract and save Plicor.h2o.avg ---

try,
       
    OutputData = stats.Profile.Plicor.Avg';
    FileNameMain = [pth 'Plicor_avg'];                 % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
catch,
    err_count = err_count + 1;
end

if err_count > 0 
    disp(sprintf('%d errors occured!'))
end

% --- Extract and save Pgauge.h2o.avg ---

try,
       
    OutputData = stats.Profile.Pgauge.Avg';
    FileNameMain = [pth 'Pgauge_avg'];                 % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
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
    error 'Matix is not symetrical'
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