function [CSI_netOK] = testCSI_net (sites)
% testCsi_net: CSI_net file status on \\PAOA001
%
%   Input: sites[], string vector with the acronym of each site
%           eg. sites=['CR   '; 'OY   '; 'YF   '; 'PAOA '; 'PAOB '; 'HJP02'; 'HJP75'; 'PAOJ ']
%   Output: CSI_netOK[], numeric vector with binary data showing the
%   presence or absence of the site CSI_net files.
%
%               1 - ALL files are present
%               2 - at LEAST one of the files is missing. Each has multiple
%               files in the CSI_net folder so the flag is set to 0 if one
%               or more are missing
%
%           eg. CSI_netOK=[1 1 1 1 1 0 1 1]
%               would show all CSI_net files for each site are present but
%               at least one of the CSI_net files for HJP02 is absent

CScurrentDOY = num2str(floor(fr_get_DOY(datenum(now), 0))); %Campbell Scientif DOY
currentDOY = num2str(floor(fr_get_DOY(datenum(now), 1))); %normal DOY
currentYear = datestr(datenum(now),'yyyy'); %current year eg. 2004

CSI_netOK(1:(size(sites,1))) = 0; %set all flags to zero

CRfiles = ['FR_GEN  ';      % filenames for the file in the \\PAOA001\Sites\CR\CSI_net\old\ folder
           'FR_F_21X';
           'FR_C_21X';
           'FR_SOIL ';
           'FR_CLIM1';
           'FR_CLIM2';
           'FR_B_21X';
           'UVIC_01 ';
           'DAVE_01 ';];
OYfiles = ['OY_CLIMT';      % filenames for the file in the \\PAOA001\Sites\OY\CSI_net\old\ folder
           'OY_Ctl  ';
           'OY_CLIM1';
           'OY_CLIM2';];
YFfiles = ['YF_CLIM1';      % filenames for the file in the \\PAOA001\Sites\YF\CSI_net\old\ folder
           'YF_CLIM2';];   
PAOAfiles = ['FLOW7  ';     % filenames for the file in the \\PAOA001\Sites\PAOA\CSI_net\old\ folder
             'TOWER5 ';
             'PCCTRL2';
             'TDR8   ';
             'Soil6  ';
             'Bonet4 ';];
PAOBfiles = ['BS_23X_1';    % filenames for the file in the \\PAOA001\Sites\PAOB\CSI_net\old\ folder
             'BS_23X_2';
             'BS_21X_4';
             'BS_cr7_3';];
HJP02files = ['H02_10X2';   % filenames for the file in the \\PAOA001\Sites\HJP02\CSI_net\old\ folder
              'H02_23X1';
              'H02_10X1';];
HJP75files = ['MSC_MET1';   % filenames for the file in the \\PAOA001\Sites\HJP75\CSI_net\old\ folder
              'HUT_CTR ';
              'MSC_MET2';];  
PAOJfiles = ['JP_10X_2';    % filenames for the file in the \\PAOA001\Sites\PAOJ\CSI_net\old\ folder
             'JP_23X_1';
             'JP1     ';
             'JP_cr7  ';];            

