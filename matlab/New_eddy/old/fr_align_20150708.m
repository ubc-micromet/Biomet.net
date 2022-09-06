function [data_out, N, del_1, del_2] = fr_align(data_in, chan, n, del_span, shift)
%
% data_in   = structure input of 'instruments'
% chan      = vector of channels to use in alignment
% n         = number of samples to use for delay.m program (eg n = 5000);
% del_span  = maximum delay value (eg del_span = [-60 60])
%
% (c) Elyn Humphreys & Z.Nesic  File created:       July 7, 2003 
%                               Revisions:          May  5, 2009


%
% Revisions:
% May 5, 2009 (Zoran)
%       - handled correctly cases when one of the arrays is 0 length
%         (N = min(n1(n1>0));

%   Sep 18, 2001  - based upon fr_remove_delay
%   July 3, 2003  - new version to deal with multiple datasets



nInstruments = length(data_in);

arg_default('shift',zeros(size(chan)));
[nd,md] = size(del_span);
if nd == 1
    del_span = ones(nInstruments,1)*del_span;
end

%get all delays
for i = 1:nInstruments;
   [del_1(i),del_2(i)] = find_delay(data_in(i).EngUnits, data_in(1).EngUnits,...
      [chan(i) chan(1)],...
      n,del_span(i,:));
end   

%apply del_1 values
x            = max(del_1);
shift_all    = abs(del_1 - x);
trim         = shift_all;

for i = 1:nInstruments;
   data_out(i).EngUnits = data_in(i).EngUnits(shift_all(i)+1:end-trim,:);
end

%apply del_2 values
del_diff  = del_2 - del_1;
x         = max(del_diff);
cut_all   = abs(del_diff - x);

for i = 1:nInstruments;
   nn    = floor(linspace(1,length(data_out(i).EngUnits),cut_all(i)+2));
   data_out(i).EngUnits(nn(2:cut_all(i)+1),:) = [];
   n1(i) = length(data_out(i).EngUnits);
end

% find the shortest non-zero length array
N = min(n1(n1>0));

for i = 1:nInstruments;
   if n1(i) ~= 0 
       data_out(i).EngUnits = data_out(i).EngUnits(1:N,:);
   else
       data_out(i).EngUnits = [];   % assign empty for zero length arrays
   end
end




function [del_1, del_2] = find_delay(x,y,chan,n,del_span)
%
%
%
%
%
%
%
% Revisions:
%
%

N = min(length(x),length(y));
if N > n
   del_1 = delay(x(1:n,chan(1)),y(1:n,chan(2)),del_span);
   del_2 = delay(x(N-n+1:N,chan(1)),y(N-n+1:N,chan(2)),del_span);
else
   del_1 = 0;
   del_2 = 0;
end


return
%--------------------------------------------------------------------
%old fr_align for two instruments
%function [x1,y1,N,del_1, del_2] = fr_align(x, y,chan,n,del_span)
%
%
%
%
%
%
% (c) Zoran Nesic               File created:       Sep 18, 2001
%                               Last modification:  Sep 18, 2001

%
% Revisions:
%
%   Sep 18, 2001
%       - based upon fr_remove_delay
%

[del_1,del_2] = find_delay(x, y,chan,n,del_span);

n1 = size(x,1);
n2 = size(y,1);

if del_1 > 0
    x1 = x(1:n1-del_1,:);
    y1 = y(del_1+1:n2,:);
else
    y1 = y(1:n2-abs(del_1),:);
    x1 = x(abs(del_1)+1:n1,:);
end
n1 = n1 - abs(del_1);
n2 = n2 - abs(del_1);

if del_1 < del_2
    del_diff = del_2 - del_1;
    nn = floor(linspace(1,n2,del_diff+2));
    y1(nn(2:del_diff+1),:) = [];
    n2 = n2 - del_diff;
elseif del_1 > del_2
    del_diff = del_1 - del_2;
    nn = floor(linspace(1,n1,del_diff+2));
    x1(nn(2:del_diff+1),:) = [];
    n1 = n1 - del_diff;
end

N = min(n1,n2);
x1 = x1(1:N,:);
y1 = y1(1:N,:);

