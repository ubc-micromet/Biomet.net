%===============================================================
function c = FR_init_all(dateStr)
%===============================================================
%
% (c) Zoran Nesic           File created:       Jan  3, 1998
%                           Last modification:  Apr 16, 1998
%

%
%   Revisions:
%
%   Apr 16, 1998
%       -   reordered setup information
%       -   added more coments
%       -   introduced new configuration parameter: c.ChanReorder
%           that takes care about channel reordering of the raw data
%           so it matches the expected EngUnit channel order
%           (see fr_read_data_files.m)
%   Apr 14, 1998
%       -   found that delay times need to be referenced to the sonic
%           temperature (not w) to get resonable results (high correlations)
%           Hence, the program is going to be using ch.#13 (Ts) as its
%           reference for the delay time calculations. The 
%           channels whose delay times are checked for each hhour are:
%           [6 7 13 3 4 12] -> [co2, h20, Ts, Tc1, Tc2, w]
%   Apr 13, 1998
%       - fixed problem with c.covVector reffering to channel #21 (v_DAQ)
%         for the period before Dec 10, 1997 when that channel hasn't been
%         used. The quick fix was to use channel #2 twice in the covVector
%         (see below).
%       - changed H2O_offset from 14mV to 18mV (14mV was a mistake).
%   Apr 9, 1998
%       -   introduced the "good" calibrations for the Licor. These values
%           are used for the main calculations (Sep 1997 - Mar 1998)
%   Apr 2, 1998
%       -   new config parameter (pressure correction for the tower hight):
%           c.BarometerZ = 40;
%   Mar 30, 1998
%       -   more new config parameters. This time the new filter
%           coeficients are added for the pressure transducers (c.filters.P?.?)
%   Mar 29, 1998
%       -   added new configuration parameter: c.Delays. This
%           is a vector of time delays for each channel (in samples not seconds!)
%           No delay => delay = 0.
%
%       Mar 26, 1998
%           -   added fr_get_local_path function call
%           -   changed covVector from
%                   c.covVector     = [1 2 3 4 8 9 11 12 17 18 19 20];   
%               to
%                   c.covVector     = [1 2 3 4 8 9 11 12 20 19 21 17 18];
%       Feb 26, 1998
%           -    added proper extension for hhour files (.hc.mat)
%       Feb 22, 1998
%           -   added path and extension needed for fr_save_stats
%



%-------------------------------
% Sonic definitions:
%-------------------------------
c.sonic         = 'GILLR2';
c.GillR2chNum   = 5;
c.sonic_poly    = [ 0.012 -30;...
                    0.016 290];             % polynomials for wind speed and speed of sound
c.Orientation   = 240;                      % degrees from North


