function WebCam_Picture(pictureHour,netCam_Link,fileNamePrefix)
% WebCam_Picture - take picture using a NetCam camera
%
% Inputs:
%   pictureHour    -        array of hours when pictures should be taken
%   netCam_Link    -        link to the web cam image
%   fileNamePrefix -        output file name path and prefix
%
% Example:
%
% WebCam_Picture(6:2:18,'http://192.168.1.151/netcam.jpg','d:\met-data\Pictures\HDF11_')
% takes pictures from 6am to 6pm every two hours.  Camera IP is
% 192.168.1.151. The file names will be created as
% d:\met-data\Pictures\HDF11_yyyymmddhh.jpg
%
% (c) Zoran Nesic               File created:       Mar 19, 2012
%                               Last modification:  Mar 19, 2012
%

% Revisions:
%


dateX = datevec(now);

% Save new figure only during specified time period 
% and only if time is in the first 30 minutes of the hour (one picture per
% hour)
if any(dateX(4)==pictureHour) && dateX(5) < 30
    tmp = datestr(fr_round_time(now,'hour',3),30);

    fileNameSufix = [tmp([1:8 10:11]) '.jpg'];
    fileName = [fileNamePrefix fileNameSufix];
    try
        % first create the current image
        urlwrite(netCam_Link,fileName);
        % make another copy of the same image for web page uploads
        copyfile(fileName,[fileNamePrefix 'current.jpg'],'f');
    end
end
