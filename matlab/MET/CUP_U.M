function [u,dir] = cup_u(time);

%*****************************************************************%
% THIS MATLAB FUNCTION CALCULATES CUP WIND SPEED FROM             %
% UN-ROTATED U AND V SOLENT WIND COMPONENTS                       %
%                                                                 %
%   INPUT: time (unrotated solent 4-m u & v read automatically)   %
%   OUTPUT: cup wind speed & dir                                  %
%                                                                 %
%*****************************************************************%   

%   Revisions:
%       Jun 12, 1997 (Zoran Nesic)
%               Introduced global variables for the data paths
%

% Set the global path for the data base
global DATA_PATH_1994_PA

% load data and flag files

flag = read_bor([ DATA_PATH_1994_PA '\hfubc\hfubc_f1'],2,11);

u_4 = read_bor([ DATA_PATH_1994_PA '\hfubc\hfubc_5.1_2' ]);
u_4_flag = get_flag(flag,5);
ind = find(u_4_flag == 0);
u_4(ind) = NaN*ones(1,length(ind));

v_4 = read_bor([DATA_PATH_1994_PA '\hfubc\hfubc_6.1_2']);
v_4_flag = get_flag(flag,6);
ind = find(v_4_flag == 0);
v_4(ind) = NaN*ones(1,length(ind));

% gives cup wind speed

u = sqrt(u_4.^2 + v_4.^2);

% gives wind direction

dir = NaN*ones(1,length(u_4))';

% sector 0 - 90 deg
ind = find(u_4 >= 0 & v_4 >=0);
dir(ind) = atan(abs(v_4(ind)./u_4(ind)))*180/pi + 0;

% sector 90 - 180 deg   
ind = find(u_4 < 0 & v_4 >=0);
dir(ind) = atan(abs(v_4(ind)./u_4(ind)))*180/pi + 90;

% sector 180 - 270 deg
ind = find(u_4 < 0 & v_4  < 0);
dir(ind) = atan(abs(v_4(ind)./u_4(ind)))*180/pi + 180;

% sector 270 - 360 deg
ind = find(u_4 >= 0 & v_4  < 0);
dir(ind) = atan(abs(v_4(ind)./u_4(ind)))*180/pi + 270;

% azimuth rotation for transducer offset
transducer_offset = 30;
dir = dir - transducer_offset;
ind = find(dir < 0);
dir(ind) = dir(ind) + 360;  

% azimuth rotation for solent orientation offset
orientation_offset = 238;
dir = dir + orientation_offset;
ind = find(dir >= 360);
dir(ind) = dir(ind) - 360;  





