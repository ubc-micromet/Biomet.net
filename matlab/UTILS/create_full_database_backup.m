function create_full_database_backup(sitesIn,yearsIn,pathOut)

% backs up:
%        (1) the entire cleaned biomet db on Annex001 (stages 1-3).
%        (2) Site specific files e.g. SiteId_init_all.m
%        (3) all calibration files
% to a directory of the users choice. A logfile is generated, placed in base_dir
% and e-mailed to selected users (currently Zoran and Nick).
% Detailed logs are generated by fr_automated_cleaning for each site
% and year and placed in base_dir\database\yyyy\SiteId.

% Inputs:
%   -sitesIn:      cell array of siteId's, if left empty default is
%                   {'CR' 'YF' 'OY' 'BS' 'PA' 'HJP02'}
%   -yearsIn:      years desired; if left empty, program defaults to all existing
%                   years for each site for which there is data
%   -base_path:  desired location for backup
%
% Based on create_full_biomet_db_backup
%
% Zoran Nesic               File created:       May 23, 2024
%                           Last modification:  May 23, 2024


%
% Revisions:
%

    dv=datevec(datetime);
    if ~iscell(sitesIn)
        fprintf(2,'\n\nInput "sitesIn" needs to be a cell!\n\n');
        return
    end

    today_str = char(datetime('now','format','yyyyMMdd''T''HHmm'));
    dir_name = today_str;
    
    base_dir = fullfile(pathOut,dir_name);
    oldPwd = pwd;
    try
        %==========================================================================
        % Create base directory
        % If it already exists stop because it might already be in use. If user
        % wants to use this name it'll have to be deleted manually.
        
        [~,mes] = mkdir(base_dir);
        if ~isempty(mes)
            fprintf('%s\n',mes);
            fprintf(2,'%s\n','... returning, backup directory already exists.');
            return
        else
            fprintf('%s\n',['... backup directory ' base_dir ' created']);
        end
        
        fid = fopen(fullfile(base_dir,'biomet_db_backup.log'),'wt');
        fprintf('%s\n','%%%%%%%%%%%%%%%%%% Creating full biomet database backup %%%%%%%%%%%%%%%%%%');
        fprintf('Date: %s\n',char(datetime));
        fprintf(fid,'%s\n','%%%%%%%%%%%%%%%%%% Creating full biomet database backup %%%%%%%%%%%%%%%%%%');
        fprintf(fid,'Date: %s\n',char(datetime));
        
        % ==========================================================================
        % Copy biomet.net
        disp('Copying biomet.net...');
        fprintf(fid,'%s\n','Copying biomet.net...');
        [~,~] = mkdir(base_dir,'Biomet.net\Matlab');
        [~,mes] = copyfile(findBiometNetPath,fullfile(base_dir,'\Biomet.net'));
        if ~isempty(mes)
            disp(mes)
            disp('... returning, error copying Biomet.net');
            fprintf(fid,'%s\n',mes);
            fprintf(fid,'%s\n','... returning, error copying Biomet.net.');
            return
        else
            fprintf('%s - successfully copied Biomet.net\n',char(datetime));
            fprintf(fid,'%s\n','... successfully copied Biomet.net');
        end
        
        for m=1:length(sitesIn)
        
            siteID = sitesIn{m};
    
            fprintf('%s\n',['========== Raw database file backup for ' char(siteID) ' ==========']);
            fprintf(fid,'%s\n',['========== Raw database file backup backup for ' char(siteID) ' ==========']);
            %==========================================================================
            % Copy all relevant raw data (flux,climate,...)
            copy_FirstStage_files(siteID,yearsIn,fullfile(base_dir,'Database'));
    
            fprintf('%s\n',['========== Done raw file backup for ' char(siteID) ' ==========']);
            fprintf(fid,'%s\n',['========== Done raw  file backup backup for ' char(siteID) ' ==========']);
    
        end
    
        % =========================================================================
        % Copy relevant files from Calculation_Procedures folder
        %==========================================================================
        for m=1:length(sitesIn)
        
            siteID = sitesIn{m};
    
            fprintf('%s\n',['========== Calculation_procedures backup for ' char(siteID) ' ==========']);
            fprintf(fid,'%s\n',['========== Calculation_procedures backup for ' char(siteID) ' ==========']);
            if ~exist(fullfile(base_dir,'Database'),'dir')
                [~,~] = mkdir(base_dir,'Database');
            end

            % backup cleaning files: ini and .mat
            mkdir(base_dir,fullfile('Database\Calculation_Procedures\TraceAnalysis_ini',siteID));
            pth_ini = fullfile(base_dir,'Database\Calculation_Procedures\TraceAnalysis_ini',siteID);
        
            disp(['Copying TraceAnalysis_ini and FirstStage .mat files for ' siteID] );
            fprintf(fid,'%s\n',['Copying TraceAnalysis_ini and FirstStage .mat files for ' siteID ]);
        
            [~,mes] = copyfile(fullfile(biomet_path('Calculation_Procedures','TraceAnalysis_ini',siteID),'*.ini'),pth_ini);
            if ~isempty(mes)
                disp(mes)
                disp(['...error copying ini files for ' siteID]);
                fprintf(fid,'%s\n',mes);
                fprintf(fid,'%s\n',['...error copying ini files for ' siteID]);
            else
                fprintf('%s ...ini files done \n',char(datetime));
                fprintf(fid,'%s ...ini files done \n',char(datetime));
            end
            [~,mes] = copyfile(fullfile(biomet_path('Calculation_Procedures','TraceAnalysis_ini',siteID),'*.mat'),pth_ini);
            if ~isempty(mes)
                disp(mes)
                disp(['...error copying FirstStage .mat files for ' siteID]);
                fprintf(fid,'%s\n',mes);
                fprintf(fid,'%s\n',['...error copying FirstStage .mat files for ' siteID]);
            else
                fprintf('%s ...FirstStage .mat files done \n',char(datetime));
                fprintf(fid,'%s ...FirstStage .mat files done \n',char(datetime));
            end
            % added Derived Variables folder 20110518
            [~,mes] = copyfile(fullfile(biomet_path('Calculation_Procedures','TraceAnalysis_ini',[siteID '\Derived_Variables']),'*.*'),fullfile(pth_ini,'Derived_Variables'));
            if ~isempty(mes)
                disp(mes)
                disp(['...error copying Derived Variables folder for ' siteID]);
                fprintf(fid,'%s\n',mes);
                fprintf(fid,'%s\n',['...error copying Derived Variables folder for ' siteID]);
            else
                fprintf('%s ...Derived Variables folder done \n',char(datetime));
                fprintf(fid,'%s ...Derived Variables folder done \n',char(datetime));
            end
        end

        %============================================================
        % At this point all files that are needed are copied to the
        % destination folder. The default database paths will now be
        % changed to this new folder.
        %============================================================
        cd(base_dir)
        % Create default database path:
        fidBiometDefault = fopen('biomet_database_default.m','w');
        if fidBiometDefault > 0
            fprintf(fidBiometDefault,'%s\n','function folderDatabase = biomet_database_default');
            fprintf(fidBiometDefault,'%s\n','% This file is generated automatically by create_full_database_backup.m');
            fprintf(fidBiometDefault,'%s\n','fPath = mfilename(''fullpath'');');
            fprintf(fidBiometDefault,'%s\n','projectFolder = fileparts(fPath);');
            % fprintf(fidBiometDefault,'%s\n','ind = find(fPath==filesep);');
            % fprintf(fidBiometDefault,'projectFolder = fPath(1:ind(end));');
            fprintf(fidBiometDefault,'%s\n','folderDatabase = fullfile(projectFolder,''Database'');');
            fclose(fidBiometDefault);
        end

        for m=1:length(sitesIn)
        
            siteID = sitesIn{m};
    
            fprintf('%s\n',['========== Full cleaned database backup for ' char(siteID) ' ==========']);
            fprintf(fid,'%s\n',['========== Full cleaned database backup for ' char(siteID) ' ==========']);


            fprintf('%s\n','Creating first through thirdstage cleaned trace backups...');
            fprintf(fid,'%s\n','Creating first through thirdstage cleaned trace backups...');

            %==========================================================================
            % Create first, second and thirdstage database (for comparison with current
            % results)
    
            for k=1:length(yearsIn)
                try
                    fprintf('%s\n',['Creating cleaned trace backup for ' siteID ' ' num2str(yearsIn(k))]);
                    fprintf(fid,'%s\n',['Creating cleaned trace backup for ' siteID ' ' num2str(yearsIn(k))]);
                    fr_automated_cleaning(yearsIn(k),siteID,[1 2 3]);
                    fprintf('%s ...Cleaned traces backup complete\n\n',char(datetime));
                    fprintf(fid,'%s ...Cleaned traces backup complete\n',char(datetime));
                catch
                    fprintf(2,'%s ...Cleaned traces backup failed\n\n',char(datetime));
                    fprintf(fid,'%s ...Cleaned traces backup failed\n',char(datetime));
                    continue
                end
            end
        
            fprintf('%s\n',['========== Finished database backup for ' char(siteID) ' ==========']);
            fprintf(fid,'%s\n',['========== Finished database backup for ' char(siteID) ' ==============']);
            % base_dir = fullfile(base_path,dir_name); % reset base_dir for the next site
        end
        fprintf('%s\n','%%%%%%%%%%%%%%%% Finished full biomet database backup %%%%%%%%%%%%%%%%%%%');
        fprintf(fid,'%s\n','%%%%%%%%%%%%%%%% Finished full biomet database backup %%%%%%%%%%%%%%%%%%%');
        
        % compare annual cumulative NEP, GEP and R from newly generated db traces
        % with Annex001 database
        fprintf('%s\n','%%%%%%%%%%%%%%%% Annual NEP comparison %%%%%%%%%%%%%%%%%%%');
        fprintf(fid,'%s\n','%%%%%%%%%%%%%%%% Annual NEP comparison %%%%%%%%%%%%%%%%%%%');
        try
            pth_localdb = biomet_database_default;
            %   pth_refdb   = 'D:\clean_db_backups\20100926\Database';
            %pth_refdb   = 'D:\clean_db_backups\20101024\Database';
            %pth_refdb   = 'D:\clean_db_backups\20101121\Database'; % updated 20101122: Mat's new numbers for MPB1 (2008) and MPB2 (2009)
            %pth_refdb   = 'D:\clean_db_backups\20110116\Database'; % updated 20110124
            %pth_refdb   = 'D:\clean_db_backups\20110508\Database'; % updated so that 2010 is complete for all sites
            %pth_refdb   = 'D:\clean_db_backups\20120129\Database'; % updated so that 2011 is complete for all sites
            %pth_refdb   = 'D:\clean_db_backups\20140629\Database'; % updated so that 2012 is complete for all sites
            %pth_refdb   = '\\annex001\clean_db_backups\20170203\Database\'; % updated so that 2016 is complete for all sites
            pth_refdb   = '\\annex001\clean_db_backups\20180403\Database\'; % updated so that 2017 is complete for all sites
        
        
            create_annual_nep_report(yearsIn,pth_localdb,pth_refdb,fid,sitesIn);
        catch ME
            fprintf(fid,'%s\n','... creation of NEP comparison table failed ');
            fprintf(fid,'%s\n',ME.message);
        end
        
        fprintf('%s\n','%%%%%%%%%%%%%%%% Annual NEP comparison finished %%%%%%%%%%%%%%%%%%%');
        fprintf(fid,'%s\n','%%%%%%%%%%%%%%%% Annual NEP comparison finished %%%%%%%%%%%%%%%%%%%');
        
        fclose(fid);
        
        
        
        
        % prepare and send an e-mail alert
        
        message = [];
        message = [message sprintf('Biomet backup complete at %s:\n',char(datetime))];
        message = [message newline];
        message = [message sprintf('%s\n',['Backup can be found in ' base_dir ])];
        message = [message newline];
        message = [message sprintf('%s\n','***Please burn a DVD copy as soon as possible***')];
        
        subject_line = 'Full biomet backup ready';
        
        setpref('Internet',{'SMTP_Server','E_mail'},...
            {'smtp.interchange.ubc.ca','zoran.nesic@ubc.ca'});
        message = char(message)';
        [n,m] = size(message');
        message = [message; ' '.*ones(75-m,n)];
        
        sendmail('zoran.nesic@ubc.ca',subject_line,message(:)',fullfile(base_dir,'biomet_db_backup.log'));
    catch ME        
        disp(ME.stack);
    end

    % return to the original folder
    cd(oldPwd);
end

function biometNetPath = findBiometNetPath
    funA = which('read_bor');     % First find the path to Biomet.net by looking for a standard Biomet.net functions
    tstPattern = [filesep 'Biomet.net' filesep];
    indFirstFilesep=strfind(funA,tstPattern);
    biometNetPath = fullfile(funA(1:indFirstFilesep-1),tstPattern);
end
