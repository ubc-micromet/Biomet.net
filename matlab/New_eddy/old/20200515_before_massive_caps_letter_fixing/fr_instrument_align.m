function Instrument_data = fr_instrument_align(configIn,systemNum,Instrument_data)

%Revisions:  
%
% Oct 18, 2017 (Zoran)
%   - Chaged what happens when Alignment.Enable = 'FALSE'.  Up to now this
%     appeared to be an untested option.  If the program had
%     Alignment.Enable set to FALSE the calculations would work only if all
%     the instruments had the same EngUnit lenghts. I've fixed that to,
%     with the flag set to FALSE, the instrument data (EngUnits) gets
%     trimmed to the shortest data length of all the instruments in that
%     system (usually a Sonic and an IRGA). 
%     I've noticed that for some sites this flag was set to:
%     Alignment.Enable = 1 or 0 (instead of 'TRUE' or 'FALSE').  In those
%     cases the data processing had been done as if Alignment.Enable = TRUE
%
%     **********************
%     Final note: Alignment should always be set to 'FALSE' if there is no
%     true alignement hardware setup (analog out of sonic 'w' measured by
%     the analog input of an IRGA). Otherwise the data processing is
%     unpredictable (program will cut out too much data and align the
%     traces improperly)
%     **********************
%
% May 5, 2009 (Zoran)
%   - Added new ini parameters (warning messages printed if parameters not
%   used, defaults are provide within this program):
%       configIn.Instrument(i).Alignment.Shift
%       configIn.Instrument(i).Alignment.Span
%       configIn.System(i).Alignment.SampleLength
%       configIn.System(i).Alignment.MaxAutoSampleReduction
%
%   Mar 23, 2004
%       - increased the span for the delays from [-60 60] to [-200 200]
%May 24, 2003 - Allow slaveChan to equal 1
%July 7, 2003 - Allow more than two instruments to be aligned and output alignment info with 
%                Instrument_data structure
%Aug 5, 2003  - Allow System level to determine instrument channels to use to align traces (priority) otherwise use Instrument level info

nInstruments = length(configIn.System(systemNum).Instrument);               % number of instruments in the system

chanNum = [];

% Check if Alignment for the current system is not needed
try
    if strcmp(upper(configIn.System(systemNum).Alignment.Enable),'FALSE'), 
        % if Alignment.Enable is set to FALSE then just trim the
        % instrument data so that all the traces have the same length and
        % then return
        
        % find min data length
        minLength = 1e38;
        for i = 1:nInstruments
            currentInstrument = configIn.System(systemNum).Instrument(i);                      % cycle for each instrument in the system
            m = length(Instrument_data(currentInstrument).EngUnits); 
            if m < minLength
                minLength = m;
            end
        end
        
        % trim all the traces to the new length
        for i = 1:nInstruments
            currentInstrument = configIn.System(systemNum).Instrument(i);                      % cycle for each instrument in the system
            Instrument_data(currentInstrument).EngUnits = Instrument_data(currentInstrument).EngUnits(1:minLength,:); 
        end
        
        % return the trimmed traces
        return
    end
catch
    disp('Configuration file should have System().Alignment.Enable = TRUE/FALSE line in it.');
    disp('Assuming Enable = TRUE.');
end
    

% Get settings for instruments 
for i = 1:nInstruments
    currentInstrument = configIn.System(systemNum).Instrument(i);                      % cycle for each instrument in the system
    try  
        chanNum(currentInstrument) = configIn.System(systemNum).Alignment.ChanNum(i); 
        Inst2align(currentInstrument) = currentInstrument;
    catch
        chanNum(currentInstrument) = configIn.Instrument(currentInstrument).Alignment.ChanNum; 
        Inst2align(currentInstrument) = currentInstrument;
    end;
    if isfield(configIn.Instrument(currentInstrument).Alignment,'Shift')
        shift(currentInstrument)   = configIn.Instrument(currentInstrument).Alignment.Shift; 
    else
        shift(currentInstrument) = 0;
        disp(sprintf('Missing configIn.Instrument(%d).Alignment.Shift info.  Assuming: [%d]',currentInstrument,shift(currentInstrument)))        
    end
    if isfield(configIn.Instrument(currentInstrument).Alignment,'Span')
        span(currentInstrument,:)  = configIn.Instrument(currentInstrument).Alignment.Span;
    else
        span(currentInstrument,:)  = [-200 200];
        disp(sprintf('Missing configIn.Instrument(%d).Alignment.Span info.  Assuming: [%d,%d]',currentInstrument,span(currentInstrument,:)))
    end
    InstType(currentInstrument) = {configIn.Instrument(currentInstrument).Alignment.Type};
