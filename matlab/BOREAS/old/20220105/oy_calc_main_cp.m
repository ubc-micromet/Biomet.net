function [statsar, statsbr, statsRaw, statsDiag, tv] = oy_calc_main_cp(doys,years);
%
%
% Outputs: statsar  - stats after rotation
%          statsbr  - stats before rotation
%          statsRaw - raw stats with constants removed, no change in measured units
%
% E.Humphreys Sept 6, 2000
%             
% Revisions: 
% Jan 7, 2001 - Fixed startDate to work on any year
% Nov 22, 2001 - work on closed path system

localdbase = 0;
  
if exist('years')==0 |isempty(years);
    years  = [2000];
end

switch localdbase
case 0;
    pthoy = biomet_path('yyyy','oy','fl');
case 1;
    pthoy  = 'c:\local_dbase\oy\flux\';
end


GMT_shift =  8/24;       %shift grenich mean time to 24hr day
tv = read_bor([ pthoy 'oy_flux_53_tv'],8,[],years); tv = tv-GMT_shift;

startDate = datenum(min(years),1,1); 

if ~isempty(doys);
    if min(doys) > 7e+005;
        st   = min(doys);
        ed   = max(doys);
    else
        st        = min(doys)+startDate-1;
        ed        = max(doys)+startDate-1;
    end
    
    indOut    = find(tv >=st & tv <= ed);
   
   t = tv - startDate+1;
   t = t(indOut);
   tv = tv(indOut) + GMT_shift; %return it to GMT time
   
else
   t = tv - startDate+1;
   indOut = find(t >=t(1) & t <= t(end));
   tv = tv(indOut) + GMT_shift; %return it to GMT time
end




warning off;
[statsOut, statsRaw] = oy_process_stats_cp(pthoy,years,indOut);

[statsar, statsbr]   = oy_calc_eddy_cp(statsOut);

statsDiag = [];



