function  c  =  fr_get_init(siteFlag, currentDate);
%
%
%
% (c) Zoran Nesic       File created:             , 1997
%                       Last modification:  Sep 25, 2001

%
% Revisions:
%
%   Sep 25, 2001
%       - changed the function so it assumes that the XXX_init_all files have
%         siteFlag as the XXX part of the name. This makes adding new ini files
%         for new sites and/or data recalculation much easier.
%   Nov 21, 1999
%       - added eval statements. This helps if paths change after Matlab
%         had been initiated (eval refreshes the path). Used to cause
%         errors on the computers that didn't have one of the xx_init_all.m
%         files on the path at the moment of inititalization. Later on, when
%         a program would change the path so it included the particular xx_init_all
%         file, matlab would come up with an error: "Function not in context at compilation
%         use eval/feval instead"
%

[year,month] = datevec(currentDate);

if year < 2000
    tmp = [ '19' FR_DateToFileName(currentDate)];
else
    tmp = [ '20' FR_DateToFileName(currentDate)];
end

if strcmp(upper(siteFlag),'CR')
    siteFlag = 'FR';
end

fileName = ['c = ' siteFlag '_init_all(tmp);'];
eval(fileName);
