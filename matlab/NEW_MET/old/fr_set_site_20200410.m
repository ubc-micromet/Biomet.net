function x = fr_set_site(SiteID,Locality)
%
% This function copies all matlab ini files needed to run UBC site programs
% into c:\UBC_PC_Setup\Site_Specific. The original file location can be:
%
%       c:\UBC_PC_Setup\Site_Specific\xx   where xx stands for the site ID (CR, PA, BS...)
%
%   or
%
%       \\paoa001\Sites\xxxx\UBC_PC_Setup\Site_Specific where xxxx stands for 4-letter site ID (CR, PAOA, PAOB...)
%       The network location contains the most current site setup files.
%
% Locality:
%   LOCAL   - use setup files from the local hard disk (c:\UBC_PC_Setup\Site_Specific\CR
%                                                                                  \PA
%                                                                                  \BS ...
%   NETWORK - use setup files from the network location(\\paoa001\Sites\xxxx\UBC_PC_Setup\Site_Specific)
%
% (c) Zoran Nesic           File created:             ,2001
%                           Last modification:  Dec 19, 2007

% Revisions
% 
% Jan 26, 2017 (Zoran)
%	- replaced hard coded path to HFREQ data by using the default path: db_HFREQ_root
% Dec 19, 2007
%   -removed switch statement (site specific cases)when assigning HFREQ
%   datapath (Nick
% Mar 16, 2005
%   - Changed NETWORK usage to point to \\paoa001\Sites\xxxx\UBC_PC_Setup\Site_Specific
% May 16, 2003
%   - Changed handling of file structure created by:     fileStruct = dir(fileNameIN);
%     Different versions of matlab treated differently the single file case (N1 =1). The fix works
%     for all versions:
%        er = my_copyfile(fileNameIN, fullfile(destinationPth,fileName));
%                       ^^^^^^^^^^^^^^
% Sep 27, 2001
%   - made it possible to add sites without editing of this function
%     (otherwise, longName = SiteID;...)
%


destinationPth = 'c:\UBC_PC_Setup\Site_Specific\';
networkPth = '\\PAOA001\Sites\';
filesToCopy = str2mat('fr_current_siteID.m');

commentX = [10 10 '%This file is generated by fr_set_site.m' 10 ...
                   '%Please do not edit - use fr_set_site instead!' 10 10];

Locality = upper(Locality);
if strcmp(Locality,'N')
    Locality = 'NETWORK';
elseif strcmp(Locality,'L')
    Locality = 'LOCAL';
end
SiteID = upper(SiteID);


dos(['attrib -r ' destinationPth '*.m']);        % remove read-only attributes
delete([destinationPth '*.m']);

switch SiteID
    case 'CR'
        longName = 'CR';
        filesToCopy = str2mat(filesToCopy,'*.m');         % copy all user m-files 
%        filesToCopy = str2mat(filesToCopy,'fr_init_all.m');
    case 'PA'
        longName = 'PAOA';
        filesToCopy = str2mat(filesToCopy,'*.m');         % copy all user m-files 
%        filesToCopy = str2mat(filesToCopy,'pa_init_all.m');
    case 'BS'
        longName = 'PAOB';
        filesToCopy = str2mat(filesToCopy,'*.m');         % copy all user m-files 
%        filesToCopy = str2mat(filesToCopy,'bs_init_all.m');
    case 'JP'
        longName = 'PAOJ';
        filesToCopy = str2mat(filesToCopy,'*.m');         % copy all user m-files 
%        filesToCopy = str2mat(filesToCopy,'jp_init_all.m');
    otherwise,
        longName = SiteID;
        filesToCopy = str2mat(filesToCopy,'*.m');         % copy all user m-files 
end


switch Locality
    case 'LOCAL'
        mainPth = fullfile(destinationPth,SiteID, '\');
%        filesToCopy = str2mat(filesToCopy,'fr_get_local_path.m');
    case 'NETWORK'
        mainPth = fullfile(networkPth,longName,'\UBC_PC_Setup\Site_Specific\');
    otherwise
        error 'Wrong Locality!'
end



% the following is needed to avoid problems
% with copyfile when current folder
% is not on a local disk
oldPth = pwd;
cd c:\                                              

% create fr_current_siteID and make it read-only (or not?)
% 
fid = fopen([destinationPth 'fr_current_SiteID.m'],'wt');
if fid > 0
    fprintf(fid,'%s\n','function SiteID = fr_current_SiteID()');
    fprintf(fid,'%s\n',commentX);
    fprintf(fid,'SiteID  = %s%s%s;\n',char(39),SiteID,char(39));
    fclose(fid);
%    dos(['attrib +r ' destinationPth 'fr_current_SiteID.m']);   %make the file read-only
end


N = size(filesToCopy,1);
for i=1:N
    fileName = deblank(filesToCopy(i,:));
    fileNameIN = fullfile(mainPth,fileName);
    fileStruct = dir(fileNameIN);
    N1 = size(fileStruct,1);
    if N1 > 1
        for j = 1:N1
            er = my_copyfile(fullfile(mainPth,fileStruct(j).name), fullfile(destinationPth,fileStruct(j).name));
            if er ~= 1 
                error(['File: ' fullfile(mainPth,fileStruct(j).name) ' could not be copied to: ' fullfile(destinationPth,fileStruct(j).name)])
            end
        end
    elseif N1 == 1
        er = my_copyfile(fileNameIN, fullfile(destinationPth,fileName));
        if er ~= 1 
            error(['File: ' fileStruct.name ' could not be copied to: ' fullfile(destinationPth,fileName)])
        end
    else
        
    end
end

% if on the network overwrite fr_get_local_path
if strcmp(Locality,'NETWORK') | exist([destinationPth 'fr_get_local_path.m']) ~=2
   fid = fopen([destinationPth 'fr_get_local_path.m'],'wt');
   if fid > 0
      fprintf(fid,'%s\n','function [dataPth,hhourPth,databasePth,csi_netPth] = FR_get_local_path');
      fprintf(fid,'%s\n',commentX);
%       switch upper(SiteID)
%       case {'CR','HJP02','HJP75','OY','PA','YF','BS'}
%          fprintf(fid,'dataPth  = %s%s%s;\n',char(39),['\\BIOMET01\HFREQ_' upper(SiteID) '\met-data\data\'],char(39));
%       otherwise
%          fprintf(fid,'dataPth  = %s%s%s;\n',char(39),['\\ANNEX001\HFREQ_' upper(SiteID) '\met-data\data\'],char(39));
%       end
      % Dec 19, 2007: removed switch statement when building paths
      fprintf(fid,'dataPth  = %s%s%s;\n',char(39),[db_HFREQ_root 'HFREQ_' upper(SiteID) '\met-data\data\'],char(39));
      fprintf(fid,'hhourPth  = %s%s%s;\n',char(39),fullfile(networkPth,longName,'\hhour\') ,char(39));
      fprintf(fid,'databasePth  = %s%s%s;\n',char(39),'\\ANNEX001\Database\',char(39));
      fprintf(fid,'csi_netPth  = %s%s%s;\n',char(39),'[]',char(39));
      fclose(fid);
   end
end

dos(['attrib +r ' destinationPth '*.m']);   %make files read-only
cd(oldPth)                                  % go back to old path



function er = my_copyfile(inFile,outFile)
    er = 1;
    try
        fid = fopen(inFile,'rb');
        if fid < 0 
            error(['Cannot open: ' inFile]);
        end
        dataIn = fread(fid,[1, Inf],'uchar');
        fclose(fid);
        fid = fopen(outFile,'wb');
        if fid < 0 
            error(['Cannot open: ' outFile]);
        end
        fwrite(fid,dataIn,'uchar');
        fclose(fid);
    catch
        er = -1;
    end