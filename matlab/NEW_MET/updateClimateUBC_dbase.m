function updateClimateUBC_dbase
% Process all climate station data and store it in climateData.mat file
%
% Zoran Nesic                   File created:              2010
%                               Last modification: Dec 10, 2020

% Revisions
%
% Dec 10, 2020 (Zoran)
%   - climateData.mat now goes to: D:\Sites\ubc\ClimateUBC

try
    fprintf('Started: %s\n',mfilename);
    climateData = ClimateUBC_LoadAll;
    save D:\Sites\ubc\ClimateUBC\climateData climateData
catch
    fprintf('*** Error in: %s ***\n',mfilename);
end
fprintf('Finished: %s\n',mfilename);

    