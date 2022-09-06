%
% reclcmay_1997.m
%
%   Main program for recalculation of Boreas data for the period
%   May 18 to May 31, 1997.
%
% (c) Zoran Nesic               File created:       Feb  4, 1997
%                               Last modification:  Sep  8, 1998
NewIndex =[];
NewData = [];
stTime = clock;
for i = 18:31
    [indX, OutDataX] = reclc02('c:\cd-rom\boreas_97_recalc\', [1997 5 i], 'n2');
    NewIndex = [NewIndex   indX];
    NewData = [NewData;OutDataX];
    save tmp
end
disp(sprintf('Total time: %f\n\n',etime(clock, stTime)))