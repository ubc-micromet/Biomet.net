function [dataIn,timeSer,allFiles] = ch_read(pth,wildcard)
%
% Filename:  ch_read
% Author:   Zoran Nesic
% Created on: August 3, 1998 
% Revisions:  
% 
% This file is set up to convert datalogger data files to matlab readable and to combine
% several time consecutive files together for plotting.
% ===================================================================================
%
%
if pth(end)~= '\'
    pth = [pth '\'];
end

allFiles = dir([pth wildcard]);
numOfFiles = length(allFiles);

dataIn = [];
timeSer = [];
for i = 1:numOfFiles
    c = ['load ' pth allFiles(i).name];
    eval(c)
    junk1 = findstr(allFiles(i).name,'\');
    if ~isempty(junk1)
        allFiles(i).name = allFiles(i).name(junk1(end)+1:end);
    end
    junk = findstr(allFiles(i).name,'.');
    fileName = allFiles(i).name(1:junk-1);
    c = ['dataInLast = ' fileName ';'];
    eval(c);
    dataloggerTime = dataInLast(:,4);
    dataloggerHours = floor(dataloggerTime/100);
    dataloggerMinutes = dataloggerTime - dataloggerHours*100;
    dataloggerSeconds = dataInLast(:,5);
    decimalTime = (dataloggerHours + dataloggerMinutes / 60 + dataloggerSeconds/60/60 ) / 24;
    timeSerLast = datenum(dataInLast(:,2),1,1) + dataInLast(:,3) - 1 + decimalTime;
    timeSer = [timeSer ; timeSerLast];
    dataIn = [dataIn ; dataInLast];
end
[timeSer,ind] = sort(timeSer);
dataIn = dataIn(ind,:);

