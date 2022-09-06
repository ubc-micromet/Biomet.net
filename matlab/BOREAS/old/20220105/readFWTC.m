function ttc = readFWTC(fileName)
% x = readFWTC(fileName) - function that reads Fine Wire Thermocouple ASCIII data (with delimiters)
%
% Inputs:
%   fileName    -   full file name (path and everything)
% Outputs:
%   ttc         -   Single column 
%                   Temperature is in deg C
%
%
% (c) Zoran Nesic           File created:   May 13, 2002
%                           Last revision:  May 16, 2002
%     Altaf Arain           Last revision:  May 26, 2002


%%% Note: FWTC data is being logged at 21.3 Hz


% Read ASCII data file
fid=fopen(fileName,'rt');
if fid < 0 
    error 'Wrong file name'
end
x = fscanf(fid,'%c' , [1 inf]);
fclose(fid);

% convert character string to numeric values
y = str2num(x);

% May need an if statement to remove first and last line of data if it is not complete
%if ind(1) < 6
%    indStart = ind(1)+1;        % if there is an incomplete line at the beginning skip it
%elseif ind(1)==6
%    indStart = 1;               % if the first delimiter is ind==6 first line is complete
%end

%n = length(x);
%if ind(end) < n
%    indEnd = ind(end);          % if there is an incomplete line at the end crop it
%else
%    indEnd = n;                 % otherwise keep the end part in
%end


% Thermocouple temperature (deg C)
ttc = y(:,2);