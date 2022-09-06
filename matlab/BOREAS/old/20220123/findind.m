function ind = findind(FileName, OffsetYear)
%
%   ind = findind(FileName)
%
%   Inputs:
%       FileName:       BOREAS raw data file name - 'ymmddhhH.n?'
%       OffsetYear:     Year zero (year when the data base started - yyyy)
%   Outputs:
%       ind:            Index in the data base where this half hour data
%                       should go.
%
% (c) Zoran Nesic           File created:       Jan 29, 1997
%                           Last modification:  Feb  5, 1997
%
YearNum = 1990+ str2num(FileName(1));
Year = [ '199' FileName(1)];
Month = (FileName(2:3));
Day = (FileName(4:5));
hour = (FileName(6:7));
tmp = (FileName(8));
if strcmp(tmp,'1')
    minutes = '30';
else
    minutes = '60';
end
d = [Month '-' Day '-' Year];
t = [hour ':' minutes ':00'];
%[d '  ' t]
ind = (decdoy(d,t) - 1) *48+1;

if OffsetYear < YearNum
    for i = OffsetYear:YearNum-1
        ind = ind + (decdoy(['12-31-' num2str(i)],'23:30:00') - 1) *48+1;
    end
end
ind = round(ind);