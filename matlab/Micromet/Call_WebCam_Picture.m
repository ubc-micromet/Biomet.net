function Call_WebCam_Picture(siteID,netCam_Link,pictureTakingHours)
% Call_WebCam_Picture - calls WebCam_Picture.m with appropriate input
% parameters.
%
% (c) Zoran Nesic               File created:       Mar 19, 2012
%                               Last modification:  Apr 22, 2022

%
% Apr 22, 2022 (Zoran and Tzu-Yi)
%   - modified to work for DSM and RBM sites. Used YF script as the
%     starting point

%WebCam_Picture([0:2 12:23],'http://192.168.1.151/netcam.jpg','d:\met-data\Pictures\HDF11_')
arg_default('pictureTakingHours',[5:22]);

out_dir=['P:\Sites\',siteID,'\Phenocam\'];         % output directory
out_dir2='P:\Micromet_web\www\webdata\resources\csv\';         % output directory
out_path = [out_dir siteID '_'];

WebCam_Picture(pictureTakingHours,netCam_Link,out_path);
copyfile([out_path,'current.jpg'],[out_dir2,siteID,'_current.jpg'],'f')