% covariances to be calculated
% [1:4]         u,v,w,T from Gill
% [8 9]         first two thermocouples on the DBK19
% [11 12]       CO2, H2O
% [20]          kh2o
% [19 21 17 18] u,v,w,T from DAQbook
%
if str2num(dateStr) < 1997121020
    % for the period before Dec 10, 1997 (5amGMT) use Gill_v instead of DAQ_v
    % wind speed (hence channel #2 is used twice in c.covVector)
    c.DAQchNum      = 15;
    c.covVector     = [1 2 3 4 8 9 11 12 20 19 2 17 18];
else                                        
    % Dec 10 ,1997 at 5am GMT DAQ
    % book start logging 20 channels    
    c.DAQchNum      = 20;
    c.covVector     = [1 2 3 4 8 9 11 12 20 19 21 17 18];
end           

%-------------------------------
% DAQ book definitions:
%-------------------------------
c.gains         = [100 240 240 240 ones(1,c.DAQchNum-4)]; 

% define mapping of the actual measured channels to the desired final
% channel position
% DAQ desired channel order:
%  [  1  2   3   4   5    6   7    8     9      10    11  12   13  14   15  16    17    18     19     20 ]
%  [CJC TCo Tc1 Tc2 zero co2 h2o Tcell Plicor Pgauge Pref  w  Tair  u  kh2o  v  free1  free2  free3  Pbar]
%
if str2num(dateStr) < 1997100106
    % before Oct 1, 1997 no Krypton measurements. Use zero channel instead.
    c.ChanReorder = [1:14 5 15];
elseif str2num(dateStr) >= 1997100106 & str2num(dateStr) < 1997121020
    % Between Oct 1 and Dec 10, 1997 we measured Krypton but not v_wind.
    % Use zero channel instead of v.
    c.ChanReorder = [1:15 5];
else
    c.ChanReorder = 1:20;
end    
c.gains  = c.gains(c.ChanReorder);                  % reorder gains to match desired chan.order

%-------------------------------
% LI-COR definitions:
%-------------------------------
c.licor         = 174;
[c.c_poly, ...
 c.h_poly, ...
 c.Tc, ...
 c.Th, ...
 c.Psample_poly] = licor(c.licor);

c.Tbench_poly   = [0.01221 0];
%c.Psample_poly  = [0.01531 59.09];
c.Pgauge_poly   = [0.01226 -5.4201 ];
c.Pref_poly     = [0.4     0.1492];

CO2_offset      = 15;
H2O_offset      = 18;
CO2_gain        = 0.9670;
c.CO2_Cal       = [CO2_gain -CO2_offset];
c.H2O_Cal       = [CO2_gain -H2O_offset];

%-------------------------------
% Krypton definitions:
%-------------------------------
c.KH2O_poly     = [-8.4444 74.737];

%-------------------------------
% Barometric pressure
%-------------------------------
c.Pbar          = [0.0092 60];
c.BarometerZ    = 40;                       % hight difference barometer -> tower top

[c.path,c.hhour_path] = fr_get_local_path;
%c.path          = [ local_path 'data\'];
%c.hhour_path    = [ local_path 'hhour\'];
c.ext           = '.dc';
c.hhour_ext     = '.hc.mat';
c.site          = 'CR';
c.rotation      = 'N';                      % natural rotation

%
% Additional filtering for the pressure transducers
%
c.filters.Pl.b  = fir1(10,0.2);              % Licor (cut-off freq. = 0.2*10.4Hz ~ 2Hz)
c.filters.Pl.a  = 1;

c.filters.Pg.b  = fir1(10,0.2);              % Gauge (cut-off freq. = 0.2*10.4Hz ~ 2Hz)
c.filters.Pg.a  = 1;

c.filters.Pr.b  = fir1(10,0.1);              % Gauge (cut-off freq. = 0.1*10.4Hz ~ 1Hz)
c.filters.Pr.a  = 1;

c.filters.Pb.b  = fir1(10,0.1);              % Barometric (cut-off freq. = 0.1*10.4Hz ~ 1Hz)
c.filters.Pb.a  = 1;

if 1==0                                      % use 1==1 if no filtering required
    c.filters.Pl.b = 1;
    c.filters.Pg.b = 1;
    c.filters.Pr.b = 1;
    c.filters.Pb.b = 1;
end

%
% Delay times (0 - no delay)
%
% c.Delays.All([n1 n2]) -> n1 and n2 refer to the channels described in
%                          stats.BeforeRot.AvgMinMax,
% while in
% c.Delays.Channels([m1,m2]) m1 and m2 refer to the channel numbers of
%                           the DAQ book (as in EngUnits_DAQ)
%         
c.Delays.All = zeros(1,c.DAQchNum+c.GillR2chNum);

c.Delays.All([11 12]) = [23 23];

%
% Setup for delay-time on-line calculations
%
c.Delays.Channels       = [6 7 13 3 4 12];      % channels of DAQ that need dT calc
c.Delays.RefChan        =  13;                  % referenced to channel 13 (Gill-T)
c.Delays.ArrayLengths   = [5000 5000];          % the num of points used [ RefChan  DelayedChan]
c.Delays.Span           = 100;                  % max LAG (see fr_delay.m)
c.Delays.UseFlag        = [0 0];                % 0 - use off-line calculated delays,
                                                % 1 - use on-line calculated delays,
                                                % to be implemented


