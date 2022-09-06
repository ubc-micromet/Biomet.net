function Spectra = fr_calc_spectra(Eddy_HF_data_IN, Eddy_delays,config_info,spec_info)
% fr_calc_spectra  - calculation of power and co-spectra from raw data for ONE 
%                    data period (usually 1/2 hour)
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
%       enty config_in.Spectra.Fs. Other entries in config.Spectra will be assigned the
%       following defaults if they are not found:
% 
%       config_info.Spectra.no_spec_bins = 100; % length of spectrum
%       config_info.Spectra.no_in_bin    = 20;  
%       % no of minimum points in a spectral bin
%       config_info.Spectra.noverlap     = 0;   % same as in psd
%       config_info.Spectra.filtX        = 'hamming'; % same as in psd
%       config_info.Spectra.dflag        = 'linear';  % type of detrend
%       config_info.Spectra.psdVec       = all columns in Eddy_HF_data_IN;
%       % colums for which power spectra are to be calculated
%       config_info.Spectra.csdRef       = 3; 
%       % column for co-spectrum reference
%       config_info.Spectra.csdVec       = all columns in Eddy_HF_data_IN except csdRef;
%       % colums for which co-spectra are to be calculated

%=================================================================================
%
% (c) kai*  File created:       Oct 19, 2000
%           Last modification:  Sep 17, 2003
%
% Based on fr_calc_eddy by Zoran and fr_calc_spectra by Elyn
%

%       -   The spectra structure has the
%           following components:
%   Spectra.Psd      - block averaged power spectra
%          .Psd.Cov  - variances of power spectra, used for normalisation
%          .Csd      - block averaged co-spectra
%          .Csd.Cov  - covariances of power spectra, used for normalisation
%          .Flog     - block averaged frequencies

% INPUT parameter defaults
% Revisions: Nov  5, 2001 - now use direct fft
%            Aug 26, 2003 - also include Flog in structure output
%            Sep 17, 2003 - fixed shifting of delays


[n,m]  = size(Eddy_HF_data_IN);

if exist('Eddy_delays') ~= 1 | isempty(Eddy_delays)
    Eddy_delays = ones(1,m);
end 

%-----------------------------------------------------------------------
% Assign default configuration parameters
%-----------------------------------------------------------------------
[n,m] = size(Eddy_HF_data_IN); % n: No of data points, m: No of columns
config_info = config_default(config_info,'no_spec_bins',100);
config_info = config_default(config_info,'no_in_bin',20);
config_info = config_default(config_info,'nfft',2^(floor(log2(length(Eddy_HF_data_IN)))));
config_info = config_default(config_info,'n_spec',config_info.Spectra.nfft/2+1);
config_info = config_default(config_info,'noverlap',0);
config_info = config_default(config_info,'filtX','hamming');
config_info = config_default(config_info,'dflag','linear');
config_info = config_default(config_info,'psdVec',1:m);
config_info = config_default(config_info,'csdRef',3);
config_info = config_default(config_info,'csdVec',setdiff(config_info.Spectra.psdVec,config_info.Spectra.csdRef));


if ~isfield(spec_info,'Flog')
   [Flog,len_spec_bins,spec_bins] = fr_config_spec(config_info.Spectra.no_spec_bins,...
      config_info.Spectra.no_in_bin,config_info.Spectra.nfft,config_info.Spectra.Fs);
    %place this in spec_info for csd_avg.m later on
    spec_info.Flog          = Flog;
    spec_info.len_spec_bins = len_spec_bins;
    spec_info.spec_bins     = spec_bins;
    spec_info.no_spec_bins  = config_info.Spectra.no_spec_bins;
else
    Flog          = spec_info.Flog;
	len_spec_bins = spec_info.len_spec_bins;
	spec_bins     = spec_info.spec_bins;
end

Eddy_HF_data_IN   = fr_shift(Eddy_HF_data_IN, ...
                          Eddy_delays);  % remove the delay times from Eddy_HF_data_IN
m_psd = length(config_info.Spectra.psdVec);
m_csd = length(config_info.Spectra.csdVec);

                     
% Generate the window
eval(['filtX = ' config_info.Spectra.filtX '(config_info.Spectra.nfft);']);
% Match the size to the Eddy data
filtX = filtX * ones(1,m_psd);

