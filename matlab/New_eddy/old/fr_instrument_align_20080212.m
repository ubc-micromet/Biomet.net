function Instrument_data = fr_instrument_align(configIn,systemNum,Instrument_data)

%Revisions:  
%   Mar 23, 2004
%       - increased the span for the delays from [-60 60] to [-200 200]
%May 24, 2003 - Allow slaveChan to equal 1
%July 7, 2003 - Allow more than two instruments to be aligned and output alignment info with 
%                Instrument_data structure
%Aug 5, 2003  - Allow System level to determine instrument channels to use to align traces (priority) otherwise use Instrument level info

nInstruments = length(configIn.System(systemNum).Instrument);               % number of instruments in the system

chanNum = [];

% Get settings for instruments 
for i = 1:nInstruments
    currentInstrument = configIn.System(systemNum).Instrument(i);                      % cycle for each instrument in the system
    try,  
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
    end
    if isfield(configIn.Instrument(currentInstrument).Alignment,'Span')
        span(currentInstrument,:)  = configIn.Instrument(currentInstrument).Alignment.Span;
    else
        span(currentInstrument,:)  = [-200 200];
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

% Align instruments 
for i = 1:length(Inst2align);
    data_in(i).EngUnits = Instrument_data(Inst2align(i)).EngUnits(1+shift(i):end,:);
end

[data_out, N, del_1, del_2] = fr_align(data_in, chanNum, 5000, span);         % Mar 23, 2004 increased from [-60 60] to [-200 200]

for i = 1:length(Inst2align);
    Instrument_data(Inst2align(i)).EngUnits = data_out(i).EngUnits;
    Instrument_data(Inst2align(i)).Alignment.del1 = del_1(i);
    Instrument_data(Inst2align(i)).Alignment.del2 = del_2(i);   
    Instrument_data(Inst2align(i)).Alignment.master = configIn.Instrument(Inst2align(1)).Name;      
    Instrument_data(Inst2align(i)).Alignment.masterChan = ...
        configIn.Instrument(Inst2align(1)).ChanNames(chanNum(1));      
end

