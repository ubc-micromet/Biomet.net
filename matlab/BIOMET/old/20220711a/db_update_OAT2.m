function db_update_OAT2(yearIn,sites);

% renames FR_Clearcut files, moves them from CSI_NET\old on PAOA001 to
% CSI_NET\old\yyyy, updates the annex001 database

% user can input yearIn, sites (cellstr array containing site suffixes)
% use do_eddy = 1, to turn on dbase updates using calculated daily flux
% files

% file created: May 6, 2011        last modified: May 6, 2011
% (c) Nick Grant

% function based on db_update_hp_sites for HDF11 CR1000 climate data
% could be updated in the future if open path run at HDF11 with
% CR1000/3000/5000 data acquisition.

% revisions:
%

dv=datevec(now);
arg_default('yearIn',dv(1));
%arg_default('sites',{'09'});

% Add file renaming + copying to \\paoa001
pth_db = db_pth_root;

fileExt = datestr(now,30);
fileExt = fileExt(1:8);

for k=1:length(yearIn)
    for j=1:length(sites)
        siteId = char(sites{j});
        switch upper(siteId)
            case {'PA'}
                siteName = 'PAOA';
        end
        eval(['progressList_' siteId '_TDR_30min_Pth = fullfile(pth_db,''' siteId...
            '_TDR_30min_progressList_' num2str(yearIn(k)) '.mat'');']);
        
        eval([siteId '_TDR_30min_Pth = [pth_db ''\yyyy\' siteId...
             '\Climate\OAT2''];']);
         
        eval(['progressList_' siteId '_PitTempC_Pth = fullfile(pth_db,''' siteId...
            '_PitTempC_progressList_' num2str(yearIn(k)) '.mat'');']);
        
        eval([siteId '_PitTempC_Pth = [pth_db ''\yyyy\' siteId...
             '\Climate\OAT2''];']);
        

       filePath = sprintf('d:\\sites\\%s\\CSI_net\\old\\',siteName);
       %filePath = sprintf('D:\\Nick_Share\\tmp_nick\\sites_tst\\%s\\CSI_net\\old\\',siteId); % for testing on Nick's PC

        
        % move .DAT files from /old  to  old/yyyy  ;
        datFiles = dir(fullfile(filePath,'OAT2_TDR_data_30min.*'));
        for i=1:length(datFiles)
            sourceFile      = fullfile(filePath,datFiles(i).name);
            destinationFile1 = fullfile(fullfile(filePath,num2str(yearIn(k))),datFiles(i).name);
            [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
            if Status1 ~= 1
                uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
            end %if
        end %i

        datFiles = dir(fullfile(filePath,'OAT2_M_PitTempC.*'));
        for i=1:length(datFiles)
            sourceFile      = fullfile(filePath,datFiles(i).name);
            destinationFile1 = fullfile(fullfile(filePath,num2str(yearIn(k))),datFiles(i).name);
            [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
            if Status1 ~= 1
                uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
            end %if
        end %i
        
        %for testing on Nick's PC
         eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\Sites\' siteName '\CSI_net\old\' num2str(yearIn(k)) '\' 'OAT2_TDR_data_30min.' num2str(yearIn(k)) '*'',[],[],[],progressList_' siteId '_TDR_30min_Pth,' siteId '_TDR_30min_Pth,2);'])
         eval(['disp(sprintf(' '''' siteId ' TDR_30min:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
%         
         eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\Sites\' siteName '\CSI_net\old\' num2str(yearIn(k)) '\' 'OAT2_M_PitTempC.' num2str(yearIn(k)) '*'',[],[],[],progressList_' siteId '_PitTempC_Pth,' siteId '_PitTempC_Pth,2);'])
         eval(['disp(sprintf(' '''' siteId ' PitTempC_30min:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
%         

% %         

    end %j
end %k
