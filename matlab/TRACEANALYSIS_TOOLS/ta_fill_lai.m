function lai_trace = ta_fill_lai(Xyear,SiteID,flag_);

% This function will take measured LAI and interpolate the missing values.
% Measured values are from pt. qd. method or LAI-2000 and are entered into
% the function body.  Output is an LAI (projected) trace should be considered
% valid for the growing season only. This function only works for BC FluxNet sites!
%
% Arguments:
% SiteID - 2-letter (short name) site abbr.
% Xyear  - single calendar year (yyyy format).
% flag_  - toggles output style: "1" = lai_main, "0" = lai_measured (see primer)
% 
% For more details read the primer in the function body.
%
% (c) Christopher R Schwalm  Sep 11 2004
% Last update/data entry: Oct 3 2005

% \\PAOA001\matlab\TraceAnalysis_Tools\ta_fill_lai.m
%
% There is currently no automated means to capture/log LAI.  The data are
% entered here manually.  As these data are collected only once every 2-6 wk
% this is doable.  Ideally data should span the growing season from May 15
% to Oct 15 or DOY 135:288.  In addition to this measurements just before
% and just after the growing season are desireable.  Ultimately the goal is
% a record of LAI measurements from roughly DOY 130 to DOY 300 with a 2
% wk gap between measurements.  This ideal has not been realised...
%
% How to add data and use this function:
% After each measurement the data should be entered into the body of this
% function.  If replicates are available (e.g., LAI 2000) simply use the
% mean of all values for a particular site/day.  The DOY of the measurement is
% also needed.  Depending on when measurements are available you may have
% to make an educated guess as to LAI on DOY 130 and 300.  Do not forget to
% generate these values as they help the interpolation process. The traces
% created here should be failry robust for the growing season and these
% extra points help avoid boundary effects...
%
% Note also that the LAI 2000 measures effective LAI as opposed to true
% LAI.  These two are related by a clumping correction factor or ratio.
% (see Chen et al. 1997 in JOURNAL OF GEOPHYSICAL RESEARCH, VOL. 102, 
% NO. D24, PAGES 29,429-29,443, DECEMBER 26, 1997).  For OY this is not
% a non-issue. For YF a multiplier is applied (see function body). For
% CR, LAI-2000 readings of the overstory should be divided by 0.48 (from
% Elyn's thesis). However, we assume that LAI is a constant 8.4 (this is 
% most certainly incorrect but close enough for government work).
%
% This function is called in third stage cleaning by the proper ini files.
% If the "flag_" is set to "1" then "lai_main" is generated.  This is the
% best estimate of LAI based on a simple fitting procedure and does not
% contain the measured values unless they happen to lie on the curve.  If
% "flag_" is set to "0" then a trace containing just the actual measured
% values is generated (i.e., lai_measured).

% Enough arguments?
if nargin ~= 3
    error('Invalid arguments!  Try "help ta_fill_lai".')
end
SiteID = upper(SiteID);

% Data is entered here...  "doy_in" is a vector containing the DOY for each
% measurements; "lai_in" is the LAI value for that day; "guess" is either
% zero if the value was measured or "1" if an educated guess was made to get
% the data to range from DOY 130 to 300.

if strcmp('OY',SiteID) & Xyear == 2000
    error('No LAI measurements exist for this year!');
    
elseif strcmp('OY',SiteID) & Xyear == 2001
    doy_in = [300];
    lai_in = [0.24];
    guess =  [0];
    disp(' ');
    disp('Too sparse to generate a trace using interpolation!');
    disp(['Only one measurement of ' num2str(lai_in) ' on DOY ' num2str(doy_in) ' was made.']);
    disp('If you are desperate for an LAI trace for this site yr then take');
    disp('the trace for OY 2002 and multiply by .25 --this must be done manually...');
    disp(' ');
    disp('Defaulting to NaNs for all unmeasured DOYs...');
    
elseif strcmp('OY',SiteID) & Xyear == 2002
    doy_in = [107, 157, 178, 206, 233, 268, 307];
    lai_in = [0.57, 1.79, 2.18, 2.17, 1.64, 1.19, 0.92];
    guess =  [0,0,0,0,0,0,0];
    
elseif strcmp('OY',SiteID) & Xyear == 2003
    doy_in = [130, 149, 177, 205, 233, 262, 300];
    lai_in = [0.7, 1.91, 2.53, 2.06, 1.15, 0.93, 0.8];
    guess =  [1,0,0,0,0,0,1];
    
elseif strcmp('OY',SiteID) & Xyear == 2004
    doy_in = [112, 139, 166, 194, 252, 301];
    lai_in = [0.82, 1.49, 2.02, 2.18, 1.21, 0.9];
    guess  = [0, 0, 0, 0, 0, 1];
   
elseif strcmp('OY',SiteID) & Xyear == 2005
    doy_in = [110, 124, 132, 160, 182, 229, 263];
    lai_in = [0.7, 0.94, 0.69, 1, 1.65, 2.04, 1.7];
    guess  = [1, 1, 1, 1, 0, 1, 1, 0];
    
elseif strcmp('YF',SiteID) & Xyear == 2001
    error('No LAI measurements for this year exist');
    
