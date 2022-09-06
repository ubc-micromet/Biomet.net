function fileName = fr_logger_to_db_fileName(loggerIniFileName, traceName, basePath)

% (c) Zoran Nesic

%Revisions: Sept 6, 2001 - LoggerName is now optional

if traceName(1) ~= '_'
    ind = find(strcmp(upper(loggerIniFileName.TraceName),upper(traceName)));
    if isempty(ind)
        error(['Trace name does not exist: ' traceName])
    elseif length(ind) > 1
        ind = ind(1);
        disp(['Warning: Duplicate trace names: ' traceName ' in: ' char(loggerIniFileName.FileNamePrefix(ind))]);
    end
    if isfield(loggerIniFileName,'LoggerName') == 1
        fileName = fullfile(basePath,char(loggerIniFileName.LoggerName(ind)), ...
            [char(loggerIniFileName.FileNamePrefix(ind)) '.' num2str(ind)]);
    else
        fileName = fullfile(basePath, ...
            [char(loggerIniFileName.FileNamePrefix(ind)) '.' num2str(ind)]);
    end       
else
    % this is one of the special traces: _tv, _dt, _ds or such
    if isfield(loggerIniFileName,'LoggerName') == 1
        fileName = fullfile(basePath,char(loggerIniFileName.LoggerName(1)), ...
            [char(loggerIniFileName.FileNamePrefix(1)) traceName]);
    else
        fileName = fullfile(basePath, ...
            [char(loggerIniFileName.FileNamePrefix(1)) traceName]);
    end 
end
    
   