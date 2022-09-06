function OutputData = db_update_oy_eddy(stats,pth)
%
%
% (c) E Humphreys           File created:       Oct 2001
%                           Last modification:  Sept 7, 2003
%

%
% Revisions: Sept 7, 2003 - removed flags, no longer used in cleaning 

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
    OutputData = stats.statsbr.means;
    tmp = stats.statsbr.min;   OutputData = [OutputData tmp]; clear tmp
    tmp = stats.statsbr.max;   OutputData = [OutputData tmp]; clear tmp
    tmp = stats.statsbr.std;   OutputData = [OutputData tmp]; clear tmp
    tmp = stats.statsbr.const; OutputData = [OutputData tmp]; clear tmp
    tmp = stats.statsbr.Pbar;  OutputData = [OutputData tmp]; clear tmp
    
    FileNameMain = [pth 'avgbr'];               % the full file name prefix
    x = DB_save(OutputData',stats.TimeVector,FileNameMain);
catch,
    err_count = err_count + 1;
end
%
% Extract and save AvgMinMax values after rotation
%
try
    OutputData =  stats.statsar.means;
    tmp =  stats.statsar.min;   OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsar.max;   OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsar.std;   OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsar.const; OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsar.Pbar;  OutputData = [OutputData tmp]; clear tmp

    FileNameMain = [pth 'avgar'];               % the full file name prefix
    x = DB_save(OutputData',stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save AvgMinMax values RawData.Counts
%
try
    OutputData =  stats.statsRaw.means;
    tmp =  stats.statsRaw.min;   OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsRaw.max;   OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsRaw.var;   OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsRaw.const; OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsRaw.Pbar;  OutputData = [OutputData tmp]; clear tmp

    FileNameMain = [pth 'avgrv'];               % the full file name prefix
    x = DB_save(OutputData',stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end

%
% Extract and save BeforeRot.Cov.AvgDtr
%
try
    OutputData =  stats.statsbr.var;
    tmp =  stats.statsbr.covs;     OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsbr.scalcovsu;OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsbr.scalcovsv;OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsbr.scalcovsw;OutputData = [OutputData tmp]; clear tmp

    FileNameMain = [pth 'covba'];               % the full file name prefix
    x = DB_save(OutputData',stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end

%
% Extract and save AfterRot.Cov.AvgDtr
%
try
    OutputData =  stats.statsar.var;
    tmp =  stats.statsar.covs;     OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsar.scalcovsu;OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsar.scalcovsv;OutputData = [OutputData tmp]; clear tmp
    tmp =  stats.statsar.scalcovsw;OutputData = [OutputData tmp]; clear tmp

    FileNameMain = [pth 'covaa'];               % the full file name prefix
    x = DB_save(OutputData',stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end

%
% Extract and save Fluxes.AfterRot.AvgDtr
%
try
    FileNameMain = [pth 'flxaad'];               % the full file name prefix
    x = DB_save(stats.statsar.fluxes',stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end
%
% Extract and save Fluxes.BeforeRot.AvgDtr
%
try
    FileNameMain = [pth 'flxbad'];               % the full file name prefix
    x = DB_save(stats.statsbr.fluxes',stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end

%
% Extract and save Misc
%
try
    FileNameMain = [pth 'misc'];               % the full file name prefix
    x = DB_save(stats.statsDiag',stats.TimeVector,FileNameMain);
catch
    err_count = err_count + 1;
end


%-------------------------------------------------------
% introduce diagnostic flags
% based on get_flags(SiteID,years,pthout);

x = datevec(stats.TimeVector(end-100));
years = x(1);

%pth_in = biomet_path(years,'OY','fl');  % replaced with the line below by Zoran Jan 29, 2003
pth_in = pth;


  
  ini.avgar = fr_get_logger_ini('oy',years,[],'oy_avgar','fl');   % main flux-stats array
  ini.avgar = rmfield(ini.avgar,'LoggerName');
  ini.avgbr = fr_get_logger_ini('oy',years,[],'oy_avgbr','fl');   % main flux-stats array
  ini.avgbr = rmfield(ini.avgbr,'LoggerName');
  ini.covaa = fr_get_logger_ini('oy',years,[],'oy_covaa','fl');   % main flux-stats array
  ini.covaa = rmfield(ini.covaa,'LoggerName');
  ini.covba = fr_get_logger_ini('oy',years,[],'oy_covba','fl');   % main flux-stats array
  ini.covba = rmfield(ini.covba,'LoggerName');
    
%[sonic_flag] = get_sonic_flag(pth_in,years,[],ini);
%[irga_flag] = get_irga_flag(pth_in,years,[],ini);
%[stationarity_flag] = get_stationarity_flag(pth_in,years,[],ini);

%save_bor([pth_in 'misc.sonic_flag1'],1,sonic_flag);
%save_bor([pth_in 'misc.irga_flag1'],1,irga_flag);
%save_bor([pth_in 'misc.stationarity_flag1'],1,stationarity_flag);



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