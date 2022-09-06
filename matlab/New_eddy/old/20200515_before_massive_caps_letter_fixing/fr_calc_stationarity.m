function Stationarity = fr_calc_stationarity(Eddy_HF_data_IN, Eddy_delays,config_info)
% fr_calc_stationarity  - calculation of nonstationarity ration according to Mahrt(1998)
%                 
%=================================================================================
%
%   Inputs:
%       Eddy_HF_data_IN -  high frequency data in engineering units
%                          Matrix has the following columns:
%                           - U V W T CO2 H2O TC1 TC2 Aux1 Aux2 ... AuxN
%                          where Aux1..N are auxilary SCALAR inputs (like Krypton).
%                          The data are tapered to a length of a power of two, but 
%                          do not get other treatment like rotation etc.
%       Eddy_delays     - a vector of delays for each channel (in units of samples)
%                         (default a vector of zeros - no delays)
%       config_in       - a config structure that must have at least on
%       enty config_in.Stationarity.Fs. Other entries in config.Spectra will be assigned the
%       following defaults if they are not found:
%       no_of_rec    = 6;
%       no_of_subrec = 6;
%       min_length   = 20 * 60 * c.Instrument(nGILL).Fs; % Minimum record length in samples
%       stationVec   = all columns of Eddy_HF_data_IN;
%       stationRef   = 3;
%
%=================================================================================
%
% (c) kai*  File created:       Jan 23, 2001
%           Last modification:  Oct 18, 2004 - default config_info values

%       -   The Stationarity structure has the
%           following components:
%   Stationarity.NR - vector of nonstationarity ratios for covariances with w
%					 .RE - vector of random error of w'x' for all variables

[n,m]  = size(Eddy_HF_data_IN); % n: No of data points, m: No of columns

% INPUT parameter defaults
config_info = config_default(config_info,'no_of_rec',6);
config_info = config_default(config_info,'no_of_subrec',6);
config_info = config_default(config_info,'min_length',1800*0.66 * config_info.Stationarity.Fs); % Minimum record length in samples
config_info = config_default(config_info,'stationVec',1:m);
config_info = config_default(config_info,'stationRef',3);

if exist('Eddy_delays') ~= 1 | isempty(Eddy_delays)
    Eddy_delays = ones(1,m);
end 

Eddy_HF_data   = fr_shift(Eddy_HF_data_IN, ...
                          Eddy_delays);  % remove the delay times from Eddy_HF_data_IN

%-----------------------------------------------------------------------
%                   Initialize output structure
%-----------------------------------------------------------------------
m_station = length(config_info.Stationarity.stationVec);

Stationarity.NR = NaN.*zeros(m_station,1);
Stationarity.RE = NaN.*zeros(m_station,1);

no_of_cov = config_info.Stationarity.no_of_rec * config_info.Stationarity.no_of_subrec; 
Stationarity.mean_wx = NaN.*zeros(no_of_cov,m_station);
Stationarity.mean_x  = NaN.*zeros(no_of_cov,m_station);

%-----------------------------------------------------------------------
%                   STATIONARITY calculations
%-----------------------------------------------------------------------

% Test whether length of time series allows meaningful test
if n < config_info.Stationarity.min_length % i.e. if time series is less than 20 min long
   return
end
   
% Cummulative sum of all variables and all variables * w
cum_HF_data  = cumsum(Eddy_HF_data(:,config_info.Stationarity.stationVec));

% Here and belwo it is assumed that Eddy_HF_data(:,3) contains w!!!
wHF = zeros(size(Eddy_HF_data(:,config_info.Stationarity.stationVec)));
for k = 1:m_station
   wHF(:,k) = Eddy_HF_data(:,config_info.Stationarity.stationVec(k)) .* ...
      Eddy_HF_data(:,config_info.Stationarity.stationRef);
end
cum_wHF_data = cumsum(wHF);

