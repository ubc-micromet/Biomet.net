function [a] = calibrate_TBRG_to_geonor(doy,doy_st,doy_ed,ppt_TBRGavg,ppt_geonor,ind_fill,plots);

% calibrate TBRG to geonor during periods when rain is the only precip

% Nick                          file created:  Jan 15, 2008
%                               Last modified: Jan 15, 2008
% revisions:

ind_regr = find(  doy > doy_st &  doy < doy_ed & ~isnan(ppt_geonor));
cumTBRG = cumsum(ppt_TBRGavg);

% shift cumTBRG by an amount equal to the offset between the two cumulative traces
%  then any rainfall registered by the TBRG will simply be multiplied by a
%  correction factor to obtain that seen by the Geonor
offset =  ( ppt_geonor(min(ind_regr))-cumTBRG(min(ind_regr)) ) ; 
%
a = ppt_geonor(ind_regr)\(cumTBRG(ind_regr)+offset);
disp(sprintf('GEONOR = %3.2f * TBRG ',a));