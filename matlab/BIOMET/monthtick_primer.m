% This script explains the use of the monthtick, position_labels and yeargrid
% functions and also has some examples how to plot time series data

% kai* June 13, 2002

close all;

%----------------------------------------------------------------------
% Example 1 - Plotting a year of data
%
%----------------------------------------------------------------------
clear all;

% First we get ourselves some data and average it and convert it to 
% NEP in grams per day
get_traces_db('CR',[2001],'clean\secondstage',{'clean_tv' 'nee_main'});
[nee_avg,ind] = runmean(nee_main,5*48,5*48);
nep_avg = -nee_avg .* 12e-6*86400;

% This is the plot that we want to do
figure;
plot(clean_tv(ind),nep_avg);

% To find out where the monthly ticks should be we use monthtick
[tick_val,tick_label] = monthtick(clean_tv(ind),2);

% The output may be used to set the labels and ticks
set(gca,'XTick',tick_val,'XTickLabel',tick_label);

% Unfortunately, these labels sit right at the ticks, as is always
% the case in matlab. To move them to the center between two ticks
% we first have to remove the old labels and then use
% the position_labels function
set(gca,'XTick',tick_val,'XTickLabel','');
h_label = position_labels(gca,tick_val,tick_label);

% This can of course be made a look nicer:
yaxis_range    = [-3 8];
ytick_val      = [-2 0 2 4 6 8];
xaxis_range    = [tick_val(1) tick_val(end)];
axis([xaxis_range yaxis_range])
% Alas, now the labels are not centered anymore, because they are
% text in an axes of their own. To center them again we have to 
% scale that axes properly.
h_plot = gca;
subplot(h_label)
axis([xaxis_range 0 1]);
subplot(h_plot)
% Another way of doing this is of course to use the position_labels
% function only after you have done the scaling.

%----------------------------------------------------------------------
% Example 2 - Plotting multiple years
%
%----------------------------------------------------------------------
clear all;

% The process is essentially the same as above
get_traces_db('CR',[1998:2001],'clean\secondstage',{'clean_tv' 'nee_main'});
[nee_avg,ind] = runmean(nee_main,5*48,5*48);
nep_avg = -nee_avg .* 12e-6*86400;

% This is the plot that we want to do
figure;
plot(clean_tv(ind),nep_avg);

% Monthly ticks again
[tick_val,tick_label] = monthtick(clean_tv(ind),4);

yaxis_range    = [-3 8];
ytick_val      = [-2 0 2 4 6 8];
xaxis_range    = [tick_val(1) tick_val(end)];
axis([xaxis_range yaxis_range])

set(gca,'XTick',tick_val,'XTickLabel','');
h_label = position_labels(gca,tick_val,tick_label);

% To make this more intelligible we can also add vertical and 
% horizontal marker lines at the beginning of each year
h_new = yeargrid(gca)

%----------------------------------------------------------------------
% Example 3 - Changing labels on plots of many years
%
%----------------------------------------------------------------------
% Now suppose you don't like the labels as they are. You can just 
% delete them by deleting their axes
delete(h_label);

% Suppose you only wanted to mark the middle of each year (roughly
% the first of July). monthtick gives you the values if you specify
% a label_offset of 7 (to have the first label in July) and a 
% label_freq of 12 to have one label every year
[tick_val,tick_label] = monthtick(clean_tv(ind),12,7);

% Of course that one label will a boring old J for July. To replace that
% with something more exciting like the number of the year you can do this:
ind_label = find(char(tick_label) ~= ' ');
tick_label(ind_label) = cellstr(num2str([1998:2001]'));

set(gca,'XTick',tick_val,'XTickLabel',tick_label);
% Since we want the labels right at the 1st of July, we do not use 
% position_labels here.

%----------------------------------------------------------------------
% Example 4 - Tick labels on plots of days
%
%----------------------------------------------------------------------
% We now want to plot only some days in July/August
ind_tv = find(clean_tv > datenum(2001,7,27) & clean_tv < datenum(2001,7,27+6));

figure;
plot(clean_tv(ind_tv),nee_main(ind_tv))

% Tick values and labels are easily done from the dates
tick_val   = datenum(2001,7,27:27+6);
tick_label = cellstr(datestr(tick_val,6));

% And then just as above set and position_labels can be used
set(gca,'XTick',tick_val,'XTickLabel','');
h_label = position_labels(gca,tick_val,tick_label);