for i=1:1:size(sites,1)  % number of rows in the sites vector == number of sites
    pathTemp = strcat('\\PAOA001\SITES\',sites(i,:),'\CSI_net\old\'); % common first portion of the path name
    allFilesExist = 1; % flag set to 1, if ANY file is missing this flag will be set to 0
    
    switch sites(i,:) 
    case 'CR   '
        for j=1:1:size(CRfiles,1) % number of rows
            % CR path eg. \\PAOA001\Sites\CR\CSI_net\old\FR_GEN.349
            CSI_netPath=strcat(pathTemp,CRfiles(j,:),'.',currentDOY); % normal DOY
            if exist (CSI_netPath) ~= 2     % MATLAB built in function exist returns 2 if the specified file is present
                allFilesExist = 0           % if ANY file is missing set flag to 0
            end;  
        end;
        
        if allFilesExist
            CSI_netOK(i) = 1;                % CSI_net(1) set to 1 if all files are present
        end;
    case 'OY   '
        for j=1:1:size(OYfiles,1) %number of rows
            % OY path eg. \\PAOA001\Sites\OY\CSI_net\old\OY_CLIMT.2004350
            CSI_netPath=strcat(pathTemp,OYfiles(j,:),'.',currentYear,CScurrentDOY); % Note Campbell Scientif DOY
            if exist (CSI_netPath) ~= 2     % MATLAB built in function exist returns 2 if the specified file is present
                allFilesExist = 0           % if ANY file is missing set flag to 0
            end;  
        end;
        
        if allFilesExist
            CSI_netOK(i) = 1;                % CSI_net(2) set to 1 if all files are present
        end;
    case 'YF   '
        for j=1:1:size(YFfiles,1) %number of rows
            % YF path eg. \\PAOA001\Sites\YF\CSI_net\old\YF_CLIM2.2004350
            CSI_netPath=strcat(pathTemp,YFfiles(j,:),'.',currentYear,CScurrentDOY); % Note Campbell Scientif DOY
            if exist (CSI_netPath) ~= 2     % MATLAB built in function exist returns 2 if the specified file is present
                allFilesExist = 0           % if ANY file is missing set flag to 0
            end;  
        end;
        
        if allFilesExist
            CSI_netOK(i) = 1;                % CSI_net(3) set to 1 if all files are present
        end
    case 'PAOA '
        for j=1:1:size(PAOAfiles,1) %number of rows
            if (j <= 3) % three of the file use the 'yyyyDOY' file ending
               % PAOA path eg. \\PAOA001\Sites\PAOA\CSI_net\old\FLOW7.349
               CSI_netPath=strcat(pathTemp,PAOAfiles(j,:),'.',currentDOY); % normal DOY  
            else        % three of the file use the 'yyyyCSDOY' file ending
               % PAOA path eg. \\PAOA001\Sites\PAOA\CSI_net\old\TDR8.2004350
               CSI_netPath=strcat(pathTemp,PAOAfiles(j,:),'.',currentYear,CScurrentDOY); % Note Campbell Scientif DOY
            end;
            
            if exist (CSI_netPath) ~= 2     % MATLAB built in function exist returns 2 if the specified file is present
                allFilesExist = 0           % if ANY file is missing set flag to 0
            end; 
        end;
        
        if allFilesExist
            CSI_netOK(i) = 1;                % CSI_net(4) set to 1 if all files are present
        end;
    case 'PAOB '
        for j=1:1:size(PAOBfiles,1) %number of rows
            if (j <= 2) % two of the file use the 'yyyyDOY' file ending
               % PAOB path eg. \\PAOA001\Sites\PAOB\CSI_net\old\BS_23X_1.349
               CSI_netPath=strcat(pathTemp,PAOBfiles(j,:),'.',currentDOY); % normal DOY   
            else        % two of the file use the 'yyyyCSDOY' file ending
               % PAOB path eg. \\PAOA001\Sites\PAOB\CSI_net\old\BS_21X_4.350
               CSI_netPath=strcat(pathTemp,PAOBfiles(j,:),'.',currentYear,CScurrentDOY); % Note Campbell Scientif DOY
            end;
            
            if exist (CSI_netPath) ~= 2     % MATLAB built in function exist returns 2 if the specified file is present
                allFilesExist = 0           % if ANY file is missing set flag to 0
            end;  
        end;
        
        if allFilesExist
            CSI_netOK(i) = 1;                % CSI_net(5) set to 1 if all files are present
        end;
    case 'HJP02'
        for j=1:1:size(HJP02files,1) %number of rows
            % HJP02 path eg. \\PAOA001\Sites\HJP02\CSI_net\old\H02_10X2.2004350
            CSI_netPath=strcat(pathTemp,HJP02files(j,:),'.',currentYear,CScurrentDOY); % Note Campbell Scientif DOY   
            if exist (CSI_netPath) ~= 2     % MATLAB built in function exist returns 2 if the specified file is present
                allFilesExist = 0           % if ANY file is missing set flag to 0
            end;  
        end;
        
        if allFilesExist
            CSI_netOK(i) = 1;                % CSI_net(6) set to 1 if all files are present
        end;
    case 'HJP75'
        for j=1:1:size(HJP75files,1) %number of rows
            % HJP75 path eg. \\PAOA001\Sites\HJP75\CSI_net\old\MSC_MET1.2004350
            CSI_netPath=strcat(pathTemp,HJP75files(j,:),'.',currentYear,CScurrentDOY); % Note Campbell Scientif DOY   
            if exist (CSI_netPath) ~= 2     % MATLAB built in function exist returns 2 if the specified file is present
                allFilesExist = 0           % if ANY file is missing set flag to 0
            end;  
        end;
        
        if allFilesExist
            CSI_netOK(i) = 1;                % CSI_net(7) set to 1 if all files are present
        end;
    case 'PAOJ '
        for j=1:1:size(PAOJfiles,1) %number of rows
            if (j <= 2) % two of the file use the 'DOY' file ending
                % PAOJ path eg. \\PAOA001\Sites\PAOJ\CSI_net\old\JP_10X_2.349
                CSI_netPath=strcat(pathTemp,PAOJfiles(j,:),'.',currentDOY); % normal DOY   
            else        % two of the file use the 'yyyyCSDOY' file ending
                % PAOJ path eg. \\PAOA001\Sites\PAOJ\CSI_net\old\JP1.2004350
                CSI_netPath=strcat(pathTemp,PAOJfiles(j,:),'.',currentYear,CScurrentDOY); % Note Campbell Scientif DOY
            end;
            if exist (CSI_netPath) ~= 2     % MATLAB built in function exist returns 2 if the specified file is present
                allFilesExist = 0           % if ANY file is missing set flag to 0
            end;  
        end;
        
        if allFilesExist
            CSI_netOK(i) = 1;                % CSI_net(8) set to 1 if all files are present
        end;
    end; %switch
end; %for