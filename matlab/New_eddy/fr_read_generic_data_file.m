function [EngUnits,Header,tv] = fr_read_generic_data_file(fileName,assign_in,varName, dateColumnNum, timeInputFormat,colToKeep)
%  fr_read_generic_data_file - reads csv and xlsx data files for Biomet/Micromet projects 
%
% Note: This function should replace a set of similar functions written for
%       particular data formats.
%
% Limitations: 
%       All cells in the file aside from the 1 column of date/time need to be numbers!
%    
% Example:
%   Zoe's water level data:
%       [EngUnits,Header,tv] = fr_read_generic_data_file('V:\Sites\BBS\Chambers\Manualdata\WL_for_each_collar.xlsx','caller',[],1,[],[2 Inf]);
%   Manitoba ORG Field sites:
%       [EngUnits,Header,tv] = fr_read_generic_data_file(wildCardPath,'caller');
% 
% Inputs:
%   fileName            - data file
%   assign_in           - 'caller', 'base' - assignes the data to the
%                         actual column header names (logger variables)
%                         either in callers space or in the base space.
%                         If empty or 0 no
%                         assignments are made
%   varName             - Used with 'caller'. Sets the name of the structure
%                         for the output variables. If
%                         empty the default name will be 'LGR' (LGR.tv,
%                         LGR.CH4_ppm...)
%   dateColumnNum       - The column number of the column containing date [time]. There has to be one. Default 1.
%   timeInputFormat     - If the date[time] column is not in the datetime format, use this format. Default 'uuuuMMddHHmm'
%   colToKeep           - default [1 Inf] meaning export all columns from 1:end.
%                         option [x y z] would only export columns x,y,x.
%                          
%
% (c) Zoran Nesic                   File created:       Dec 20, 2023
%                                   Last modification:  Dec 21, 2023
%

% Revisions (last one first):
%
%  Dec 21, 2023 (Zoran)
%   - added more input parameters and comments.

arg_default('timeInputFormat','uuuuMMddHHmm')   % Matches time format for ORG Manitoba files.
arg_default('dateColumnNum',2)                  % table column with dates
arg_default('colToKeep', [1 Inf])                   % keep all table columns in EngUnits (not a good idea if there are string columns)
arg_default('delimiter',',');
arg_default('VariableNamesLine',1)

Header = [];  % just a place holder to keep the same output parameters 
              % as for all the other fr_read* functions.
    try
        % Set the defaults
        arg_default('assign_in','base');
        arg_default('varName','Stats');

        % Read the file using readtable function
        opts = detectImportOptions(fileName);
        if isfield(opts,'VariableNamesLine')
            opts.VariableNamesLine = VariableNamesLine;
        end
        if isfield(opts,'Delimiter')
            opts.Delimiter = delimiter;
        end
        f_tmp = readtable(fileName,opts);
        tv_tmp = table2array(f_tmp(:,dateColumnNum));      % Load end-time in the format yyyymmddHHMM
        if ~isdatetime(tv_tmp)
            tv_dt=datetime(num2str(tv_tmp),'inputformat',timeInputFormat);
        else
            tv_dt = tv_tmp;
        end
        tv = datenum(tv_dt);
        if isinf(colToKeep(2))
            f1 = f_tmp(:,colToKeep(1):end);
        else
            f1 = f_tmp(:,colToKeep);
        end
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
