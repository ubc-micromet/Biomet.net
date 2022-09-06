function [EngUnits, Header,tv] = fr_read_EddyPro_file(fileName,assign_in,varName)
% [EngUnits, Header] = fr_read_SmartFlux_file(fileName,assign_in,varName) - reads SmartFlux EP-Summary data files
%
% 
% Inputs:
%   fileName            - data file
%   assign_in           - 'caller', 'base' - assignes the data to the
%                           actual column header names (logger variables)
%                           either in callers space or in the base space.
%                           If empty or 0 no
%                           assignments are made
%   varName             - Used with 'caller'. Sets the name of the structure
%                         for the output variables. If
%                         empty the default name will be 'LGR' (LGR.tv,
%                         LGR.CH4_ppm...)
%
%
% (c) Zoran Nesic                   File created:       Aug 25, 2022
%                                   Last modification:  Aug 26, 2022
%

% Revisions (last one first):
%
% Aug 26, 2022 (Zoran)
%   - added spliting flag variables into multiple variables.
%


    try
        % Set the defaults
        arg_default('assign_in','base');
        arg_default('varName','Stats');

        % read the first headearline 
        fid = fopen(fileName);
        tmp = textscan(fid,'%s',1,'delimiter','\n');
        Header.line1 = char(tmp{1});
        fclose(fid);

        % read the second headearline
        fid = fopen(fileName); 
        tmp = textscan(fid,'%s',1,'delimiter','\n','headerlines',1);
        Header.line2 = char(tmp{1});
        fclose(fid);

        % read the third headearline
        fid = fopen(fileName); 
        tmp = textscan(fid,'%s',1,'delimiter','\n','headerlines',2);
        Header.line3 = char(tmp{1});
        fclose(fid);        

        % find how many fields are there
        ind = strfind(double(Header.line2),',');   % search for all tab delimeters (ascii = 9)
        N = length(ind)+1;          % this is the number of fields

        %Create: Header.var_names 
        tmp = textscan(Header.line2,'%s',N,'delimiter',','); % cell array of the var names
        tmp = tmp{1};
        for i=1:N-4
            newString = tmp{i+4};
            newString  = replace_string(newString,'-','_');
            newString  = replace_string(newString,'u*','us');
            newString  = strtrim(replace_string(newString,'(z_d)/L','zdL'));
            newString  = replace_string(newString,'T*','ts');
            newString  = replace_string(newString,'%','p');
            newString  = replace_string(newString,'/','_');
            Header.var_names{i} = newString;
        end

        %Create: Header.units 
        tmp = textscan(Header.line3,'%s',N,'delimiter',','); % cell array of the var names
        tmp = tmp{1};
        for i=1:N-4
            Header.var_units{i} =char(tmp{i+4}); %
        end

        % Create the data format string
        frmStr = '%s %s %s %s';  % "DATA file_name"
        for i=1:N-4
            frmStr = [frmStr ' %f']; %#ok<*AGROW>
        end
        %frmStr = [frmStr '\n'];

        % re-open the file and read the data
        fid = fopen(fileName);
        % read the data
        EngUnits_tmp = textscan(fid,frmStr,'delimiter',',','headerlines',3);
        EngUnits = NaN * ones(length(EngUnits_tmp{5}),N-4);
        for i=1:N-4
            x = EngUnits_tmp{i+4};
            EngUnits(:,i) = x;
            % It is possible to aks the program to output, in addition to the
            % matrix EngUnits, all the variables and to put them in the callers
            % space.
            % store each x(j) -> outStruct(j).(var_name)
            for j=1:length(x)                
                outStruct(j,1).(char(Header.var_names(i))) =x(j);  
            end
        end
        % Extract time vector:
        tv=datenum(strcat(char(EngUnits_tmp{2}), ' '*ones(size(1,1)) ,char(EngUnits_tmp{3})));
        % tv = tv + 1/48;                         % *so does the SmartFlux** Biomet tv specifies the end of the measurement period, not the start

        % store each tv(j) -> outStruct(j).TimeVector
        for j=1:length(tv)                
            outStruct(j,1).TimeVector = tv(j);    
        end
        
        % Extract individual flags from flag variables
        flagVariables = {'spikes_hf','amplitude_resolution_hf','drop_out_hf',...
                         'absolute_limits_hf','skewness_kurtosis_hf','skewness_kurtosis_sf',...
                         'discontinuities_hf','discontinuities_sf','timelag_hf',...
                         'timelag_sf','attack_angle_hf','non_steady_wind_hf'};
        for j=1:size(outStruct,1)
            for cntFlagsVars = 1:length(flagVariables)
                flagField = char(flagVariables{cntFlagsVars});
                flagStr = sprintf('%d',outStruct(j,1).(flagField));
                for cntFlags = 1:length(flagStr)                
                    flagNum = str2double(flagStr(cntFlags));
                    outStruct(j,1).(sprintf('%s_%d',flagField,cntFlags)) = flagNum;
                end
            end
        end
        
        if strcmpi(assign_in,'CALLER')
            assignin('caller',varName,outStruct);
        end

        fclose(fid);

    catch %#ok<CTCH>
        fprintf('\nError reading file: %s. \n',fileName);
        EngUnits = [];
        Header = [];
        tv = [];
        error 'Exiting function...'
    end       
end
%-------------------------------------------------------------------
% function replace_string
% replaces string findX with the string replaceX and padds
% the replaceX string with spaces in the front to match the
% length of findX.
% Note: this will not work if the replacement string is shorter than
%       the findX.
function strOut = replace_string(strIn,findX,replaceX)
    % find all occurances of findX string
    ind=strfind(strIn,findX);
    strOut = strIn;
    N = length(findX);
    M = length(replaceX);
    if ~isempty(ind)
        %create a matrix of indexes ind21 that point to where the replacement values
        % should go
        x=0:N-1;
        ind1=x(ones(length(ind),1),:);
        ind2=ind(ones(N,1),:)';
        ind21=ind1+ind2;

        % create a replacement string of the same length as the strIN 
        % (Manual procedure - count the characters!)
        strReplace = [char(ones(1,N-M)*' ') replaceX];
        strOut(ind21)=strReplace(ones(length(ind),1),:);
    end    
    
end