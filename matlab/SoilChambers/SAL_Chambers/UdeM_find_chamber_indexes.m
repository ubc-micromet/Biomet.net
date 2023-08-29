function indOut = UdeM_find_chamber_indexes(dataIn,configIn)
%  indOut = UdeM_find_chamber_indexes(dataIn,configIn) - finds start/end indexes for all loggers/analyzer 
%                                         
%  The idea is to try to make this generic.  The program finds the name of
%  the chamber control logger, extracts each chamber's start/end indexes and 
%  then proceeds with finding start/end indexes for all other instruments/loggers.
% 
% Note:
%  The control logger must have a trace called .chamberNumber!
%
%  Output structure:
%       indOut.logger
%         struct with fields:
%           CH_CTRL:        [1×18 struct]
%           CH_AUX_10s:     [1×18 struct]
%           CH_AUX_30min:   [1×18 struct]
%       indOut.analyzer
%         struct with fields:
%           LGR:            [1×18 struct]
%
%     and each of the above structures looks like this:
%       indOut.analyzer.LGR(1)
%         struct with fields:
%           start:  [1×24 double]
%           end:    [1×24 double]
%     Each corresponding start and end time mark the begining and the
%     the end of each slope measurement. In case of UdeM setup,
%     there is one slope per hour so there are 24 starts and stops for
%     the chamber #1 above (.LGR(1)).
% 
%  example:
%   dateIn = datenum(2019,8,22)
%   configIn = UdeM_init_all(dateIn);
%   indOut = UdeM_find_chamber_indexes(dateIn,configIn); % find all indexes for Aug 22, 2019 data
%
% Zoran Nesic                   File created:       Jan 29, 2020
%                               Last modification:  Jan 27, 2022
%

% Revisions (newest first):
%
% Jan 27, 2022 (Zoran)
%   - added a check to see if the system switched to CH #20 (happens when
%     there is an issue with the flow and the system goes to a bypass mode
%     by switching the flow to channel #20 which is just opened to free flow of air)
%     If it did, the program would ignore that chamber. Otherwise the program
%     would have an overflow error when trying to access a non-existent chamber.
% Mar 1, 2020 (Zoran)
%   - added more comments above
%


ch_ctrl = configIn.ch_ctrl;             % name of the chamber controll logger 

% Find indexes pointing to the last points of each chamber run
% (when chamber counter switches from one chamber to the next)
indd = (find(diff(dataIn.rawData.logger.(ch_ctrl).chamberNumber)~=0));

counter = zeros(configIn.chNbr,1);
indOut.logger.(ch_ctrl).start = NaN;
indOut.logger.(ch_ctrl).end = NaN;
start = 1;
for i = 1:length(indd)
    chNum = dataIn.rawData.logger.(ch_ctrl).chamberNumber(indd(i));
    % if there is a problem with a chamber's airflow, the system
    % will switch to flow bypass which is chamber #20. 
    % This part of the program will ignore that chamber (Zoran: 20220127)
    if chNum <= configIn.chNbr 
        counter(chNum) = counter(chNum)+1;
        indOut.logger.(ch_ctrl)(chNum).start(counter(chNum)) = start;
        indOut.logger.(ch_ctrl)(chNum).end  (counter(chNum)) = indd(i);
        start                             = indd(i)+1;
    end
end

tv_ch_ctrl = dataIn.rawData.logger.(ch_ctrl).tv;

for instrumentNum = 1:length(configIn.Instrument)
    % for each instrument that's not the ch_ctrl
    % using time vectors and indexes for ch_ctrl
    % find the instruments start/end indexes
    % If logger is missing return NaNs for all start/stop values
    instrumentVarName = configIn.Instrument(instrumentNum).varName; 
    if ~strcmpi(instrumentVarName,ch_ctrl)
        instrumentType = configIn.Instrument(instrumentNum).Type;
        % pre-alocate space with NaNs
        for chNum = 1:length(indOut.logger.(configIn.ch_ctrl))
            indOut.(instrumentType).(instrumentVarName)(chNum).start = NaN*zeros(1,24);
            indOut.(instrumentType).(instrumentVarName)(chNum).end = NaN*zeros(1,24);
        end
        if ~isempty(dataIn.rawData.(instrumentType).(instrumentVarName))
            % if the data for this instrument exists proceed with finding
            % indexes
            tv_inst = dataIn.rawData.(instrumentType).(instrumentVarName).tv;
            % for each chamber
            for chNum = 1:length(indOut.logger.(configIn.ch_ctrl))
                for sampleNum = 1:length(indOut.logger.(configIn.ch_ctrl)(chNum).start)
                    % get start and end time for this chamber's run
                    tv_start = tv_ch_ctrl(indOut.logger.(configIn.ch_ctrl)(chNum).start(sampleNum));
                    tv_end   = tv_ch_ctrl(indOut.logger.(configIn.ch_ctrl)(chNum).end(sampleNum));
                    ind = find(tv_inst >= tv_start & tv_inst<= tv_end);
                    if ~isempty(ind)
                        % if ind is not empty assign the start/end indexes
                        indOut.(instrumentType).(instrumentVarName)(chNum).start(sampleNum) = ind(1);
                        indOut.(instrumentType).(instrumentVarName)(chNum).end(sampleNum) = ind(end);
                    else
                        % if ind is empty most likely the program is dealing
                        % with 30 minute data and there is no 30-min time stamps inside of the one
                        % chamber run.  Find the nearest time and use that
                        % index instead
                        [~,ind] = min(abs(tv_end - tv_inst));
                        indOut.(instrumentType).(instrumentVarName)(chNum).start(sampleNum) = ind;
                        indOut.(instrumentType).(instrumentVarName)(chNum).end(sampleNum) = ind;
                    end
                end
            end
        end
    end
end    

% once you have CH_CTRL indexes, use its tv to find the tv-s of the analyzer
% and other loggers and, from those, the appropriate indexes
% 
% need all of these:
% indOut.CH_CTRL.start/end done!
% indOut.analyzer.start/end
% indOut.CH_AUX....

