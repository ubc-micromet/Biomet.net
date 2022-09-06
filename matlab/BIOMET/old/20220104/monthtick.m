function [tick_val,tick_label] = monthtick(tv,label_freq,label_offset)
% [tick_val,tick_label] = monthtick(tv,label_freq,label_offset)
%
% For a given matlab time vector tv monthtick returns a vector
% of tickvalues and a cellstring array of labels that can be use
% with the function set (see monthtick_primer for examples). 
% 
% There will be a tick value for each first of a month between tv(1)
% and tv(end) and an the beginning of the month before tv(1) and 
% after tv(end). The number of elements in tick_label is equal to
% that of tick_val and either contains first letter of the 
% corresponding month or is empty, depinding on the value of 
% label_freq. The default is label_freq = 1. If the number of
% a month is specified in label_offset the labeling will start 
% at that month instead of January.

% kai* June, 12, 2002

if ~exist('label_freq') | isempty(label_freq)
   label_freq = 1;
end

if ~exist('label_offset') | isempty(label_offset)
   label_offset = 1;
end

[y,m,d,hh,mm,ss] = datevec(tv);

tv_full = [datenum(y(1),m(1),1):datenum(y(end),m(end)+1,1)]';    

tick_yymm = datevec(tv_full);
tick_yymm = unique(tick_yymm(:,1:2),'rows');

tick_val = datenum(tick_yymm(:,1),tick_yymm(:,2),1);

lab_mon   = 'JFMAMJJASOND';
lab_all = (ones(ceil(length(tick_yymm)/12)+1,1) * lab_mon)' ;
lab_all = lab_all(:);

ind_label = label_offset:label_freq:length(tick_val);
tick_label = char(' ' .* ones(length(tick_val)));
tick_label(ind_label) = char(lab_all( tick_yymm(1,2) + ind_label-1));
tick_label = cellstr(tick_label);

return


