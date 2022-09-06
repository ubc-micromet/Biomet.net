function db_update_TF_Radiation_met(yearIn)
% Totem Field Radiation data Processing 
%
% user can input yearIn
%
%                                       file created:  Oct 26, 2020        
%                                       last modified: Oct 26, 2020
%

% function based on db_update_YF_met

% Revisions:
%
%


dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sites',{'UBC_Totem'});
Site = 'UBC_Totem';
% Add file renaming + copying to \\paoa001
pth_db = db_pth_root; %#ok<NASGU>

for k=1:length(yearIn)

        % Progress list for TF (CR1000) logger
        strForEval = ['progressList_UBC_Totem_Radiation_30min_Pth = fullfile(pth_db,'''...
            'UBC_Totem_TF_Radiation_progressList_' num2str(yearIn(k)) '.mat'');'];
        eval(strForEval);
        
        % Climate database path
        strForEval = ['UBC_Totem_ClimateDatabase_Pth = [pth_db ''yyyy\UBC_Totem\Radiation\''];'];
        eval(strForEval);
        
        % Process TF CR1000  logger
        strForEval = ['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\UBC' ...
            '\CSI_net\Totem_Radiometer_Data\CR1000_TF_Radiation_MET.' num2str(yearIn(k)) '*'',[],[],[],progressList_UBC_Totem_Radiation_30min_Pth' ...
            ',UBC_Totem_ClimateDatabase_Pth,2,0,10);'];
        eval(strForEval);     
        strForEval = ['disp(sprintf(''' Site ...
            ' CR1000_TF_Radiation_MET:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))'];
        eval(strForEval);
                    
end %k
