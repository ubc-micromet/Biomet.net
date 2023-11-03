function chamberOut = UdeM_join_mat_files(filePath,dateRange)
%
% 
% Load all hhour files (a slow process, 20s per day). 
% The resulting structure (chamberOut) is smaller. It lacks the curve fitting 
% models. SHouldn't be a big problem because those are needed for troubleshooting
% and quality control; not for the data summaries.
% For the climate and diagnostic variables - it only picks the averages, not
% min/max/std-s.  This can be changed if needed. (see "otherwise" below)
%
% If the dataStruct changes in the future, this file will need to change too.
% 
% Example:
%   - chamberOut = UdeM_join_mat_files('E:\Site_DATA\WL\met-data\hhour',datenum(2019,6,21:30))
%     compiles all data for June 2019 collected at UdeM site that year.
%
%
% Zoran Nesic               File created:       Apr 1, 2020
%                           Last modification:  Apr 2, 2020
    
    
%filePath = 'E:\Site_DATA\WL\met-data\hhour';
numOfDaysToProcess = length(dateRange);
dayCounter = 0;
for currentDate = dateRange
    tx=now;
    dayCounter = dayCounter+1;
    fileName = sprintf('%s_recalcs_UdeM.mat',datestr(currentDate,'yyyymmdd'));
    if exist(fullfile(filePath,fileName),'file')
        fprintf('Loading: %s...',fileName);
        load(fullfile(filePath,fileName)); %#ok<*LOAD>
        fprintf(' loaded in %4.1f seconds. \n',(now-tx)*24*3600);      
        for chNum = 1:18
            try
                chamber = dataStruct.chamber(chNum);
                allFields = fieldnames(chamber.sample);
                N = length(chamber.sample);
                validSampleNum = 0;
                for fieldName = allFields'  
                    for sampleNum = 1:N
                        % if there is no dcdt for lin_B then there was some error in flux calcs.
                        % Reject that sample.
                        if ~isnan(chamber.sample(sampleNum).tv) ... 
                                                    & chamber.sample(sampleNum).tv ~= 0 ...
                                                    & ~isempty(chamber.sample(sampleNum).flux) ...
                                                    & ~isnan(chamber.sample(sampleNum).flux.co2.lin_B.dcdt) %#ok<*AND2>                            
                            fName = char(fieldName);
                            switch fName
                                case 'tv'
                                    try
                                        indNextSample = length(chamberOut.chamber(chNum).tv)+1;
                                    catch
                                        indNextSample = 1;
                                    end
                                    chamberOut.chamber(chNum).tv(indNextSample,1) = chamber.sample(sampleNum).tv;
                                    validSampleNum = validSampleNum + 1;
                                case 'flux'
                                    if ~isempty(chamber.sample(sampleNum).(fName))
                                        gasTypes = fieldnames(chamber.sample(sampleNum).(fName));
                                        for cellGasType = gasTypes'
                                            cGasType = char(cellGasType);
                                            fitFieldNames = fieldnames(chamber.sample(sampleNum).(fName).(cGasType));
                                            for cellFitFieldNames = fitFieldNames'
                                                cFitFieldName = char(cellFitFieldNames);

                                                % it's one of 'lin_B', 'exp_L', 'exp_B' fields
                                                fluxFieldNames = fieldnames(chamber.sample(sampleNum).(fName).(cGasType).(cFitFieldName));
                                                for cellFluxFieldNames = fluxFieldNames'
                                                    cFluxFieldNames = char(cellFluxFieldNames);
                                                    switch cFluxFieldNames % ' one of: 'dcdt','rmse','t0','c0','fCO2','gof','fitOut','t_elapsed'
                                                        case {'fCO2','fitOut','gof'}
                                                            % skip these fields                         
                                                        otherwise
                                                            try
                                                                indNextSample = length(chamberOut.chamber(chNum).(fName).(cGasType).(cFitFieldName).(cFluxFieldNames))+1;
                                                            catch
                                                                indNextSample = 1;
                                                            end                                                                    
                                                            chamberOut.chamber(chNum).(fName).(cGasType).(cFitFieldName).(cFluxFieldNames)(indNextSample,1) = ...
                                                                       chamber.sample(sampleNum).(fName).(cGasType).(cFitFieldName).(cFluxFieldNames);
                                                    end
                                                end
                                            end
                                        end
                                    end
                                otherwise
                                    try
                                        indNextSample = length(chamberOut.chamber(chNum).(fName).avg)+1;
                                    catch
                                        indNextSample = 1;
                                    end  
                                    chamberOut.chamber(chNum).(fName).avg(indNextSample,1) = chamber.sample(sampleNum).(fName).avg;
                            end

                        end
                    end                
                end 
            catch
                fprintf('*** Error processing file %s. \n',fileName);
                validSampleNum = 0;
            end
        end
    else
        fprintf('Missing file %s. \n',fileName);
    end
    fprintf('File #%d of %d with %d valid records processed in %4.2f seconds.\n',dayCounter,numOfDaysToProcess,validSampleNum,(now-tx)*24*3600)
end