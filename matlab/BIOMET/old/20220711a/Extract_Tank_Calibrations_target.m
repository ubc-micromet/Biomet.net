function [Report,co2stats] = Extract_Tank_Calibrations_target(calAES, tankAESSN, filePath, fileExt, co2_chan_num,points2avg)

% 
% This program is used to extract the calibration values obtained during the tank
% calibrations in the lab.
%
% (c) Zoran Nesic/ Dominic Lessard              File created:       Jul 3, 2008
%                                               Last modification:  Dec 30, 2013
%

% Revisions:
%
% Dec 30, 2013 (Zoran)
%   - made the program case sensitive to work with Matlab_2013a


wildCard = ['*.' fileExt];

[fileName, pathName, filterIndex] = uigetfile(fullfile(filePath,wildCard),'Select TARGET tank calibration data');

dataIn = fr_read_Digital2_file(fullfile(pathName,fileName)); 

co2 = dataIn(:,co2_chan_num); 

plot(co2)
fig = gcf;
zoom on

% set cancelX to false
cancelX = 0;

% calibration counter
N = 0;

% loop until cancelX == 1
while cancelX == 0
	pause
	%
	[nRow, nCol] =size(co2);
	%
	% Select the last point
	[x,y]=ginput(1);
	
	% indexes need to be integers so round x
	lastPoint = round(x);
	
	% calculate the first point index
	firstPoint = lastPoint - points2avg + 1;
	
	% create index of the CO2 sample points
	indSelectedPoints = [firstPoint:lastPoint];

    % increment the calibration counter
    N = N + 1;
    
	% extract CO2 sample
	co2_selected = co2(indSelectedPoints);
	
	% plot the CO2 trace and the sample
	h(N) = line(indSelectedPoints,co2_selected,'color','r');
	
	% turn zoom back on
	zoom out
	
	% Calculate statistics on the CO2 sample [avg std min max lastPointIndex]
	co2stats(N,:) = [mean(co2_selected) std(co2_selected) min(co2_selected) max(co2_selected) lastPoint];
	
	% show the CO2 average value on the figure
	ht(N) = text(firstPoint,co2stats(1)+0.5,sprintf('co_2 = %7.3f',co2stats(1)));
	zoom on
    
    ButtonName=questdlg('What do you want to do now?', ...
                       'Next step', ...
                       'Add another point','Remove last point','Finish','Add another point');
   switch ButtonName,
     case 'Add another point', 
      figure(fig);
     case 'Remove last point',
         N = N-1;
         co2stats = co2stats(1:N,:);
         delete(h(N+1))
         delete(ht(N+1))
         zoom on
      case 'Finish',
          cancelX = 1;
   end % switch 
end

% Create the output report
Report = sprintf('Tank calibration report for tank Target C02: %6.3f  AES number: %08s\n', calAES, tankAESSN);
Report = [Report sprintf('Report created: %s     \nFile name: %s \n\n',datestr(now),fullfile(pathName,fileName))];
Report = [Report sprintf('CO2 sample       Avg        Std       Min       Max       Location \n')];
for i = 1:N
    Report = [Report sprintf('       %3d     %7.3f   %7.4f    %7.3f   %7.3f       %d\n',i,co2stats(i,:))];
end
    
% save report into a file (use SN to create a generic file name. put file in the same
% folder where the data came from)