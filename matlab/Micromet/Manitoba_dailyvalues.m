function Manitoba_dailyvalues(siteNames,outputPath)

% Manitoba_dailyvalues
%
% Nick Lee              File created:       Jun 23, 2021
%                       Last modification:  Jun 23, 2021
%
% This file is intended to create csv files to export mean daily values
% for the Manitoba sites

% Revisions (latest first):


arg_default('siteNames',{'Hogg','Young'});
arg_default('outputPath','P:\Micromet_web\www\webdata\resources\csv\');

fprintf('*** Started processing at %s\n',datetime(datestr(now)))
for siteNum = 1:length(siteNames)
    siteID = char(siteNames(siteNum));
    %% Define path & csv output path, current time, and date range
    pth = biomet_path('yyyy',siteID);
    
    % Current time & year
    c = clock;
    Year_now = c(1);
    
    % Define date range (i.e. years of interest)
    switch siteID
        case 'Hogg'
            Years = 2021:Year_now;
        case 'Young'
            Years = 2021:Year_now;
        otherwise
            error('Wrong site name!')
    end
    
    %% Load time vector
    var = 'clean_tv';
    tv=read_bor(fullfile(pth,'FLUX',var),8,[],Years);
    %tv = year_append(Years,'BB','Met',var,pth,8);
    
    % Define start and end indices for web plots
%     inde = find(datetime(datestr(tv)) == dateshift(datetime(c),'start','hour'));
%     if strcmp(siteID,'BB2')
%         inds = find(datetime(datestr(tv)) == datetime(2019,11,13));
%     end
    
    formatOut = 'yyyy-mm-dd'; %'yyyy-mm-dd HH:MM:SS'
    tvx = tv(1:48:end);
    tv_export = datestr(tvx,formatOut);
    
    
    %% Load data and calculate daily averages
    Fco2 = read_bor(fullfile(pth,'FLUX','co2_flux'),[],[],Years);
    co2 = read_bor(fullfile(pth,'FLUX','co2_mixing_ratio'),[],[],Years);
    Fch4 = read_bor(fullfile(pth,'FLUX','ch4_flux'),[],[],Years);
    Taraw = read_bor(fullfile(pth,'FLUX','TA_1_1_1'),[],[],Years);
    Hraw = read_bor(fullfile(pth,'FLUX','H'),[],[],Years);
    LEraw = read_bor(fullfile(pth,'FLUX','LE'),[],[],Years);
    
    Fco2a = runmean(Fco2,48,48);
    co2a = runmean(co2,48,48);
    Fch4a = runmean(Fch4,48,48);
    Taa = runmean(Taraw,48,48);
    Haa = runmean(Hraw,48,48);
    LEa = runmean(LEraw,48,48);
    
    data = [Fco2a, co2a, Fch4a, Taa, Haa, LEa];
    cHeader = {'Time' 'CO2 flux' 'CO2 mixing ratio' 'CH4 flux' 'Air temperature' ...
               'Sensible heat' 'Sensible heat'}; % Include BB2 variable here
    cFormat = '%12.6f, %12.6f, %12.6f, %12.6f, %12.6f, %12.6f\n';
    fileName = [siteID '_DailyAvg.csv'];
    csv_save(cHeader,outputPath,fileName,cellstr(tv_export),cFormat,data)
    
    
end

end