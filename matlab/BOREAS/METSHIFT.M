function x = metshift(RawData, delayArray)
%
%   x = metshift(RawData, delay)
%
%
%   This file corrects the delays, shifts, CO2 and H2O
%   columns.
%
%   Inputs:
%
%       RawData     - matrix with raw data (see read_met.m)
%       delayArray  - an array of channel numbers and appropriate delays
%                     All the channel numbers that are not given are assumed
%                     to be of delay 0. Delays are expressed in number of samples
%                    [ ch1, delay1 ...
%                      ch2, delay2 ...
%                       ...             ]; 
%       
%   Outputs:
%
%       x           - corrected (shifted) RawData
%
% (c) Zoran Nesic       File created:       May  8, 1997
%                       Last modification:  May  8, 1997
%
% Example1: BOREAS data: CO2 (ch #5) and H2O (ch #6) are delayed 20 samples:
%       delayArray = [  5,20;...
%                       6,20];
%       metshift(RawData,delayArray)
%
% Example2: visualization of the algorithm
%               x = 1:10;x = x(ones(1,9),:)
%               metshift(x,[5,2;6,4])
NumOfLines = length(RawData);

[n,m] = size(delayArray);

% shift every channel given in delayArray
for i=1:n
    RawData(delayArray(i,1),1:NumOfLines -delayArray(i,2)) = ...
                         RawData(delayArray(i,1),delayArray(i,2)+1:NumOfLines);
end

% cut the data at the end of the matrix to align all the rows
maxDelay = max(delayArray(:,2));
x = RawData(:,1:NumOfLines-maxDelay);

% different approaches to delaying arrays
%

% next line looks great but is almost 2x slower
%x = [RawData(1:4,1:NumOfLines-delay); RawData(5:6,delay+1:NumOfLines);RawData(7:9,1:NumOfLines-delay)];
%
