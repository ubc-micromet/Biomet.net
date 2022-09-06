function check_sites(SiteId)

if strcmp(fr_get_pc_name,'PAOA001')
    addpath C:\BIOMET.NET\MATLAB\TRACEANALYSIS_FIRSTSTAGE;
    addpath C:\BIOMET.NET\MATLAB\TRACEANALYSIS_SECONDSTAGE;
    addpath C:\BIOMET.NET\MATLAB\TRACEANALYSIS_TOOLS;
end

if strcmp(upper(SiteId),'PAUL')
    SiteId = 'CR';
    pth = biomet_path('Calculation_Procedures\TraceAnalysis_ini',SiteId);
    file_name = fullfile(pth,[SiteId '_chambers.ini']);
    yy = datevec(now);
    ta_firststage(yy(1),'cr',file_name,[]);
else
    pth = biomet_path('Calculation_Procedures\TraceAnalysis_ini',SiteId);
    file_name = fullfile(pth,[SiteId '_SiteStatus.ini']);
    yy = datevec(now);
    ta_firststage(yy(1),'cr',file_name,[]);
end


if strcmp(fr_get_pc_name,'PAOA001')
    rmpath C:\BIOMET.NET\MATLAB\TRACEANALYSIS_FIRSTSTAGE;
    rmpath C:\BIOMET.NET\MATLAB\TRACEANALYSIS_SECONDSTAGE;
    rmpath C:\BIOMET.NET\MATLAB\TRACEANALYSIS_TOOLS;
end
