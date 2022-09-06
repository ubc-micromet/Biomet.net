function fr_set_recalc(SiteId)
% FR_SET_RECALC Condition site specific functions for recalc
%
%   X = FR_SET_RECALC First carries out FR_SET_SITE(SITEID,'NETWORK')
%   to ensure that the ini-file is the newest avaialable. Then it
%   copies the FR_GET_CURRENT_SITEID_PATH and then the PAOA001\SITES
%   calibration files into the hhour directory from that function.
%   Finally it will overwrite these ini and cal files with those in 
%   CURRENT_RECALC

% kai* Dec 1, 2003

% The following is needed to avoid problems with copyfile 
% when current folder is not on a local disk
oldPth = pwd; 
cd c:\;

destinationPth   = 'c:\UBC_PC_Setup\Site_Specific\';
current_recalcPth = '\\annex002\kai\matlab\Current_Recalc\';

%---------------------------------------------------------------------
% Copy network setup for ini-file and get network path
fr_set_site(SiteId,'n')
dos(['attrib -r ' destinationPth '*.m']);   
eval('[dataPth_net,hhourPth_net,databasePth_net] = FR_get_local_path;');

%---------------------------------------------------------------------
% Copy fr_get_current_siteid_path to fr_get_local_path and get local path
% my_copyfile(fullfile(current_recalcPth,'FR_get_current_siteid_path.m'),...
%    fullfile(destinationPth,'FR_get_local_path.m'));
dos(['copy ' fullfile(current_recalcPth,'FR_get_current_siteid_path.m') ' ' ...
   fullfile(destinationPth,'FR_get_local_path.m')]);

% Use eval here to get path updated and new function used
% [dataPth,hhourPth,databasePth] = feval('FR_get_local_path');
path(path)
eval('[dataPth,hhourPth,databasePth] = FR_get_local_path;');
%---------------------------------------------------------------------
% Copy net cal files and then overwrite with current calibration files
lst_ini_net = dir([hhourPth_net '*_init_all.m']);
lst_cal_net = dir([hhourPth_net      'calibrations.*']);
lst_ini_cur = dir([current_recalcPth '*_init_all.m']);
lst_cal_cur = dir([current_recalcPth 'calibrations.*']);

for i = 1:length(lst_ini_net)
   my_copyfile(fullfile(current_recalcPth,lst_ini_net(i).name),...
      fullfile(destinationPth,lst_ini_net(i).name));
end   

for i = 1:length(lst_cal_net)
   my_copyfile(fullfile(hhourPth_net,lst_cal_net(i).name),...
      fullfile(hhourPth,lst_cal_net(i).name));
end   

for i = 1:length(lst_ini_cur)
   my_copyfile(fullfile(current_recalcPth,lst_ini_cur(i).name),...
      fullfile(destinationPth,lst_ini_cur(i).name));
end   

for i = 1:length(lst_cal_cur)
   my_copyfile(fullfile(current_recalcPth,lst_cal_cur(i).name),...
      fullfile(hhourPth,lst_cal_cur(i).name));
end   

%---------------------------------------------------------------------
%make files read-only
dos(['attrib +r ' destinationPth '*.m']);   

% Go back to old current dir
cd(oldPth)       

return

function er = my_copyfile(inFile,outFile)
er = 1;
try
   fid_in = fopen(inFile,'rb');
   if exist('fid_in') & fid_in < 0 
	   er = -1;
      disp(['Cannot read from: ' inFile]);
   end
   dataIn = fread(fid_in,[1, Inf],'uchar');
   fclose(fid_in);
   fid_out = fopen(outFile,'wb');
   if exist('fid_out') & fid_out < 0 
      er = -1;
	   disp(['Cannot write to: ' outFile]);
   end
   fwrite(fid_out,dataIn,'uchar');
   fclose(fid_out);
   disp(['Copied ' inFile]);
end

