function add_year(pth,fileName,chans)
%
% add_year.m
%
%   This program adds a year worth of data to an existing data base
%   set
%
%   example:
%   pth = 'r:\paoa\newdata\tst\';
%   fileName = 'bnt';
%   chans = 1:104;
%   add_year(pth,fileName,chans);
%
% (c) Zoran Nesic		File created:       Dec 26, 1997
%                       Last modification:  Dec 26, 1997

%
% Revisions:
%

%pth = 'r:\paoa\newdata\tst\';
%fileName = 'bnt';
%chans = 1:104;

flag_len = ceil(max(chans)/8);
hhours = 365 * 48;

%
% new time vector
%
fullFileName = [pth fileName '_dt'];
t = read_bor(fullFileName);
oldLength = length(t);
newLength = oldLength + hhours;
t_new = linspace(0,max(t)+365,newLength)';
save_bor(fullFileName,1,t_new);

%
% new flag_1 file
%
fullFileName = [pth fileName '_f1'];
x = read_bor(fullFileName,2,flag_len);
zr = zeros(hhours,flag_len);
x_new = [x;zr];
save_bor(fullFileName,2,x_new,flag_len);

%
% new flag_2 file
%
fullFileName = [pth fileName '_f2'];
x = read_bor(fullFileName,3,10);
zr = zeros(hhours,10);
x_new = [x;zr];
save_bor(fullFileName,3,x_new,10);

zr = zeros(hhours,1);
for i=chans
    fullFileName = [pth fileName '.' num2str(i)];
    x = read_bor(fullFileName);
    x = [x;zr];
    save_bor(fullFileName,1,x);
    disp(sprintf('%d,',i));
end
    
