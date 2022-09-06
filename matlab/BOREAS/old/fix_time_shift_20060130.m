function trace_out = fix_time_shift(SiteID,clean_tv,trace_in);

% INPUTS
%        -clean_tv          clean time vector
%        -trace_in          data to be resampled at the "correct" times 
%                              in clean tv
%        -doy_begin         


% corrects for time shifts in data traces created by e.g. PC clock offsets
% created by NickG, January 20, 2006

% modifications:

% check year

dv = datevec(clean_tv(1000));
if SiteID == 'bs'
  % begin correction for OBS 2005, DOY 209-228 due to incorrect PC clock
  if dv(1) == 2005
     tv_local                  = clean_tv - 6/24;
     tv_corr                   = tv_local;
     doy_local                 = tv_local - datenum(2005,1,0);
     ind_shift                 = find((doy_local >= 209) & (doy_local <= 228));
     tv_corr(ind_shift)        = tv_local(ind_shift) - (43/60)/24;
     doy_corr                  = tv_corr - datenum(2005,1,0); 
     
    % YI = INTERP1(X,Y,XI) interpolates to find YI, the values of
    % the underlying function Y at the points in the vector XI.
    % The vector X specifies the points at which the data Y is
    % given.
     
    trace_out                 = interp1(doy_corr,trace_in,doy_local);
  else 
    trace_out                 = trace_in;
  end
else
   trace_out                 = trace_in;
end
     
     