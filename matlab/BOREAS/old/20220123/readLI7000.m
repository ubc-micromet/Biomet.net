function x = readLI7000(fileName)
% x = readLI7000(fileName) - function that reads LI7000 data (set to 6 columns)
%
% Inputs:
%   fileName    -   full file name (path and everything)
% Outputs:
%   x           -   a matrix of 6 columns 
%
%
% (c) Zoran Nesic           File created:   May 25, 2002
%                           Last revision:  May 25, 2002


% Read data
[junk x1 x2 x3 x4 x5 x6]= textread(fileName,'%s %f %f %f %f %f %f \n','headerlines',1);
% Correct if the first line is incomplete
if x6(1)==0
    offsetStart = 2;
else
    offsetStart = 1;
end
% Correct if the last line is incomplete
offsetEnd = length(x6);

x1 = x1(offsetStart:offsetEnd);
x2 = x2(offsetStart:offsetEnd);
x3 = x3(offsetStart:offsetEnd);
x4 = x4(offsetStart:offsetEnd);
x5 = x5(offsetStart:offsetEnd);
x6 = x6(offsetStart:offsetEnd);

x = [x1 x2 x3 x4 x5 x6];