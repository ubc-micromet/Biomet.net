function run_ECCC_climate_station_update(yearsIn,monthsIn,stationIDs)
% run_ECCC_climate_station_update(yearsIn,monthsIn,stationIDs)
%
% Process ECCC climate station data. 
%
% yearsIn   - range of years to process (default current year)
% monthsIn  - range of months to process (default previous and the current
%             month.
% stationIDs    - a vector of station IDs. They can be found here:
%                 https://drive.google.com/drive/folders/1WJCDEU34c60IfOnG4rv5EPZ4IhhW9vZH
%                 File: "Station Inventory EN.csv"
%
% Zoran Nesic                   File created:               2022
%                               Last modification:  Oct 19, 2022

% Revisions
%
% Oct 19, 2022 (Zoran)
%  - Added a generic option to create a station under yyyy\ECCC\stationID
%    for all new stations except BB (49088) and Hogg (10927)
% Sep 7, 2022 (Zoran)
%  - added input option for stationIDs
%  - added calls for Manitoba station

[yearNow,monthNow,~]= datevec(now);
monthRange = monthNow-1:monthNow;
arg_default('yearsIn',yearNow)
arg_default('monthsIn',monthRange)
arg_default('stationIDs',49088)

for cntStations = 1:length(stationIDs)
    sID = stationIDs(cntStations);
    switch sID
        case 49088
            % Burns Bog station
            pathECCC = 'yyyy\BB\Met\ECCC';
        case 10927
            % Hogg station
            pathECCC = 'yyyy\Hogg\Met\ECCC';
        otherwise
            % Group all other stations under \ECCC\stationID
            pathECCC = fullfile('yyyy','ECCC',num2str(sID));
%         otherwise
%             fprintf('station ID out of range!\n');     
%             pathECCC = '';
    end
    if ~isempty(pathECCC)
        try
            db_ECCC_climate_station(yearsIn,monthsIn,sID,...
                                    fullfile(biomet_database_default,pathECCC),60);
        catch
        end
    end
end