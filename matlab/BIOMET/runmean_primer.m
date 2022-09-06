% This script explains the use of the fast_avg, runmean and fr_fill_with_mdv
% functions and uses them to show how to easily do mean diurnal courses

% kai* June 13, 2002

close all;
clear all;

% Load some interesting data
get_traces_db('CR',[1998:2001],'clean\secondstage',{'clean_tv' 'nee_main'});

%----------------------------------------------------------------------
% 1 - Comparing fastavg and runmean
%
%----------------------------------------------------------------------

% Do 5-day averages and gauge the speed of both functions
tic;
[nee_avg_f,nee_nan_f]     = fastavg(nee_main,5*48);
toc;
tic;
[nee_avg_r,ind,nee_std,nee_nan_r] = runmean(nee_main,5*48,5*48);
toc;

% These plots just shows that both functions do the same thing
figure;
plot([nee_avg_f-nee_avg_r]);
figure
plot([nee_nan_f-nee_nan_r]);

% fastavg does the averaging considerably faster, but if you can wait 
% a fraction of a second you might want to consider using runmean.
% It offers some features that are really great and make it a function that
% is far superior to the simplistic littel piece of code assembled by Zoran.
% Plus, frankly, I hate being outprogrammed and I do think everybody should
% use my stuff. I will also apply for a position
% with the Microsoft Windows Enforcement Squad next week.

%----------------------------------------------------------------------
% 2 - Enhanced features of runmean
%
%----------------------------------------------------------------------
% 1) Time vector plotting using the index
figure;
[nee_avg,ind] = runmean(nee_main,5*48,5*48);
plot(clean_tv(ind),nee_avg);

% 2) Continous running average using the step argument
figure;
[nee_avg,ind] = runmean(nee_main,5*48,1);
plot(clean_tv,nee_main,clean_tv,nee_avg);

% 3) Running standard deviations along with averages
figure;
[nee_avg,ind,nee_std,nee_n] = runmean(nee_main,5*48,5*48);
plot(clean_tv(ind),nee_avg,clean_tv(ind),nee_avg+nee_std,clean_tv(ind),nee_avg-nee_std);
% You may ask yourself whether this type of standard deviation actually makes sense.
% Therefore, we go to some application where is might be a bit easier to interpret

% 4) Running statistics for matrices
% To show the power of this feature we use it to calculate mean diurnal courses
get_traces_db('CR',[2001],'clean\secondstage',{'clean_tv' 'nee_main'});

nee_daily = reshape(nee_main,48,365)'; % This puts each half hour in a separate column
[nee_mdv, ind_avg, nee_mdv_std]= runmean(nee_daily,5,5);

% This allows us to plot the so called finger print
figure;
surf(nee_mdv)
view(2)

%----------------------------------------------------------------------
% 3 - fr_fill_with_mdv
%
%----------------------------------------------------------------------

% The function fr_fill_with_mdv uses some of the techniques shown above
% to calculate a mean diurnal variation and fill a trace using that kind
% of average
get_traces_db('CR',[1998:2001],'clean\secondstage',{'clean_tv' 'nee_main'});

[nee_filled,nee_avg,nee_std,nee_mdv] = fr_fill_with_mdv(nee_main,10);

% Now we can do the finger print for all the data ...
figure;
surf(nee_mdv)
view(2)

% ... as well as get an estimate on variability using nee_std
figure;
plot(clean_tv,nee_filled,clean_tv,nee_avg+nee_std,clean_tv,nee_avg-nee_std);