%-----------------------------------------------------------------------
%                   Initialize output structure
%-----------------------------------------------------------------------
Spectra.Psd      = NaN.*zeros(config_info.Spectra.no_spec_bins,m_psd);
Spectra.fPsd     = NaN.*zeros(config_info.Spectra.no_spec_bins,m_psd);
Spectra.Csd      = NaN.*zeros(config_info.Spectra.no_spec_bins,m_csd);
Spectra.fCsd     = NaN.*zeros(config_info.Spectra.no_spec_bins,m_csd);

Spectra.Flog     = NaN.*zeros(config_info.Spectra.no_spec_bins,1);
Spectra.Psd_norm = NaN.*zeros(1,m_psd);
Spectra.Csd_norm = NaN.*zeros(1,m_csd);    

%-----------------------------------------------------------------------
%                   Select traces for FFT,
%                   shorten trace to a length 2^N, detrend, and apply window
%-----------------------------------------------------------------------
% e.g. % 2^15 = 32768 points <=> 26.2min
% Check whether time series is long enough
if isfield(config_info.Spectra,'filtwin')
   eval(['filtwin = ' config_info.Spectra.filtwin ';']);
   n_win = length(filtwin);
   if length(Eddy_HF_data_IN) > 2*n_win-1
      Eddy_HF_data_avg = conv2(Eddy_HF_data_IN,filtwin);
      Eddy_HF_data_IN = Eddy_HF_data_IN(n_win/2:end-n_win/2-1,:) - Eddy_HF_data_avg(n_win:end-n_win,:);
   else
      return
   end
end

if length(Eddy_HF_data_IN(:,1)) >= config_info.Spectra.nfft
   Eddy_HF_data = Eddy_HF_data_IN(1:config_info.Spectra.nfft,config_info.Spectra.psdVec);
   Eddy_HF_data = filtX .* detrend(Eddy_HF_data,config_info.Spectra.dflag);
else 
   return;
end

%-----------------------------------------------------------------------
%                   SPECTRA calculations
%-----------------------------------------------------------------------

% Do the FFT
Eddy_HF_spec = fft(Eddy_HF_data);

%Calculate power spectra
% psd_met is not used here because it does only the * 1 / n_spec multiplication
% These results here are also obtained by psd - but for our purpose this is faster:
spec_pts = (1:config_info.Spectra.n_spec)';
Px = abs(Eddy_HF_spec(spec_pts,:)).^2 ./ config_info.Spectra.nfft; 
% The first value in Px is just the average of the time series, 
% it is dropped at this point
Px = Px(2:end,:);
% Create the frequency vector
Fx = (spec_pts(2:end) - 1)*config_info.Spectra.Fs/config_info.Spectra.nfft;
Fx_mat = Fx * ones(1,m_psd);
fPx = Fx_mat .* Px;

Spectra.Psd_norm = sum(Px) * 1 / config_info.Spectra.n_spec;
% ...* 1 / n_spec - Compute total biased variance of windowed trace 
%                   Stull 8.6.1b, p. 312
[Pxd] = csd_avg([Px fPx], spec_info);
Spectra.Psd = Pxd(:,1:m_psd) .* 2./ config_info.Spectra.Fs;
% ...* 2./ Fs - Compute spectral energy density S(n) (per frequency interval 1/Fs)
%               Stull 8.6.2b, p. 313
Spectra.fPsd = Pxd(:,(m_psd+1):end) .* 2./ config_info.Spectra.Fs;
% Multiplication has to be done before block averaging, because the vector
% Fx cannot be extracted after block averaging

%Calculate cospectra
conj_w = conj(Eddy_HF_spec(spec_pts,config_info.Spectra.csdRef)) * ones(1,m_csd);
Cx = real(Eddy_HF_spec(spec_pts,config_info.Spectra.csdVec).*conj_w) ./ config_info.Spectra.nfft; 
Cx = Cx(2:end,:);
fCx = Fx_mat(:,1:m_csd) .* Cx;

Spectra.Csd_norm = sum(Cx) * 1 / config_info.Spectra.n_spec;

[Cxd] = csd_avg([Cx fCx], spec_info);
Spectra.Csd  = Cxd(:,1:m_csd)       .* 2./ config_info.Spectra.Fs;
Spectra.fCsd = Cxd(:,(m_csd)+1:end) .* 2./ config_info.Spectra.Fs;

Spectra.Flog = Flog;

function c_out = config_default(c_in,c_in_field,val)

c_out = c_in;

if isfield(c_in.Spectra,c_in_field) & eval(['~isempty(c_in.Spectra.' c_in_field ')'])
    % do nothing
else
    eval(['c_out.Spectra.' c_in_field ' = val;']);
end

