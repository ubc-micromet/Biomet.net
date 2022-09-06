function [EngUnits, Header,tv] = fr_read_Gasmet_file(fileName,assign_in)
% [EngUnits, Header] = fr_read_Gasmet_file(fileName) - reads Gasmet data files
%
% 
% Inputs:
%   fileName            - Gasmet file in ASCII format
%   assign_in           - 'caller', 'base' - assignes the data to the
%                           actual column header names (logger variables)
%                           either in callers space or in the base space.
%                           If empty or 0 no
%                           assignments are made
%
%
% (c) Zoran Nesic                   File created:       Apr 15, 2017
%                                   Last modification:  Apr 15, 2017

arg_default('assign_in','base')

numOfChans = 16;
Header.line2 = {'H2O','H2O_res','CO2','CO2_res','CH4','CH4_res',...
                'N2O','N2O_res','NH3','NH3_res','CO','CO_res',...
                'Pbar','Pbar_res','Temp','Temp_res'};
try
    % Open file
    fid = fopen(fileName);
    
    % read entire file (each line is one cell)
    tmp = textscan(fid,'%s','headerlines',0,'Delimiter','\n');
    
    % take the first line as the header
    Header.line1 = char(tmp{1}{1});
    
    % Gasmet stores multiple header lines in the same file.  Those need to
    % be removed before further processing.
    % Scan the rest of cells and remove all that contain the header line
    k = 0;
    tmp2=[];
    for i=2:length(tmp{1})
        if isempty(strfind(tmp{1}{i},'Date'))
            k = k+1;
            tmp2 = [tmp2 tmp{1}{i} 10 ]; %#ok<AGROW>
        end
    end
    
    % Rescan the data string that contains the same info as the data file
    % but without any header lines
    [s_read] = textscan(tmp2,'%s %s %f %f %f %f  %f %f %f %f  %f %f %f %f  %f %f %f %f %s%s%s','headerlines',0);
    
    % Close the file
    fclose(fid);
    
    % reserve space for the numerical values
    EngUnits = NaN*zeros(length(s_read{1}),numOfChans);
    
    % Extract time vector by adding the data and the time columns.  
    % Matlab will add the current year to the time vector so we need to
    % subtract it from the result (yearX).
    yearX = datevec(now);
    yearX = yearX(1);
    tv = datenum(char(s_read{1}{:}))+datenum(char(s_read{2}{:}))-datenum(yearX,1,1);
    for j=3:numOfChans+2
        EngUnits(:,j-2) = s_read{j};
        % It is possible to aks the program to output, in addition to the
        % matrix EngUnits, all the variables and to put them in the callers
        % space.  The variable names are hard-coded in this program
        % (see Header.line2)
        if strcmpi(assign_in,'CALLER')
            assignin('caller',char(Header.line2(j-2)),s_read{j});
        end
    end
       
catch
    fprintf('\nError reading file: %s. \n',fileName);
    error 'Exiting function...'
end
