function dataStruct = UdeM_ACS_calc_basic_stats(dataStruct)


%----------------------------------------------------------------
%   - Do basic stats for all chamber related data
%     The configuration data structure configIn contains the 
%     information of which climate sensor relates to which chamber.
%
%     The resulting structure is in this format:
%     
%     .chamber(chNumber)
%        .sample(hour)
%          .tv
%          .soil_Temperature_in
%          ...
%          .flux
%             .co2
%               .dcdt
%               .rmse
%               ...
%             .ch4
%               ...
%             .n2o
%               ...
%----------------------------------------------------------------

indOut = dataStruct.indexes;
configIn = dataStruct.configIn ;

% cycle through all chambers
for chNum = 1:configIn.chNbr
    % cycle through all the samples (chamber runs, usually 24 per day)
    for sampleNum = 1:length(indOut.analyzer.LGR(chNum).start)
        % find the field name and the trace name 
        for traceNum=1:size(configIn.chamber(chNum).traces,1)
            % extract info for this trace
            varName = char(configIn.chamber(chNum).traces{traceNum,1});
            instrType = char(configIn.chamber(chNum).traces{traceNum,2});
            instrName = char(configIn.chamber(chNum).traces{traceNum,3});
            traceName = char(configIn.chamber(chNum).traces{traceNum,4});
            try
                if ~isempty(instrType) & ~isempty(instrName) & ~isempty(traceName) & ~isempty(dataStruct.rawData.(instrType).(instrName)) %#ok<AND2>
                    % pull the trace data out
                    indStart = dataStruct.indexes.(instrType).(instrName)(chNum).start(sampleNum);
                    indEnd   = dataStruct.indexes.(instrType).(instrName)(chNum).end(sampleNum);
                    tv        = dataStruct.rawData.(instrType).(instrName).tv;
                    traceVals = dataStruct.rawData.(instrType).(instrName).(traceName)(indStart:indEnd);
                    % store calculations for this trace
                    if strcmpi(instrType,'analyzer')
                        % store time vector for the analyzer only!
                        dataStruct.chamber(chNum).sample(sampleNum).tv = tv(indEnd);
                    end
                    dataStruct.chamber(chNum).sample(sampleNum).(varName).avg = mean(traceVals);
                    dataStruct.chamber(chNum).sample(sampleNum).(varName).min = min(traceVals);
                    dataStruct.chamber(chNum).sample(sampleNum).(varName).max = max(traceVals);
                    dataStruct.chamber(chNum).sample(sampleNum).(varName).std = std(traceVals);
                else
                    % store NaNs for each output value
                    if strcmpi(instrType,'analyzer')
                        % store time vector for the analyzer only!
                        dataStruct.chamber(chNum).sample(sampleNum).tv = tv(indEnd);
                    end
                    dataStruct.chamber(chNum).sample(sampleNum).(varName).avg = NaN;                
                    dataStruct.chamber(chNum).sample(sampleNum).(varName).min = NaN;
                    dataStruct.chamber(chNum).sample(sampleNum).(varName).max = NaN;
                    dataStruct.chamber(chNum).sample(sampleNum).(varName).std = NaN;
                end
            catch
                % if any errors happen, print the error and asign NaNs to everything:
                % Note: I am not sure if assigning NaN to tv will have bad effects
                %       Only time will tell.  :-(
                dataStruct.chamber(chNum).sample(sampleNum).tv = NaN;
                dataStruct.chamber(chNum).sample(sampleNum).(varName).avg = NaN;                
                dataStruct.chamber(chNum).sample(sampleNum).(varName).min = NaN;
                dataStruct.chamber(chNum).sample(sampleNum).(varName).max = NaN;
                dataStruct.chamber(chNum).sample(sampleNum).(varName).std = NaN;
            end
            
        end
    end
end