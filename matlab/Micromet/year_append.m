function y = year_append(years,site,folder,variable,pth,data_type)
%% THIS MATLAB FUNCTION READS DATA FROM THE BOREAS DATABASE INTO MATLAB & APPENDS YEAR
%
%       year            site years of interest
%       site            site code
%       folder          folder of interest
%       variable        variable of interest
%       pth             path of interest
%       data_type       data type from read_bor
%
%   Written by Sara Knox, Oct 21, 2019
%
%%
y = [];
for i = 1:length(years)
    % Check if variable exists
    try
        y_yr = read_bor([pth num2str(years(i)) '\' site '\' folder '\' variable],data_type);
    catch
        if leapyear(years(i))
            y_yr = NaN(366*48,1);
        else
            y_yr = NaN(365*48,1);
        end
    end
    
    y = [y; y_yr];% load the time vector
end
