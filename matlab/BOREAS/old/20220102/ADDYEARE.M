function addyeare
%
% addyeare.m
%
%   This program adds a year worth of data to an existing data base
%   set for Eddy corr. system (data collected using old MSDOS program,
%   Apr. 1996 - Nov. 1997
%
%
% (c) Zoran Nesic		File created:       Dec 28, 1997 (starting point add_year.m)
%                       Last modification:  Jan  1, 1999

%
% Revisions:
%
%   Jan 1, 1999
%    - path modifications

pth = 'r:\paoa\paoa\';
fileName = 'paoa';
chans = 1:88;
pages = 1:2;


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
    for k=pages
        fullFileName = [pth fileName '_' num2str(i) '.' num2str(k) '_2'];
        x = read_bor(fullFileName);
        x = [x;zr];
        save_bor(fullFileName,1,x);
    end
end
    