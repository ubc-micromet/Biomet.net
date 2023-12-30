function [EngUnits,Header,tv] = fr_read_ORG_file(fileName,assign_in,varName)
%  fr_read_ORG_file - reads ORG csv files 
%
% Note: This function reads Manitoba files for McGill Sara/Jason's project 
%    
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
% (c) Zoran Nesic                   File created:       Dec 17, 2023
%                                   Last modification:  Dec 17, 2023
%

% Revisions (last one first):
%
Header = [];  % just a place holder to keep the same output parameters 
              % as for all the other fr_read* functions.
    try
        % Set the defaults
        arg_default('assign_in','base');
        arg_default('varName','Stats');

        % Read the file using readtable function
        opts = detectImportOptions(fileName);
        opts.VariableNamesLine = 1;
        opts.Delimiter = ',';
        f_tmp = readtable(fileName,opts);
        tv_tmp = table2array(f_tmp(:,2));      % Load end-time in the format yyyymmddHHMM
        tv_dt=datetime(num2str(tv_tmp),'inputformat','uuuuMMddHHmm');
        tv = datenum(tv_dt);
        f1 = f_tmp(:,1:end);
        EngUnits = table2array(f1);            % Load all data
        EngUnits(EngUnits==-9999) = NaN;       % replace -9999s with NaNs
        numOfVars = length(f1.Properties.VariableNames);
        numOfRows = length(tv);
        
        % store each tv(j) -> outStruct(j).TimeVector
        for cntRows=1:numOfRows                
            outStruct(cntRows,1).TimeVector = tv(cntRows);     %#ok<*AGROW>
        end        

        % Convert EngUnits to Struc
        for cntVars=1:numOfVars
            % store each x(j) -> outStruct(j).(var_name)
            try
                for cntRows=1:numOfRows                
                    outStruct(cntRows,1).(char(f1.Properties.VariableNames(cntVars))) ...
                            = EngUnits(cntRows,cntVars);  
                end
            catch ME
                fprintf('**** ERROR ==>  ');
                fprintf('%s\n',ME.message);
                rethrow(ME)
            end
        end


        if strcmpi(assign_in,'CALLER')
            assignin('caller',varName,outStruct);
        end

    catch %#ok<CTCH>
        fprintf('\nError reading file: %s. \n',fileName);
        EngUnits = [];
        Header = [];
        tv = [];
        error 'Exiting function...'
    end       
end
