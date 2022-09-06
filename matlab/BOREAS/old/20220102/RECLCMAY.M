%
% reclcmay.m
%
%   Main program for recalculation of Boreas data for the period
%   May 2 to May 20, 1996.
%
% (c) Zoran Nesic               File created:       Feb  4, 1997
%                               Last modification:  Feb  6, 1997
NewIndex =[];
NewData = [];
stTime = clock;
for i = 2:20
    [indX, OutDataX] = reclc02('g:\may1996\', [1996 5 i], 'n2');
    NewIndex = [NewIndex   indX];
    NewData = [NewData;OutDataX];
    save tmp
end
disp(sprintf('Total time: %f\n\n',etime(clock, stTime)))