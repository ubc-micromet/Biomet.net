function DataOUT = fr_shift(DataIN, delayArray)
%
%   DataOUT = fr_shift(DataIN, delay)
%
%
%   Shift the columns in DataIN for the given time delays (delayArray). 
%
%   Inputs:
%
%       DataIN      - input data (one row = one sample)
%       delayArray  - an array of delays whose length is equal to the number of
%                     of columns in DataIN
%   Outputs:
%
%       DataOUT     - corrected (shifted) DataIN
%
% (c) Zoran Nesic       File created:       May  8, 1997  (using metshift.m)
%                       Last modification:  Mar 29, 1998
%

%
% Revisions:
%
%   Mar 29, 1998
%       -   converted function to work with "one row one sample"
%

[NumOfLines,n1] = size(DataIN);

delayArray = delayArray(:);
[n,m] = size(delayArray);
delayMin = min(delayArray);
if n1 ~= n
    error 'Length of the delayArray ~= numOfColumns of DataIN!'
end

% shift every channel given in delayArray
for i=1:n
      DataIN(1:NumOfLines -delayArray(i)-abs(delayMin),i) = ...
         DataIN([abs(delayMin) + delayArray(i)+1:NumOfLines],i);
end

% cut the data at the end of the matrix to align all the rows
maxDelay = max(delayArray)-delayMin;
DataOUT = DataIN(1:NumOfLines-maxDelay,:);

% different approaches to delaying arrays
%

% next line looks great but is almost 2x slower (Matlab 4.2)
%DataOUT = [DataIN(1:4,1:NumOfLines-delay); DataIN(5:6,delay+1:NumOfLines);DataIN(7:9,1:NumOfLines-delay)];
%

