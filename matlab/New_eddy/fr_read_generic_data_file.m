function [EngUnits,Header,tv,outStruct] = fr_read_generic_data_file(fileName,assign_in,varName, dateColumnNum, timeInputFormat,colToKeep,structType,inputFileType,modifyVarNames,VariableNamesLine)
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
%   inputFileType       - default 'delimitedtext', see readtable for more options
%   modifyVarNames      - 0 [default] - don't table column names or use Biomet strategy for renaming them
%                         1 - let Matlab modify col names to proper Matlab variable names
%   VariableNamesLine   - 0 [default] let Matlab decide where column names are
%                         n - the row numnner where the column names are
%                          
%
% (c) Zoran Nesic                   File created:       Dec 20, 2023
%                                   Last modification:  Mar 25, 2024
%

% Revisions (last one first):
%
% Mar 25, 2024 (Zoran)
%   - added '.' to the list of characters that need to be replaced if they
%     appear in the variable names. Replace with '_'
% Mar 9, 2024 (Zoran)
%   - proper handling of GHG HF files. Automatic detection of DATAH column
% Feb 16, 2024 (Zoran)
%   - improved renameFields
% Feb 14, 2024 (Zoran)
%   - added new input parameter: VariableNamesLine. In some cases readtable cannot figure out which row 
%     contains the column (variable) names. Use VariableNamesLine to point to that row. EddyPro data needs this set to 2)
% Jan 26, 2024 (Zoran)
%   - added modifyVarNames as the function input
% Jan 23, 2024 (Zoran)
%   - added options to modify field names using Micromet strategy (replaceString) to keep this output compatible with the old
%     EddyPro conversion programs.
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
arg_default('modifyVarNames',false);             % let readtable modify variable names
arg_default('VariableNamesLine',0);              % indicates which row contains names of columns

Header = [];  % just a place holder to keep the same output parameters 
              % as for all the other fr_read* functions.
    try
        % Set the defaults
        arg_default('assign_in','base');
        arg_default('varName','Stats');

        % Read the file using readtable function
        if modifyVarNames
            opts = detectImportOptions(fileName,'FileType',inputFileType,'VariableNamesLine',VariableNamesLine);
        else
            opts = detectImportOptions(fileName,'FileType',inputFileType,'VariableNamingRule','preserve','VariableNamesLine',VariableNamesLine);
            %opts.VariableNames = renameFields(opts.VariableNames);
            % Now re-enable renaming of the variables
            %opts.VariableNamingRule = 'modify';
        end
        if length(dateColumnNum)==2
            timeVariable = opts.VariableNames(dateColumnNum(2));
            opts=setvartype(opts,timeVariable,'datetime');
            opts.VariableOptions(dateColumnNum(2)).InputFormat = char(timeInputFormat{2});
        end

        % Detect if this is HF data set (data from GHG *.data file)
        if strcmp(opts.VariableNames(1),'DATAH')
            % this is HF data file. These files need to have their variable names
            % processed in a special way because the units are in the same row as the
            % variable names. In addition to that, the variable names repeat themselves
            % like: CO2 (mmol/m^3) and CO2 (mg/m^3)
            flagHFdata = 1;
        else
            flagHFdata = 0;
        end

        % Read the file with the preset options
        warning('off','MATLAB:table:ModifiedAndSavedVarnames');
        f_tmp = readtable(fileName,opts);

        % For HF files separate units from the variable names
        % and to sort out the duplicate variable names
        if flagHFdata == 1
            [variableNames, Header.Units] = GHG_sep_var_names(f_tmp.Properties.VariableNames);
        else
            % keep the original names
            variableNames = f_tmp.Properties.VariableNames;
            % but use the proper names for Units!
            goodNames = renameFields(variableNames);
            for cntVars = 1:length(goodNames)
                Header.Units.(char(goodNames{cntVars})) = '';
            end
        end
        % if we want to modify the file name using our own rules (see renameFields local function for the list of rules)
        if ~modifyVarNames
            f_tmp = renamevars(f_tmp,f_tmp.Properties.VariableNames,renameFields(variableNames));
        end
        tv_tmp = table2array(f_tmp(:,dateColumnNum));      % Load end-time in the format yyyymmddHHMM
        if ~isdatetime(tv_tmp)
            tv_dt=datetime(num2str(tv_tmp),'inputformat',char(timeInputFormat{1}));
        else
            tv_dt = tv_tmp(:,1);
            if size(tv_tmp,2)==2
                tv_dt = tv_dt+timeofday(tv_tmp(:,2));
            end
        end
        
        % All rows where the time vector is NaN should be removed. Those are usually
        % part of the file header that got misinterperted as data
        f_tmp = f_tmp(~isnat(tv_dt),:);
        tv_dt = tv_dt(~isnat(tv_dt));

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
            Header.Units.TimeVector = 'datenum';
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

    catch ME %#ok<CTCH>
        fprintf(2,'\nError reading file: %s.\n',fileName);
        rethrow(ME)
    end       
end

%% --------------------------------------------------------
% rename fields that are not proper Matlab or Windows names
% using Biomet/Micromet renaming strategy
function renFields = renameFields(fieldsIn)
    renFields  = strrep(fieldsIn,' ','_');
    renFields  = strrep(renFields,'-','_');
    renFields  = strrep(renFields,'.','_');
    renFields  = strrep(renFields,'u*','us');
    renFields  = strrep(renFields,'(z_d)/L','zdL');
    renFields  = strrep(renFields,'T*','ts');
    renFields  = strrep(renFields,'%','p');
    renFields  = strrep(renFields,'/','_');
    renFields  = strrep(renFields,'(','_');
    renFields  = strrep(renFields,')','');