% Calculate sub-covariances & nonstationarity test data
std_wi    = zeros(config_info.Stationarity.no_of_rec,1);
F_bar_rec = zeros(config_info.Stationarity.no_of_rec,1);

for k = 1:m_station
   [cov_int,mean_xy,mean_x,mean_y]= ...
      fr_cov(cum_wHF_data(:,config_info.Stationarity.stationVec(k)),...
      cum_HF_data(:,config_info.Stationarity.stationVec(k)),...
      cum_HF_data(:,config_info.Stationarity.stationRef),no_of_cov);
	Stationarity.mean_wx(:,k) = mean_xy;
	Stationarity.mean_x(:,k)  = mean_x;
   
   % Within record std & average record flux
   for i = 1:config_info.Stationarity.no_of_rec
      ind = (i-1)*config_info.Stationarity.no_of_subrec+1:i*config_info.Stationarity.no_of_subrec;
      std_wi(i) = std(cov_int(ind));
      F_bar_rec(i)   = mean(cov_int(ind));
   end
   std_btw = std(F_bar_rec);
   std_wi_bar = mean(std_wi);
   
   % Nonstationarity ratio
   Stationarity.NR(k) = std_btw / (std_wi_bar/sqrt(config_info.Stationarity.no_of_subrec));
   
   % Random error of flux
   [cov_int,mean_xy,mean_x,mean_y]= fr_cov(cum_wHF_data(:,k),cum_HF_data(:,k),...
      cum_HF_data(:,config_info.Stationarity.stationRef),config_info.Stationarity.no_of_rec);
   Stationarity.RE(k) = std(cov_int)/sqrt(config_info.Stationarity.no_of_rec);
end
 
%**********************************************************************************
% FUNCTION that does the sub-covariances
%**********************************************************************************
function [cov_int,mean_xy,mean_x,mean_y]= fr_cov(cum_xy,cum_x,cum_y,no_of_cov)
%**********************************************************************************
% [cov_int,mean_xy,mean_x,mean_y]= fr_cov(cum_xy,cum_x,cum_y,no_of_cov)
%
%	INPUTS:  cum_xy  - cummulative sum of x.*y
%           cum_x   - cummulative sum of x
%           cum_y   - cummulative sum of y
%       	
%	OUTPUTS:	cov_int - vector of covariances for the no_of_cov intervals
%				mean_xy - vector of sum(x.*y) for the no_of_cov intervals
%				mean_x  - vector of sum(x) for the no_of_cov intervals
%				mean_y  - vector of sum(y) for the no_of_cov intervals
%**********************************************************************************

len_tv = length(cum_xy); 
len_int    = floor(len_tv/no_of_cov);

cov_int = zeros(1,no_of_cov);
mean_xy = zeros(1,no_of_cov);
mean_x  = zeros(1,no_of_cov);
mean_y  = zeros(1,no_of_cov);

% This is so the first ind_beg points to a value of zero
cum_xy = [0 ; cum_xy];
cum_x  = [0 ; cum_x];
cum_y  = [0 ; cum_y];

% Loop through records
for i = 1:no_of_cov
   % Interval: sum for current = cumsum(last point of current) - cumsum(last point of last)
   ind_beg = (i-1)*len_int+1;
   ind_end =   (i)*len_int+1;
   
   mean_xy(i) = (cum_xy(ind_end) - cum_xy(ind_beg))/len_int;
   mean_x(i)  = (cum_x(ind_end)  - cum_x(ind_beg)) /len_int;
   mean_y(i)  = (cum_y(ind_end)  - cum_y(ind_beg)) /len_int;
   
   cov_int(i) = mean_xy(i) - mean_x(i) * mean_y(i);
end

function c_out = config_default(c_in,c_in_field,val)

c_out = c_in;

if isfield(c_in.Stationarity,c_in_field) & eval(['~isempty(c_in.Stationarity.' c_in_field ')'])
    % do nothing
else
    eval(['c_out.Stationarity.' c_in_field ' = val;']);
end