elseif strcmp('YF',SiteID) & Xyear == 2002    
    doy_in = [130, 137, 158, 179, 206, 221, 235, 269, 292, 308];
    lai_in = [1.85, 2.12, 2.77, 4.63, 3.77, 4.82, 3.67, 4.03, 3.06, 2.85];
    guess  = [1,0,0,0,0,0,0,0,0,0];
    
elseif strcmp('YF',SiteID) & Xyear == 2003
    doy_in = [130, 145, 163, 177, 190, 204, 218, 232, 247, 261, 274, 307];
    lai_in = [2.25, 3.5, 4.72, 4.41, 5.12, 4.44, 4.47, 4.43, 3.87, 3.91, 3.87, 2.71];
    guess  = [1,1,0,0,0,0,0,0,0,0,0,0];
    
elseif strcmp('YF',SiteID) & Xyear == 2004
    doy_in = [112, 138, 166, 252, 301];
    lai_in = [2.66, 3.34, 4.69, 3.23 2.8];
    guess  = [0, 0, 0, 0 1];
    
elseif strcmp('YF',SiteID) & Xyear == 2005
    doy_in = [110, 124, 132, 160, 182, 229, 263];
    lai_in = [2.2, 3.18, 2.91, 4.34, 4.69, 5.14, 5.00];
    guess  = [1, 1, 1, 1, 0, 1, 1];

elseif strcmp('CR',SiteID)
    disp(' ');
    disp('LAI at the CR site is assumed to equal 8.4 since 1997 (crown closure).')
    disp('ALL values set to 8.4');
    disp(' ');
    lai_in = [8.4];
else
    error('Not a valid year and/or site for BC FluxNet, aborting...')
end
    
if strcmp('YF',SiteID)
    lai_in = lai_in.*1.4; % see Humprehys et al. 2005 Carbon dioxide fluxes in three coastal Douglas-fir stands
    % at different stages of development after harvesting in GCB correction
    % factor for LAI-2000 measurements; this is R from the PCA manual...
end

% load reference tv
try
    tv  = evalin('caller','clean_tv');
catch
    pth = biomet_path(Xyear,SiteID,'Clean\ThirdStage');
    tv  = read_bor([pth 'clean_tv'],8);      
end

% wraparound/tweak tv (tv as is has last day in year as DOY = 1 of following year!)
DOY = fr_get_doy(tv,0); DOY = DOY-0.0208;
DOY(length(DOY))=DOY(length(DOY)-1)+0.0208;    

% fit polynomial to real data (only over span of actual data!) --first get
% poly. order based on length of measurement vector
Xorder = min(length(lai_in)-2,4);
if length(lai_in) == 3
    Xorder = 2;
elseif length(lai_in) < 3
    Xorder = 0;
end

% if enough measurements present and lai_main is desired then polyfit...
if Xorder > 0 & flag_ == 1
    % polyfit here...
    % warning off MATLAB:polyfit:RepeatedPointsOrRescale;
    p = polyfit(doy_in,lai_in,Xorder);
    % warning on MATLAB:polyfit:RepeatedPointsOrRescale;
    lai_poly = polyval(p,DOY);
    % remove bogus fitted values using cutoffs
    ind_select = find(DOY < doy_in(1)); 
    lai_poly(ind_select) = lai_in(1);  % constrains pre-growing season to first measurement (hopfully before and close to DOY = 135)
    ind_select = find(DOY > doy_in(end));
    lai_poly(ind_select) = lai_in(end); % constrains post growing season values to last measured value (hopefully in November: DOY > 300)
    ind_select = find(lai_poly < lai_in(1) & DOY < doy_in(2));
    lai_poly(ind_select) = lai_in(1); % smoothes function toward boundary of measurements
    ind_select = find(lai_poly < lai_in(end) & DOY > doy_in(end-1));
    lai_poly(ind_select) = lai_in(end); % smoothes function toward boundary of measurements
    % screen dump
    disp(' ');
    disp(['The maximum LAI of ' num2str(max(lai_poly)) ' was on DOY = ' num2str(ceil(DOY(find(lai_poly==max(lai_poly))))) '.']);
    disp(' ');
end

if flag_ == 1 & Xorder == 0 & ~strcmp('CR',SiteID)
    disp(' ');
    disp('Too few data points to interpolate, defaulting too all NaN''s...');
    disp(' ');
    lai_trace = NaN.*ones(size(DOY)); % lai_main forced to all NaNs if too few points
elseif flag_ == 1 & Xorder ~= 0 & ~strcmp('CR',SiteID)
    lai_trace = lai_poly; % lai_main in previous yr
         tm = datevec(now);
         if tm(1) == Xyear
             ind = find(DOY > fr_get_doy(now));
             lai_trace(ind) = NaN;  % lai_main with rest of current year as Nan
         end
elseif flag_ == 0 & ~strcmp('CR',SiteID)
    lai_trace = NaN.*ones(size(DOY));
    ind_real = find(guess==0);
    doy_in = doy_in(ind_real); lai_in = lai_in(ind_real);
    [C,IA,IB] = INTERSECT(floor(DOY),doy_in);
    lai_trace(IA) = lai_in; % lai_measured
elseif strcmp('CR',SiteID)
    lai_trace = 8.4.*ones(size(DOY)); % special case for CR...
end