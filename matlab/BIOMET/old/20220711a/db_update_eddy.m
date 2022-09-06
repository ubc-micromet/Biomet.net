function OutputData = db_update_eddy(stats,pth)
%
%
% (c) Zoran Nesic           File created:       May 11, 1998
%                           Last modification:  Jan 18, 2000
%

%
% Revisions:
% Jan 18, 2000
%   - added checks for out of bound data (if the data TimeVector
%     is pointing outside of the scope of this data base).
%   May 11, 1998
%       -   

pth_out = fr_valid_path_name(pth);          % check the path and create
if isempty(pth_out)                         
    error 'Directory does not exist!'
else
    pth = pth_out;
end
err_count = 0;
OutputData = [];
%
% Extract and save AvgMinMax values before rotation
%
try,
    OutputData = DB_matrix_to_vector(stats.BeforeRot.AvgMinMax);
    FileNameMain = [pth 'avgbr'];               % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
catch,
    err_count = err_count + 1;
end
%
% Extract and save AvgMinMax values after rotation
%
try
    OutputData = DB_matrix_to_vector(stats.AfterRot.AvgMinMax);
    FileNameMain = [pth 'avgar'];               % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save AvgMinMax values RawData.Counts
%
try
    OutputData = DB_matrix_to_vector(stats.RawData.AvgMinMax.Counts);
    FileNameMain = [pth 'avgrc'];               % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save AvgMinMax values RawData.Voltages
%
try
    OutputData = DB_matrix_to_vector(stats.RawData.AvgMinMax.Voltages);
    FileNameMain = [pth 'avgrv'];               % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save BeforeRot.Cov.LinDtr
%
try
    OutputData = DB_covs_to_vector(stats.BeforeRot.Cov.LinDtr);
    FileNameMain = [pth 'covbl'];               % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save BeforeRot.Cov.AvgDtr
%
try
    OutputData = DB_covs_to_vector(stats.BeforeRot.Cov.AvgDtr);
    FileNameMain = [pth 'covba'];               % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save AfterRot.Cov.LinDtr
%
try
    OutputData = DB_covs_to_vector(stats.AfterRot.Cov.LinDtr);
    FileNameMain = [pth 'coval'];               % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save AfterRot.Cov.AvgDtr
%
try
    OutputData = DB_covs_to_vector(stats.AfterRot.Cov.AvgDtr);
    FileNameMain = [pth 'covaa'];               % the full file name prefix
    x = DB_save(OutputData,stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save Misc
%
try
    FileNameMain = [pth 'misc'];               % the full file name prefix
    x = DB_save(stats.Misc',stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save Fluxes.LinDtr
%
try
    FileNameMain = [pth 'flxld'];               % the full file name prefix
    x = DB_save(stats.Fluxes.LinDtr',stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save Fluxes.AvgDtr
%
try
    FileNameMain = [pth 'flxad'];               % the full file name prefix
    x = DB_save(stats.Fluxes.AvgDtr',stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save Angles
%
try
    FileNameMain = [pth 'angle'];               % the full file name prefix
    x = DB_save(stats.Angles',stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
if err_count > 0 
    disp(sprintf('%d errors occured!'))
end
%===============================================================
% LOCAL FUNCTIONS
%===============================================================
function x = file_err_chk(fid)
    if fid == -1
        error 'File opening error'
    end


%----------------------------------------------------------------
% DB_matrix_to_vector
%
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

%----------------------------------------------------------------
% DB_covs_to_vector
%
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