end

if isempty(chanNum); return; end; %leave function if there are no instruments to align

cut             = find(chanNum == 0);
chanNum(cut)    = [];
shift(cut)    = [];
span(cut,:)    = [];
Inst2align(cut) = [];
InstType(cut) = [];

% Rearrange channels so that master channel is first
[InstType,ind_sort] = sort(InstType);
Inst2align = Inst2align(ind_sort);
chanNum    = chanNum(ind_sort);
span       = span(ind_sort,:);
shift      = shift(ind_sort);

shift_max = max(shift);
shift = -(shift-shift_max);

% Align instruments and find the data length for each instrument
dataLength = zeros(length(Inst2align),1);
for i = 1:length(Inst2align);
    data_in(i).EngUnits = Instrument_data(Inst2align(i)).EngUnits(1+shift(i):end,:);
    dataLength(i) = length(data_in(i).EngUnits);
end

try
    sampleLength = configIn.System(systemNum).Alignment.SampleLength;
catch
    sampleLength = 5000;
    disp(sprintf('Missing configIn.System(%d).Alignment.SampleLength. Using sampleLength = %d',systemNum,sampleLength));
end

[data_out, N, del_1, del_2] = fr_align(data_in, chanNum, sampleLength, span);         % Mar 23, 2004 increased from [-60 60] to [-200 200]

% Check if the number of missing samples appears to be too big 
% i.e. del_1 and del_2 are very different.  This will depend on the 
% instruments used but usually up to 5-sample differencies are OK but
% it can be more if an old LI-7000 digital board was used.
% Each System will have its own Alignment.MaxAutoSampleReduction
try
    MaxAutoSampleReduction = configIn.System(systemNum).Alignment.MaxAutoSampleReduction; 
catch
    % if MaxAutoSampleReduction parameter has not been defined in the
    % confing.ini then use a default of 5 and display a warning
    MaxAutoSampleReduction = 5;
    disp(sprintf('Missing configIn.System(%d).Alignment.MaxAutoSampleReduction parameter!',systemNum))
end
for i = 1:length(Inst2align);
    if abs(del_1(i)-del_2(i)) > MaxAutoSampleReduction
        % if the difference is bigger then the maximum alowed
        % assume that it's due to insufficient sample length
        % and/or low signal correlation and then increase the sample length
        % to full signal length (minimum dataLength for all instruments
        % involved). By using the full signal length del_1 and del_2 are
        % forced to be the same.
        display(sprintf('MaxAutoSampleReduction of %d was exceeded for the System #%d.', MaxAutoSampleReduction,systemNum))
        [data_out, N, del_1, del_2] = fr_align(data_in, chanNum, min(dataLength), span); 
    end
end
for i = 1:length(Inst2align);
    Instrument_data(Inst2align(i)).EngUnits = data_out(i).EngUnits;
    Instrument_data(Inst2align(i)).Alignment.del1 = del_1(i);
    Instrument_data(Inst2align(i)).Alignment.del2 = del_2(i);   
    Instrument_data(Inst2align(i)).Alignment.master = configIn.Instrument(Inst2align(1)).Name;      
    Instrument_data(Inst2align(i)).Alignment.masterChan = ...
        configIn.Instrument(Inst2align(1)).ChanNames(chanNum(1));      
end

