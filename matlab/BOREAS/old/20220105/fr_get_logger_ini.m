function ini = fr_get_logger_ini(SiteID,YearX,loggerName,baseFileName,msmtType);

if ~exist('msmtType') | isempty(msmtType);
    msmtType = 'cl';
end

pth = biomet_path(YearX,SiteID,msmtType);
iniFileName = fullfile(pth,loggerName,[baseFileName '.ini']);
[ini.TraceNum, ini.TraceName,...
 ini.FileNamePrefix, ini.LoggerName]=textread(iniFileName,'%d %s %s %s');