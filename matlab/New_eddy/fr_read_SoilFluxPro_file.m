function [EngUnits,Header,tv] = fr_read_SoilFluxPro_file(fileName,assign_in,varName,timeUnits)
%  fr_read_SoilFluxPro_file - reads SoilFluxPro csv files
%
% Notes: 
%   1. This function reads csv file outputs from SoilFluxPro software
%   2. The data is going to be stored into the nearest 30-min slot but the
%      time will be preserved in the variable varName(sampleNum).chamber.sample_tv
%      (read_bor data type: 8)
%   3. Because of Note #2, if the same chamber is measured less than 30 minutes
%      apart, the newer sample may overwrite the older. This is very unlikely
%      to happen during a normal sampling sequence.
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
%   timeUnit            - minutes in the sample period (spacing between two
%                         consecutive data points. Default 5 (min)
%
%
% (c) Zoran Nesic                   File created:       Sep  6, 2023
%                                   Last modification:  Sep  6, 2023
%

% Revisions (last one first):
%

Header = [];  % just a place holder to keep the same output parameters 
              % as for all the other fr_read* functions.
    try
        % Set the defaults
        arg_default('assign_in','base');
        arg_default('varName','Stats');
        arg_default('timeUnits',5);

        % Read the file using readtable function
        opts = detectImportOptions(fileName); %,'NumHeaderLines', 1);
        opts.VariableNamesLine = 2;
        opts.Delimiter = ',';
        warning('off','MATLAB:table:ModifiedAndSavedVarnames')
        f_tmp = readtable(fileName,opts);
        tv_tmp = table2array(f_tmp(:,2));
        tv_dt=datetime(tv_tmp,'inputformat','yyyy/MM/dd HH:mm:ss');
        tv_exact = datenum(tv_dt);          % this is the true time when the measurement took place
        tv = fr_round_time(tv_exact,timeUnits);       % this is the true time rounded to the nearest 30min
        chambNames = table2array(f_tmp(:,1));
        f1 = f_tmp(:,3:end);
        EngUnits = table2array(f1);
        numOfVars = length(f1.Properties.VariableNames);
        numOfRows = length(tv);
        
        % store each tv(j) -> outStruct(j).TimeVector
        for cntRows=1:numOfRows                
            outStruct(cntRows,1).TimeVector = tv(cntRows);     %#ok<*AGROW>
        end        

        % Convert EngUnits to Struc
        for cntRows=1:numOfRows 
            % store each x(j) -> outStruct(j).(var_name)
            try
                for cntVars=1:numOfVars             
                    outStruct(cntRows,1).chamber.(char(chambNames(cntRows))).(char(f1.Properties.VariableNames(cntVars))) ...
                            = EngUnits(cntRows,cntVars);  
                end
                outStruct(cntRows,1).chamber.(char(chambNames(cntRows))).sample_tv ...
                            =  tv_exact(cntRows);           
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
