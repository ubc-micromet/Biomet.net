function [slope_1, slope_2, slope_avg]= ch_slope (start,stop,timeSer,dataIn,column)
%
%[slope_1, slope_2, slope_avg]= ch_slope (start, end, column)
%
% This function calculates the slope for the given column in the matrix of combined data 
% from either datalogger (for cr10, dataIn = data_cr10 and timeSer = timeSer_cr10,  
% for 21x, dataIn = data_21x and timeSer = timeSer_21x). Check the datalogger .fsl file
% (output array) for the column number you want, or read it off the plot title.
%
%
%
%
%
% whos
indMain = find(timeSer >= start & timeSer <= stop);

var1 = dataIn (:,column);

timeSlice      = timeSer(indMain);
columnSlice    = var1(indMain);
N              = length(columnSlice);

ind       = floor(1:N/2);
p1        = polyfit(timeSlice(ind),columnSlice(ind),1);
slope_1   = p1(1);

ind       = floor(N/2+1:N);
p2        = polyfit(timeSlice(ind),columnSlice(ind),1);
slope_2   = p2(1);

ind       = 1:N;
p         = polyfit(timeSlice(ind),columnSlice(ind),1);
slope_avg = p(1);
% whos


