function [EngUnits,Header,tv,outStruct] = fr_read_generic_data_file(fileName,assign_in,varName, dateColumnNum, timeInputFormat,colToKeep,structType,inputFileType)
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
%       [EngUnits,Header,tv,outStruct] = fr_read_generic_data_file(wildCardPath);
% 
% Inputs:
%   fileName            - data file
%   assign_in           - 'caller', 'base' - assignes the data to the
%                         actual column header names (logger variables)
%                         either in callers space or in the base space.
%   varName             - Used with 'caller'. Sets the name of the structure
%                         for the output variables. If
%                         empty the default name will be 'LGR' (LGR.tv,
%                         LGR.CH4_ppm...)
%   dateColumnNum       - The column number of the column containing date [time]. There has to be one. Default 1.
%   timeInputFormat     - If the date[time] column is not in the datetime format, use this format. Default 'uuuuMMddHHmm'
%   colToKeep           - default [1 Inf] meaning export all columns from 1:end.
%                         option [x y z] would only export columns x,y,x.
%   structType          - 0 [default] - Struct(ind).Variable, 1 - Struct.Variable(ind).
%                         The default is to index the structure using the old style: Struct(:).TimeVector,...
%                         This works well with the UBC Biomet EC calculation program outputs which are large
%                         nested trees of outputs: "Stats(:).MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs"
%                         For most of the simple input files like the ones from EddyPro, Ameriflux, SmartFluxPro
%                         it's much faster to load the data into the new style: Stats.TimeVector(:).
%                         Use structType = 1 for the non-legacy simple stuff.
%                         Note: There is a matching parameter for the database creation program: db_struct2database.
%                               Use the same value for structType!
%                          
%
% (c) Zoran Nesic                   File created:       Dec 20, 2023
%                                   Last modification:  Jan 22, 2024
%

% Revisions (last one first):
%
% Jan 22, 2024 (Zoran)
%   - arg_default for timeInputFormat was missing {}. Fixed.
% Jan 19, 2024 (Zoran)
%   - added parameter inputFileType. It is used when calling readtable to set the "FileType" property. 
%     The function used to assume the delimeter="," and use that. This is more generic and it should work
%     with *.data files from Licor (fro the .ghg files).
%   - gave dateColumnNum option to be a vector of 2. First number refers to the DATE column 
%     and the second to the TIME column for the tables that read DATE and TIME as two separate columns  
%     If dateColumnNum is a vector of two, then the timeInputFormat has to be also a cell vector of two!
% Jan 12, 2024 (Zoran)
%   - added structType input option (see the header for more info).
%       - speed improvement for an Ameriflux file with 52,600 lines was 4.5s vs 170s
%  Dec 21, 2023 (Zoran)
%   - added more input parameters and comments.

arg_default('timeInputFormat',{'uuuuMMddHHmm'})   % Matches time format for ORG Manitoba files.
arg_default('dateColumnNum',1)                  % table column with dates
arg_default('colToKeep', [1 Inf])                   % keep all table columns in EngUnits (not a good idea if there are string columns)
arg_default('inputFileType','delimitedtext');
arg_default('VariableNamesLine',1)
arg_default('structType',0)

Header = [];  % just a place holder to keep the same output parameters 
              % as for all the other fr_read* functions.
    try
        % Set the defaults
        arg_default('assign_in','base');
        arg_default('varName','Stats');

        % Read the file using readtable function
        opts = detectImportOptions(fileName,'FileType',inputFileType);
        if length(dateColumnNum)==2
            timeVariable = opts.VariableNames(dateColumnNum(2));
            opts=setvartype(opts,timeVariable,'datetime');
            opts.VariableOptions(dateColumnNum(2)).InputFormat = char(timeInputFormat{2});
        end
        if isfield(opts,'VariableNamesLine')
            opts.VariableNamesLine = VariableNamesLine;
        end
        % if isfield(opts,'Delimiter')
        %     opts.Delimiter = delimiter;
        % end
        f_tmp = readtable(fileName,opts);
        tv_tmp = table2array(f_tmp(:,dateColumnNum));      % Load end-time in the format yyyymmddHHMM
        if ~isdatetime(tv_tmp)
            tv_dt=datetime(num2str(tv_tmp),'inputformat',char(timeInputFormat{1}));
        else
            tv_dt = tv_tmp(:,1);
            if size(tv_tmp,2)==2
                tv_dt = tv_dt+timeofday(tv_tmp(:,2));
            end
        end
        tv = datenum(tv_dt); %#ok<*DATNM>
        if isinf(colToKeep(2))
            f1 = f_tmp(:,colToKeep(1):end);
        else
            f1 = f_tmp(:,colToKeep);
        end
        % At this point some of the columns could contain strings or cells
        % Set all of those to NaNs
        nCol = size(f1,2);
        EngUnits = NaN(size(f1));
        for cntCol = 1:nCol
            oneCol = table2array(f1(:,cntCol));
            if isnumeric(oneCol)
                EngUnits(:,cntCol) = oneCol;
            end
        end
        %EngUnits = table2array(f1);            % Load all data
        EngUnits(EngUnits==-9999) = NaN;       % replace -9999s with NaNs
        numOfVars = length(f1.Properties.VariableNames);
        numOfRows = length(tv);
        
        if structType == 0
            % store each tv(j) -> outStruct(j).TimeVector
            for cntRows=1:numOfRows                
                outStruct(cntRows,1).TimeVector = tv(cntRows);     %#ok<*AGROW>
            end   
        else
            outStruct.TimeVector = tv;
        end

        % Convert EngUnits to Struc
        for cntVars=1:numOfVars
            % store each x(j) -> outStruct(j).(var_name)
            try
                if structType == 0
                    % Old style output: outStruct(:).TimeVector
                    for cntRows=1:numOfRows                
                        outStruct(cntRows,1).(char(f1.Properties.VariableNames(cntVars))) ...
                                = EngUnits(cntRows,cntVars);  
                    end
                else
                    % New/simple style output: outStruct.TimeVector(:)
                    outStruct.(char(f1.Properties.VariableNames(cntVars))) ...
                                = EngUnits(:,cntVars);
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
