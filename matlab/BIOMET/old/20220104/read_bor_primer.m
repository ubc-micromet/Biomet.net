% read_bor_primer
%
%
%
%
%
% Zoran Nesic           File created:       Jan 10, 2000
%                       Last modification:  Jan 11, 2000


% This file is intended to serve as a manual (learning through examples)
% of how to read data from the Biomet data base. Data base changes introduced in Jan 2000
% required changes in the main data-reading program: read_bor.m. The current version
% is meant to work in the same way as the old one if the new optional arguments are not
% used.

%
% Important note:
%   - data base for years 1996 - 1999 (inclusive) is all under 
%     the folder for the year 1999. The data traces are continuous (4-year long).
%   - the new data (year 2000->) will be separated into 1 year data chunks
%     (folders 2000, 2001, ...)
%


% the following statement will read a continuous trace fr_a.3 from the data base
% running from 1996 till Dec 31, 1999.
x = read_bor('\\annex001\database\1999\cr\Climate\fr_a\fr_a.3'); 

% due to the changes in the data base structure
% the following statement will read a continuous trace fr_a.3 from the data base
% running from Jan 1, 2000 till Dec 31, 2000. Every new year a new folder with
% the new-years data base will be created.
x = read_bor('\\annex001\database\2000\cr\Climate\fr_a\fr_a.3'); 

% The syntax given above will be supported in the future so the old programs
% are not affected with the data base and read_bor.m changes.


%------------------- FOR NEW PROGRAMS ------------------------------
%
% The proper way to write new programs:
% (proper in a sense that it will be supported in the future versions,
%  new changes in the database path will be user transparent,
%  in a few words: it will reduce the corrections to your programs
%  due to the events outside of your control)
% 

pth = biomet_path(2000,'cr','cl');          % find data base path for year = 2000
                                            % and fill in the defaults (site name, data type)
tv = read_bor([pth 'fr_a\fr_a_tv'],8);      % load the time vector 
[DOY,year] = fr_get_doy(tv,0);              % calculate DOY (Campbell format) from tv
x = read_bor([pth 'fr_a\fr_a.3']);          % load a trace
plot(DOY,x)                                 % use data

pth = biomet_path(1999,'bs','fl');          % find data base path for year = 1999,
                                            % site Black Spruce, flux data
tv = read_bor([pth 'flxad_tv'],8);          % load the time vector 
[DOY,year] = fr_get_doy(tv,0);              % calculate DOY (Campbell format) from tv
x = read_bor([pth 'flxad.3']);              % load a trace
plot(DOY,x)                                 % use data


% to extract a time period use:
pth = biomet_path(2000,'cr','cl');          % find data base path for year = 2000
                                            % and fill in the defaults (site name, data type)
tv = read_bor([pth 'fr_a\fr_a_tv'],8);      % load the time vector 
indOut = find(tv > datenum(2000,1,1) & ...
          tv <= datenum(2000,1,31,23,30,2));% extract Jan 1, 200 -> Jan 31, 2000, 23:30
[DOY,year] = fr_get_doy(tv(indOut),0);      % calculate decimal DOY  from tv
x1 = read_bor([pth 'fr_a\fr_a.2'],[],[],[],indOut); % load a short trace 
x2 = read_bor([pth 'fr_a\fr_a.3'],[],[],[],indOut); % load a short trace 
x3 = read_bor([pth 'fr_a\fr_a.4'],[],[],[],indOut); % load a short trace 
plot(DOY,x1,DOY,x2,DOY,x3)                  % use data

% note that above program works way faster than the combination of:
    % tv = read_bor([pth 'fr_a\fr_a_tv'],8);      % load the time vector 
    % indOut = find(tv > datenum(2000,1,1) & ...
    %      tv <= datenum(2000,1,31,23,30,2));% extract Jan 1, 200 -> Jan 31, 2000, 23:30
    % x = read_bor([pth 'fr_a\fr_a.3']); 
    % x = x(indOut)
% because the read_bor will load up only the data it needs



% to join a few years and extract a time period use:

pth = biomet_path('yyyy','cr','cl');        % find data base path for year = 'yyyy' 
                                            % and fill in the defaults (site name, data type)
Years = [1998:2000];
tv = read_bor([pth 'fr_a\fr_a_tv'],8,[],Years);      % load the time vector 
indOut = find(tv > datenum(1998,5,1) & ...
          tv <= datenum(2000,1,31,23,30,2));% extract May 1, 1998 -> Jan 31, 2000, 23:30
x = read_bor([pth 'fr_a\fr_a.3'],[],[],Years,indOut); % load a short trace 
plot(tv(indOut),x)                          % use data


% to join a few years and get a continuous decimal time trace (_dt)

pth = biomet_path('yyyy','cr','cl');        % find data base path for year = 'yyyy' 
                                            % and fill in the defaults (site name, data type)
Years = [1998:2000];
tv = read_bor([pth 'fr_a\fr_a_tv'],8,[],Years);% load the time vector 
x = read_bor([pth 'fr_a\fr_a.3'],[],[],Years); % load a short trace 
ind = find( tv > datenum(Years(1),1,1) & tv <= datenum(Years(end)+1,1,1));
x = x(ind);
tv = tv(ind);
dt = tv - tv(1);                            % create a "dt" trace
plot(dt,x)                                  % use data

% To join a few years of highlevel cleaned data
% the override_1999 flag (last argument of read_bor has to be 1
pth = biomet_path('yyyy','cr','high_level'); % find data base path for year = 'yyyy' 
                                            % and fill in the defaults (site name, data type)
Years = [1998:2000];
tv = read_bor([pth 'clean_tv'],8,[],Years,[],1);% load the time vector 
x = read_bor([pth 'fc_main'],[],[],Years,[],1); % load a short trace 
plot(tv,x)                                  % use data

% To join a few years of lowlevel cleaned climate data
% the override_1999 flag (last argument of read_bor has to be 1
% and the 'clean' has to be added to the path 
pth = biomet_path('yyyy','cr','cl');        % find data base path for year = 'yyyy' 
                                            % and fill in the defaults (site name, data type)
Years = [1998:2000];
tv = read_bor([pth 'clean\clean_tv'],8,[],Years,[],1);% load the time vector 
x = read_bor([pth 'clean\barometric_pressure'],[],[],Years,[],1); % load a short trace 
plot(tv,x)                                  % use data

% to convert time vector to a readable format:
datestr(tv(3))                              % date and time of the third sample
datestr(tv(end))                            % date and time of the last sample
datestr(now)                                % current date and time
