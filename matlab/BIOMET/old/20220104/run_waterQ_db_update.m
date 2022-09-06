function run_waterQ_db_update(year);

% runs db update for Mark Johnson's WaterQ loggers; two runs are required,
% one for hhourly and one for 10min averaged data

% (c) Nick Grant             file created:  Aug 13, 2009
%                            last modified: Aug 13, 2009                     
% Revisions:
%

dv = datevec(now);

arg_default('year',dv(1));

pth_db = db_pth_root;

% waterQ_database_10min_Pth = fullfile(pth_db,num2str(year),'\CR\Climate\waterQ\10min');
% waterQ_database_30min_Pth = fullfile(pth_db,num2str(year),'\CR\Climate\waterQ\30min');

waterQ_database_10min_Pth = fullfile(pth_db,'yyyy','\CR\Climate\waterQ\10min');
waterQ_database_30min_Pth = fullfile(pth_db,'yyyy','\CR\Climate\waterQ\30min');

% progressList_waterQ_10min_Pth = fullfile(waterQ_database_10min_Pth,'waterQ_10min_progressList.mat');
% progressList_waterQ_30min_Pth = fullfile(waterQ_database_30min_Pth,'waterQ_30min_progressList.mat');

progressList_waterQ_10min_Pth = fullfile(pth_db,num2str(year),'\CR\Climate\waterQ\10min','waterQ_10min_progressList.mat');
progressList_waterQ_30min_Pth = fullfile(pth_db,num2str(year),'\CR\Climate\waterQ\30min','waterQ_30min_progressList.mat');

pth_csinet = '\\PAOA001\Sites\CR\CSI_NET\old\';

fn_10min   = ['WaterQ_Data_10m.' num2str(year) '*'];
fn_30min   = ['WaterQ_Data_30m.' num2str(year) '*'];

[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(fullfile(pth_csinet,fn_10min),[],[],[],progressList_waterQ_10min_Pth,waterQ_database_10min_Pth,2,[],10);
disp(sprintf('CR waterQ 10min:  Number of files processed = %d, Number of 10min = %d',numOfFilesProcessed,numOfDataPointsProcessed))

[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(fullfile(pth_csinet,fn_30min),[],[],[],progressList_waterQ_30min_Pth,waterQ_database_30min_Pth,2,[],30);
disp(sprintf('CR waterQ 30min:  Number of files processed = %d, Number of HHours = %d',numOfFilesProcessed,numOfDataPointsProcessed))
