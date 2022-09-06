function [EngUnits, Header,tv] = fr_read_LGR2_file(fileName,assign_in,flagUBCGII_ASCII,varName,forceReadASCII)
% [EngUnits, Header] = fr_read_LGR2_file(fileName,assign_in,flagUBCGII_ASCII) - reads LGR CO2/CH4 data files
%
% 
% Inputs:
%   fileName            - LGR CO2/CH4 file in ASCII format
%   assign_in           - 'caller', 'base' - assignes the data to the
%                           actual column header names (logger variables)
%                           either in callers space or in the base space.
%                           If empty or 0 no
%                           assignments are made
%   flagUBCGII_ASCII    - (1 - read UBC_GII files, 0 - read LGR
%                         uncompressed files)
%   varName             - Used with 'caller'. Sets the name of the structure
%                         for the output variables. If
%                         empty the default name will be 'LGR' (LGR.tv,
%                         LGR.CH4_ppm...)
%   forceReadASCII      - if this parameter is 1 then program will not try
%                         to load *.mat (overwrites .mat file with a new
%                         one)
%
%
% (c) Zoran Nesic                   File created:       Jan 30, 2019
%                                   Last modification:  Jan 31, 2020
%

% Revisions (last one first):
%
% Jan 31, 2020 (Zoran)
%   - the file header (Header.line3 below) was all wrong.  I changed it
%     using my best guess but I'll need to take a look at the original
%     Archived LGR files to do this properly.
%   - row checking procedure was weak.  Many bad dates were passing through
%     just to crash the program at datenum conversion. See findValidRows.
% Jan 22, 2020 (Zoran)
%   - Small edits to make the function compatible with Matlab > 2011a
% Jan 30, 2019 (Zoran)
%   - Created new function using fr_read_LGR1_file.m as the starting point.
%

    arg_default('assign_in','base');
    arg_default('flagUBCGII_ASCII',0);
    arg_default('varName','LGR');
    arg_default('forceReadASCII',0);

    % See if the matlab version of the ASCII file already exists and load
    % it instead
  try
    if forceReadASCII==1 || (~contains(fileName,'.mat') && ~exist([fileName '.mat'],'file')) 

        Header.line3 = {'H2O_ppm','H2O_ppm_sd','CO2_ppm','CO2_ppm_sd','CH4_ppm','CH4_ppm_sd',...
                        'CH4d_ppm','CH4d_ppm_sd','CO2d_ppm','CO2d_ppm_sd',...
                        'GasP_torr','GasP_torr_sd','GasT_C','GasT_C_sd','AmbT_C',...
                        'AmbT_C_sd','RD0_us','RD0_us_sd','RD1_us','RD1_us_sd',...
                        'Laser1','Laser1_sd','Laser2','Laser2_sd',...
                        'Fit_Flag','MIU_VALVE','MIU_DESC'};
        numOfChans = length(Header.line3);

        % Create a data line format
        % don't use all the channels (numOfChans) because the last one is a string
        if flagUBCGII_ASCII==1
            lineFormat = ['%s ', repmat('%f',[1 numOfChans-1]),'%s\r\n'];
        else
            lineFormat = ['%s ', repmat('%f',[1 numOfChans-1]),'%s\n'];
        end


        % Open file
        fid = fopen(fileName);
        errCode = findBeginingOfLine(fid,fileName, flagUBCGII_ASCII);

        % read the first two lines in the file (each line is one cell)
        tmp = textscan(fid,'%s',2,'headerlines',0,'Delimiter','\n');
        % Close the file
        fclose(fid);

        % take the second line as the header
        Header.line1 = char(tmp{1}{1});
        Header.line2 = char(tmp{1}{2});
        % Check if the header is actually present (only the first time the LGR
        % is turned on it outputs the header.  Most of the files will not have
        % one. Remove it if it exists
        if isempty(strfind(Header.line2,'Time'))
            Header.line1 = [];
            Header.line2 = [];
            % Open file
            fid = fopen(fileName);
            errCode = findBeginingOfLine(fid,fileName, flagUBCGII_ASCII); %#ok<*NASGU>

            % Read the entire file again (no headerlines to skip): 
            s_read = [];
            x_read = textscan(fid,lineFormat,'headerlines',0,'Delimiter',',');

            while ~isempty(x_read{1})
                % go through the cell array and remove the lines where the time
                % stamp is empty (Nov 15, 2018)
                % first find all the good rows
                ind =[];
                ind = findValidRows(x_read,fileName);
                % then only keep the good ones
                temp = [];
                for k =1:length(x_read)
                    temp{k} = x_read{k}(ind);
                end              
                
                x_read = [];
                x_read = temp; 
                if isempty(s_read)
                    s_read = x_read;
                else
                    for i=1:length(x_read)
                        s_read{i} = [s_read{i} ; x_read{i}]; %#ok<*AGROW>
                    end
                end
                x_read = textscan(fid,lineFormat,'headerlines',0,'Delimiter',',');
            end
            % Close the file
            fclose(fid);
        else
            % The headerlines exists. Read the file while skipping the
            % headerlines. 
            % Open file
            fid = fopen(fileName);
            errCode = findBeginingOfLine(fid,fileName, flagUBCGII_ASCII);

            s_read = textscan(fid,lineFormat,'headerlines',2,'Delimiter',',');
            % Close the file
            fclose(fid);
        end

        % The end of the LGR file (as stored by LGR unit, not the ones
        % collected via RS232) contains PGP part (a few hudred lines).
        % Use the next line to find where the data stops and PGP stars and
        % remove it from s_read
        ind=find(isnan(s_read{2}(:)));  % the first NaN in the second channel is Nan for PGP
        % if PGP is found remove the extra lines
        if ~isempty(ind)
            for i=1:length(s_read)
                s_read{i} = s_read{i}(1:ind(1)-1);
            end
        end
        % reserve space for the numerical values
        EngUnits = NaN*zeros(length(s_read{1}),numOfChans);
        % Extract time vector by adding the data and the time columns.  
        strDateTime = char(s_read{1}{:});
        tv = datenum(strDateTime);       
        for j=2:numOfChans+1
            if j<= numOfChans
                % EngUnits(:,j-1) = s_read{j};
                EngUnits(1:length(s_read{j}),j-1) = s_read{j};
            else
                % The last raw of data either says 'Disabled' or 'Enabled'
                % Assing EngUnits to be 0 for Disabled, and -1 for Enabled
                for i=1:length(s_read{end})
                    EngUnits(i,j-1) = double(~strcmpi(char(s_read{j}{i,:}),'Disabled'));
                end
            end
            % It is possible to aks the program to output, in addition to the
            % matrix EngUnits, all the variables and to put them in the callers
            % space.  The variable names are hard-coded in this program
            % (see Header.line2)
            strCmd=[varName '.' char(Header.line3(j-1)) '=EngUnits(:,j-1);'];
            eval(strCmd);
%             if strcmpi(assign_in,'CALLER')
%                 assignin('caller',char(Header.line3(j-1)),EngUnits(:,j-1));
%             end
        end
        if strcmpi(assign_in,'CALLER')
            strCmd = [varName '.tv=tv;'];
            eval(strCmd);
            strCmd = sprintf('assignin(%scaller%s,%s%s%s,%s)',39,39,39,varName,39,varName);
            eval(strCmd);
        end
        % The data collection of LGR files using UBC_GII in generic mode
        % will often cut the last or the first of the sample lines half way
        % through.  That generates NaN-s.  The following should remove all
        % the rows with NaN-s in them.
        ind = ~isnan(mean(EngUnits,2));
        EngUnits = EngUnits(ind,:);
        tv = tv(ind);
        
        % Save the results so the next time the program can bypass the
        % ASCII data parsing:
        try
            save([fileName '.mat'],varName,'tv','EngUnits','Header');
        catch
            fprintf('Warning: saving of %s failed. \n',[fileName '.mat']);
        end
    else
        if contains(fileName,'.mat') 
            load(fileName); %#ok<*LOAD>
        else
            % otherwise this must be true:
            %exist([fileName '.mat'],2)
            % so load that file:
            load([fileName '.mat']);
        end
        % The data collection of LGR files using UBC_GII in generic mode
        % will often cut the last or the first of the sample lines half way
        % through. That generates NaN-s.  
        % This was fixed (see above) but some old *.mat files
        % still have them.  Instead re-generating the mat files it was
        % easier to just insure that they are removed. The time penalty
        % for doing this on the files that don't have NaN's is 0.03s per
        % file.
        % The following should remove all the rows with NaN-s in them.
        ind = ~isnan(mean(EngUnits,2));
        EngUnits = EngUnits(ind,:);
        tv = tv(ind);
        if strcmpi(assign_in,'CALLER')
            assignin('caller','EngUnits',EngUnits); %#ok<*NODEF>
            assignin('caller','Header',Header);
            eval(sprintf('tempLGR = %s;', varName));
            assignin('caller',varName,tempLGR);
            assignin('caller','tv',tv);
        end
    end
  catch  %#ok<*CTCH>
        fprintf('\nError reading file: %s. \n',fileName);
        EngUnits = [];
        Header = [];
        tv = [];
        error 'Exiting function...'
  end            
  
end

function errCode = findBeginingOfLine(fid,fileName, flagUBCGII_ASCII)
%
% For an already opened file, this program finds the first line that starts
% with the date stamp and puts the file pointer there.
% 
    errCode = 0;
    if fid>0 
        if flagUBCGII_ASCII == 1
            % if flagUBCGII_ASCII is 1 then skip the first 10,000 bytes
            fseek(fid,10000,-1);
            % and look for the first complete line defined as
            % yyyy/mm/dd
            % At this point we know that file name is in the format
            % yymmdd so that's what the program will be looking for.
            % The program is written in 2017 so it's safe to assume that
            % the year is 2000+. It will not work past year 2100.
            ind = strfind(fileName,'\');
            shortFileName = fileName(ind(end)+1:end);
            searchStr = sprintf('20%s/%s/%s',shortFileName(1:2),shortFileName(3:4),shortFileName(5:6));
            % load a 1000 bytes of data from the current position
            tmp = char(fread(fid,1000,'char')');
            % search for the string
            ind = strfind(tmp,searchStr);
            if ~isempty(ind)
                % if string is found, reposition the pointer 
                fseek(fid,10000+ind(1)-1,-1);
            else
                errCode = -1;
                fprintf('Error reading %s. \n',fileName);
                fprintf('File format for is not UBC GII ASCII?\n');
                error ''
            end
        end
    else
        errCode = -1;
        fprintf('Error opening file: %s\n',fileName)
    end
end

function status = findValidRows(dataIn,fileName)
       
    % The reasoning behind this date search is given above in the
    % function: findBeginingOfLine. 
    ind = strfind(fileName,'\');
    shortFileName = fileName(ind(end)+1:end);
    searchStr = sprintf('20%s/%s/%s',shortFileName(1:2),shortFileName(3:4),shortFileName(5:6));

    status = strncmp(searchStr,dataIn{1},10);
    % remove incomplete rows (having fewer elements than the first row)
    status = status(1:length(dataIn{end}));
    % 20200131
    % now test and confirm that all data/times are valid (sometimes there
    % is a glitch in communication and a stray character ends up in the
    % date string (example from 19072014.dUdeM101:   {'2019/07/20 03z22:09.989'})
    for i=1:length(status)
        if status(i) ==1 
            try
                tv = datenum(dataIn{1}(i));
            catch
                % if invalid date, set status to 0 (bad row)
                status(i) = 0;
            end
        end
    end
        
end