%
% boris96.m
%
%
%   Data exporting for BORIS 1996
%
%
% (c) Zoran Nesic               File created:       Feb 18, 1997
%                               Last modification:  May  4, 1997
%
% Revisions:
%
%       May 4, 1997:        Changed units for CO2 flux to ppm/m2/s,
%                           see line tmp = tmp * 1000 / 44;
%
%

BadDataFlag = 1e38;                                     % this number is used to flag bad/non-existant data
CalDataFlag = 1e38;                                     % this number is used to flag LICOR calibration data
outputFileName = 'd:\boris97\paoa_bor.dat';             % output file name

%---------------------------------
% Set file paths for each data set
%---------------------------------
filePaths = str2mat(    'r:\paoa\newdata\bonet\',...
                        'r:\paoa\newdata\aesmet\',...
                        'r:\paoa\newdata\aessoil\',...
                        'r:\paoa\newdata\aessoil\',...
                        'h:\zoran\paoa\');

%--------------------------------------------------
% For each channel/file set the corresponding path
%--------------------------------------------------
pathsForChannels = [    1 1 2 2 1 1 1 1 1 1 ...
                        1 3 3 3 3 3 5 5 5 ...
                        5 5 5 5 5 5 5 5 5 ...
                        3 3 3 3 3 3 3 3 3 ...
                        3 3 3 3 3 3 3 4 4 ...
                        4 3 3 2 2 2 2];
                        
%---------------------------------
% Create file names 
%---------------------------------                        
fileNames = str2mat(    [deblank(filePaths(1,:)) 'bnt.5'],...
                        [deblank(filePaths(1,:)) 'bnt.6'],...
                        [deblank(filePaths(2,:)) 'met.6'],...
                        [deblank(filePaths(2,:)) 'met.7'],...
                        [deblank(filePaths(1,:)) 'bnt.7'],...
                        [deblank(filePaths(1,:)) 'bnt.8'],...
                        [deblank(filePaths(1,:)) 'bnt.9'],...
                        [deblank(filePaths(1,:)) 'bnt.22'],...
                        [deblank(filePaths(1,:)) 'bnt.23'],...
                        [deblank(filePaths(1,:)) 'bnt.24']);
fileNames = str2mat(    fileNames,...                        
                        [deblank(filePaths(1,:)) 'bnt.28'],...
                        [deblank(filePaths(3,:)) 'soil.64'],...
                        [deblank(filePaths(3,:)) 'soil.65'],...
                        [deblank(filePaths(3,:)) 'soil.66'],...
                        [deblank(filePaths(3,:)) 'soil.67'],...
                        [deblank(filePaths(3,:)) 'soil.68'],...
                        [deblank(filePaths(5,:)) 'paoa_5.2_2'],...
                        [deblank(filePaths(5,:)) 'paoa_8.2_2'],...
                        [deblank(filePaths(5,:)) 'paoa_10.1_2']);
fileNames = str2mat(    fileNames,...                        
                        [deblank(filePaths(5,:)) 'paoa_9.1_2'],...
                        [deblank(filePaths(5,:)) 'paoa_12.1_2'],...
                        [deblank(filePaths(5,:)) 'paoa_27.2_2'],...
                        [deblank(filePaths(5,:)) 'paoa_87.2_2'],...
                        [deblank(filePaths(5,:)) 'paoa_44.2_2'],...
                        [deblank(filePaths(5,:)) 'paoa_81.2_2'],...
                        [deblank(filePaths(5,:)) 'paoa_82.2_2'],...
                        [deblank(filePaths(5,:)) 'paoa_84.2_2'],...
                        [deblank(filePaths(5,:)) 'paoa_46.2_2']);
fileNames = str2mat(    fileNames,...                        
                        [deblank(filePaths(3,:)) 'soil.8'],...
                        [deblank(filePaths(3,:)) 'soil.9'],...
                        [deblank(filePaths(3,:)) 'soil.10'],...
                        [deblank(filePaths(3,:)) 'soil.11'],...
                        [deblank(filePaths(3,:)) 'soil.12'],...
                        [deblank(filePaths(3,:)) 'soil.13'],...
                        [deblank(filePaths(3,:)) 'soil.16'],...
                        [deblank(filePaths(3,:)) 'soil.17'],...
                        [deblank(filePaths(3,:)) 'soil.18']);
fileNames = str2mat(    fileNames,...
                        [deblank(filePaths(3,:)) 'soil.19'],...
                        [deblank(filePaths(3,:)) 'soil.20'],...
                        [deblank(filePaths(3,:)) 'soil.21'],...
                        [deblank(filePaths(3,:)) 'soil.22'],...
                        [deblank(filePaths(3,:)) 'soil.23'],...
                        [deblank(filePaths(3,:)) 'soil.24'],...
                        [deblank(filePaths(3,:)) 'soil.25'],...
                        [deblank(filePaths(4,:)) 'soil2.5'],...
                        [deblank(filePaths(4,:)) 'soil2.6']);
fileNames = str2mat(    fileNames,...                        
                        [deblank(filePaths(4,:)) 'soil2.7'],...
                        [deblank(filePaths(3,:)) 'soil.14'],...
                        [deblank(filePaths(3,:)) 'soil.15'],...
                        [deblank(filePaths(2,:)) 'met.10'],...
                        [deblank(filePaths(2,:)) 'met.11'],...
                        [deblank(filePaths(2,:)) 'met.13'],...
                        [deblank(filePaths(2,:)) 'met.54'] ...
                        );
[N,M] = size(fileNames);
[pathN,pathM] = size(filePaths);

%---------------------------------------
% read Date, DOY, Start time, Stop time,
%---------------------------------------
t = read_bor([deblank(filePaths(5,:)) 'paoa_dt']);          % read time vector
fullLength = length(t);                                     % full length of a data base set

startIndex = find(t == 91) + 1;                             % find Apr  1, 1996, 00:30, (leap year)
stopIndex  = find(t == 335);                                % find Nov 30, 1996, 24:00, (leap year)
Index = startIndex:stopIndex;                               % find the index vector
dataLen = length(Index);

t = t(Index) + 1;                                           % decimal DOY
DOY = floor(t);                                             % DOY
DateX = read_bor([deblank(filePaths(5,:)) 'paoa_d'],4);     %
DateX = DateX(Index,:);                                     % Date
stopTime = read_bor([deblank(filePaths(5,:)) 'paoa_t'],5);  %
startTime = stopTime(Index-1,:);                            % start time
stopTime = stopTime(Index,:);                               % stop  time

%-----------------------------------------
% create and index pointing at LICOR
% calibration times (6:30GMT). These data
% will be removed later on.
%-----------------------------------------
calibIndex = 14:48:fullLength; %dataLen;

%-----------------------------------
% read flag files
%-----------------------------------

flags = zeros(fullLength,pathN);

flag_Bonet = read_bor([deblank(filePaths(1,:)) 'bnt_f1'],2,7);
flags(:,1) = get_flag(flag_Bonet,1);

flag_Met = read_bor([deblank(filePaths(2,:)) 'met_f1'],2,7);
flags(:,2) = get_flag(flag_Met,1);

flag_Soil = read_bor([deblank(filePaths(3,:)) 'soil_f1'],2,9);
flags(:,3) = get_flag(flag_Soil,1);

flag_Soil2 = read_bor([deblank(filePaths(4,:)) 'soil2_f1'],2,1);
flags(:,4) = get_flag(flag_Soil2,1);

flag_Eddy = read_bor([deblank(filePaths(5,:)) 'paoa_f1'],2,11);
flags(:,5) = get_flag(flag_Eddy,1);

%-----------------------------------
% read data files
%-----------------------------------

dataOut = zeros(dataLen,N);
fprintf('\n\nLoading %d files: ',N);
for i=1:N
    fprintf('%d ',i);
    tmp = read_bor(deblank(fileNames(i,:)));
    if i == 28
        tmp = tmp * 1000 / 44;                                      % change CO2 units from mg/m2/s to ppm m/s
    end
    if any( i == [19 20 26 28] )
        tmp(calibIndex) = CalDataFlag * ones(size(calibIndex));    % replace LICOR calibration with CalDataFlag
    end
    ind = find(flags(:,pathsForChannels(i)) == 0);                  % find non-existant data
    tmp(ind) = BadDataFlag * ones(size(ind));                       % and replace zeros with BadDataFlag
    dataOut(:,i) = tmp(Index);
    if i == 52
        tmpInd = find(t>319);
        dataOut(tmpInd,i) = BadDataFlag * ones(size(tmpInd));       % remove bad data from Rs_down
    end
end
fprintf('\n');

%------------------------------
% Print data
%------------------------------

formatX = '%s%4d %s %s ' ;
for i=1:N
    formatX = [formatX '%13.4e'];           % create the formating line
end
formatX = [formatX '\x0d\x0a'];

fid = fopen(outputFileName,'w');
for i=1:dataLen
    fprintf(fid,formatX,DateX(i,[9 10 1 2 4 5]),DOY(i),startTime(i,[1:2 4:5]),stopTime(i,[1:2 4:5]),dataOut(i,:));
end
fclose(fid);





% COLUMN KEY
% 
% COL     VARIABLE                        UNITS                   OUTPUT ARRAY
% 
% 1       date                             yymmdd
% 2       day of year                      DOY
% 3       beginning time                   hhmm
% 4       ending time                      hhmm
% 5       AIR_TEMP_HMP_38M                (DEG C)                 bonet.5
% 6       RH_HMP_38M                      (%)                     bonet.6
% 7       WIND_SPEED_VECTOR_38M           (m s^-1)                met.6
% 8       WIND_DIR_RMY_38M                (DEG FROM TRUE NORTH)   met.7
% 9       NET_RAD_UBC._30M                (W m^-2)                bonet.7
% 10      PAR_DOWN_36M                    (micromol m^-2 s^-1)    bonet.8
% 11      PAR_up_36M                      (micromol m^-2 s^-1)    bonet.9
% 12      RS_DOWN_36M                     (W m^-2)                bonet.22
% 13      RS_UP_36M                       (W m^-2)                bonet.23
% 14      RL_DOWN_36M                     (W m^-2)                bonet.24
% 15      RL_UP_36M                       (W m^-2)                bonet.28
% 16      TREE_TEMP_00.2CM                (DEG C)                 soil.64
% 17      TREE_TEMP_04.0CM                (DEG C)                 soil.65
% 18      TREE_TEMP_08.0CM                (DEG C)                 soil.66
% 19      TREE_TEMP_12.0CM                (DEG C)                 soil.67
% 20      TREE_TEMP_15.8CM                (DEG C)                 soil.68
% 21      WIND_U_COMPONENT_39M_PG2_PORT2  (m s^-1)                paoa_5.2_2
% 22      AIR_TEMP_SOLENT_39M_PG2_PORT2   (DEG C)                 paoa_8.2_2
% 23      H2O_CONC_LICOR_39M_PG1_PORT2    (mmol mol^-1)           paoa_10.1_2
% 24      CO2_CONC_39M_PG1_PORT2          (micromol mol^-1)       paoa_9.1_2
% 25      AIR_PRESS_BAROMETER_PG1_PORT2   (kPa)                   paoa_12.1_2
% 26      COV_U^W_39M_PG1_PORT2           (m^2 s^-2)              paoa_27.2_2
% 27      USTAR_39M_PORT2                 (m s^-1)                paoa_87.2_2
% 28      VAR_W^W_39M_PG1_PORT2           (m^2 s^-2)              paoa_44.2_2
% 29      H_39M_PORT2                     (W m^-2)                paoa_81.2_2
% 30      LE_LICOR_39M_PORT2              (W m^-2)                paoa_82.2_2
% 31      BOWEN_RATIO_LICOR_39M_PORT2                             paoa_84.2_2
% 32      CO2_FLUX_39M_PG2_PORT2          (mg m^-2 s^-1)          paoa_46.2_2
% 33      SOIL_TEMP_2CM                   (DEG C)                 soil.8
% 34      SOIL_TEMP_5CM                   (DEG C)                 soil.9
% 35      SOIL_TEMP_10CM                  (DEG C)                 soil.10
% 36      SOIL_TEMP_20CM                  (DEG C)                 soil.11
% 37      SOIL_TEMP_50CM                  (DEG C)                 soil.12
% 38      SOIL_TEMP_100CM                 (DEG C)                 soil.13
% 39      SOIL_HEAT_FLUX_3CM_1            (W m^-2)                soil.16
% 40      SOIL_HEAT_FLUX_3CM_2            (W m^-2)                soil.17
% 41      SOIL_HEAT_FLUX_3CM_3            (W m^-2)                soil.18
% 42      SOIL_HEAT_FLUX_3CM_4            (W m^-2)                soil.19
% 43      SOIL_HEAT_FLUX_3CM_5            (W m^-2)                soil.20
% 44      SOIL_HEAT_FLUX_3CM_6            (W m^-2)                soil.21
% 45      SOIL_HEAT_FLUX_3CM_7            (W m^-2)                soil.22
% 46      SOIL_HEAT_FLUX_3CM_8            (W m^-2)                soil.23
% 47      SOIL_HEAT_FLUX_3CM_9            (W m^-2)                soil.24
% 48      SOIL_HEAT_FLUX_8CM              (W m^-2)                soil.25
% 49      SOIL_WATER_POTENTIAL_GYP_3CM    (BARS)                  soil2.5
% 50      SOIL_WATER_POTENTIAL_GYP_6CM    (BARS)                  soil2.6
% 51      SOIL_WATER_POTENTIAL_GYP_46CM   (BARS)                  soil2.7 
% 52      SOIL_TEMP_INT                   (DEG C)                 soil.14
% 53      SOIL_TEMP_INT                   (DEG C)                 soil.15
% 54      AIR_TEMP_38m                    (DEG C)                 met.10
% 55      RH_AIR_38m                      (%)                     met.11
% 56      RS_DOWN                         (W m^-2)                met.13
% 57      PRICIPITATION                   (mm)                    met.54
%