end

%%
%%------------------------------
% GHG HF file-specific handling
% of variable names and units
%------------------------------
function [varNames, unitsOut] = GHG_sep_var_names(orgVarsAndUnits)
    % separate variable names from the units
    for cntVars = 1:length(orgVarsAndUnits)
        cVarAndUnits = char(orgVarsAndUnits{cntVars});
        x=regexp(cVarAndUnits,'[^()]*','match');
        varNames{cntVars} = renameFields(deblank(char(x(1))));
        if length(x)>1
            tmpUnits{cntVars} = deblank(char(x(2)));
        else
            tmpUnits{cntVars} = '';
        end  
    end   

    % in their wisdom, Matlab people have let multiple traces have
    % the same name. Some of them are just dumb '----'. Deal with those first.
    for cntVars = 1:length(varNames)
        if startsWith(varNames(cntVars),'___')
            varNames{cntVars} = 'foo';
        end
    end

    % then deal with this kind of repeated names: 
    %   CO2 (mmol/m^3)	    CO2 (mg/m^3)   CO2 (umol/mol)	CO2 dry(umol/mol)
    % Those will be renamed as:
    %   CO2_1 (mmol/m^3)	CO2_2 (mg/m^3) CO2_3 (umol/mol)	CO2_dry(umol/mol)

    % Renaming non-unique fields
    varNamesUnique = unique(varNames,'stable');                 % find all unique names            
    for cntVars = 1:length(varNamesUnique)                      % cycle through unique names    
        currentVarName = varNamesUnique(cntVars);
        indVarName = ismember(varNames,currentVarName);
        nNameUsage = sum(indVarName);                           % how many times the same name is used
        if  nNameUsage > 1                                      % if the name repeats rename occurancies
            ind = find(indVarName);                             % find location of the occurancies
            for repCnt = 1:nNameUsage                           % rename them
                varNames{ind(repCnt)} = sprintf('%s_%d',char(currentVarName),repCnt);
            end
        end
    end
    % Now match the units with the new variable names.
    for cntVars = 1:length(varNames)
        renField = char(varNames{cntVars});
        %renField = renameFields(varFieldName);
        varUnits = char(tmpUnits(cntVars));
        if isempty(varUnits)
            % otherwise it returns [1�0 char] which just looks ugly. 
            varUnits = '';
        end
        if     (startsWith(renField,'CO2_') && ~strcmp('CO2_dry',renField)) ...
            || (startsWith(renField,'CH4_') && ~strcmp('CH4_dry',renField)) ...
            || (startsWith(renField,'H2O_') && ~strcmp('H2O_dry',renField))
            % At this point we have multiple CO2/H2O/CH4 columns. Need to
            % sort them out by the units so we don't have them looking
            % like this: CO2_1, CO2_2...
            switch varUnits
                case 'mmol/m^3'
                    extName = 'mole_density';
                case {'mg/m^3','g/m^3'}
                    extName = 'mass_density';
                case {'umol/mol','mmol/mol'}
                    extName = 'wet_mole_fraction';
                otherwise
                    % field names like CO2_Ab
                    extName = '';
            end
            if ~isempty(extName)
                varNames{cntVars} = [renField(1:4) extName];
            else
                varNames{cntVars} = renField;
            end
            unitsOut.(char(varNames{cntVars})) =  varUnits;
        else
            % Not a special case. No need to change the variable name
            unitsOut.(renField) = varUnits;
        end
    end    
end

%% OLD
%-------------------------------------------------------------------
% function replace_string
% replaces string findX with the string replaceX and padds
% the replaceX string with spaces in the front to match the
% length of findX.
% Note: this will not work if the replacement string is shorter than
%       the findX.
% function strOut = replace_string(strIn,findX,replaceX)
%     % find all occurances of findX string
%     ind=strfind(strIn,findX);
%     strOut = strIn;
%     N = length(findX);
%     M = length(replaceX);
%     if ~isempty(ind)
%         %create a matrix of indexes ind21 that point to where the replacement values
%         % should go
%         x=0:N-1;
%         ind1=x(ones(length(ind),1),:);
%         ind2=ind(ones(N,1),:)';
%         ind21=ind1+ind2;
% 
%         % create a replacement string of the same length as the strIN 
%         % (Manual procedure - count the characters!)
%         strReplace = [char(ones(1,N-M)*' ') replaceX];
%         strOut(ind21)=strReplace(ones(length(ind),1),:);
%     end    
% end
% function renFields = renameFields(fieldsIn)
%         for cntFields = 1:length(fieldsIn)
%             newString  = fieldsIn{cntFields};
%             newString  = replace_string(newString,' ','_');
%             newString  = replace_string(newString,'-','_');
%             newString  = replace_string(newString,'u*','us');
%             newString  = strtrim(replace_string(newString,'(z_d)/L','zdL'));
%             newString  = replace_string(newString,'T*','ts');
%             newString  = replace_string(newString,'%','p');
%             newString  = replace_string(newString,'/','_');
%             newString  = replace_string(newString,'(','_');
%             newString  = replace_string(newString,')','');
%             renFields{cntFields} = newString;
%         end
% end

