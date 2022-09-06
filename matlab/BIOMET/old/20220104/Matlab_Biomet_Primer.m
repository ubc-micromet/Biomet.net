
% Read first: read_bor_primer.m
% type "edit read_bor_primer" at the Matlab prompt >>


pth = biomet_path('yyyy','pa','high_level');    % path to data from Prince Albert site ('pa')
pth = biomet_path('yyyy','cr','high_level');    % path to data from Campbell River site ('cr')
Years = [1998:2000];                            % years of data to be loaded up
tv = read_bor([pth 'clean_tv'],8,[],Years,[],1);% load the time vector
Tair = read_bor([pth 'air_temperature_main'],[],[],Years,[],1); % load a short trace (air temp. main)
Fc = read_bor([pth 'Fc_main'],[],[],Years,[],1); % load CO2 flux
Precip = read_bor([pth 'precipitation'],[],[],Years,[],1); % load precipitation

x = [1 5 3 9 6 10 2 4]                      % pretend data set of 8 points (values)
ind = find(x>=5)                            % find indexes of all point where x is greater of equal 5
x(ind)                                      % show data values when x >= 5

x = [1 5 2 100;2 4 3 65; 3 6 4 124]
x(1,:)                                      % show first column
x(:,4)                                      % show 4th row
x(2:3,2:3)                                  % show a submatrix [ x(2,2), x(2,3)
                                            %                    x(3,2), x(3,3) ]

ind = find(Tair >= 5 & Tair <=20);              % find index of 30 minute periods where 5 <= Tair <= 20
plot(tv(ind),Tair(ind));                        % plot air temp. range for the range above
plot(tv(ind),Fc(ind));                          % plot fluxes only for the air temp. range above
title('My first graph')                         % add the title
legend('Fc')                                    % add legend
xlabel('Date')                                  % add xlabel
ylabel('Date')                                  % add ylabel

ind = find(Precip > 5);              % find date and time when it rained more than 5 mm/30 minutes
tv(ind)'                             % show time vector for the rain events above. Time vector are
                                     % numbers (integer number of days
                                     % since Jan 0, 0000)
datestr(tv(ind))                     % Show the same time/dates but in a  "human readable form"

timePeriod = find(tv >= datenum(2000,3,1) & tv <= datenum(2000,3,31,24,0,0)); %select March 2000 data
plot(tv(timePeriod),Fc(timePeriod))                                           %plot Fc for March
datetick('x')                                                                 %convert time to MM/DD

% select March 2000 data using a function (select_March_2000)
[march2000,Fc_March2000] = select_March_2000(tv,Fc)
plot(march2000,Fc_March2000)


help datetick
help find
help plot
help datestr
help datenum
help biomet_path


% this needs to be saved as a separate file named "select_March_2000.m"
function [timeV,Fc_selected] = select_March_2000(tv_In,Fc_In)
 indTimeV = find(tv_In >= datenum(2000,3,1) & tv_In <= datenum(2000,3,31,24,0,0)); %select March 2000 data
 Fc_selected = tv_In(indTimeV);
 timeV = tv_In(indTimeV);
 
 






