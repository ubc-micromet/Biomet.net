function ind_select = find_selected(h,Stats);
% FIND_SELECTED Find indeces of datapoints selected in select_datapoints
%
% ind_select = fcrn_selected(h) returns indeces referring to the time
% series in the graphs h
%
% ind_select = fcrn_selected(h,Stats) assumes that Stats(:).TimeVector exists
% and returns indeces with respect to that

% kai* Mar 5, 2004

ind_select = [];

% Get exclusion from UserData of the figure
for i = 1:length(h)
   top = get(h(i).hand,'UserData');
   if isfield(top,'ind')
      ind_select = [ind_select top.ind];
   end
end

ind_select = unique(ind_select);

% Related excluded points to Original data set
if exist('Stats') & ~isempty(Stats)
   
   tv_fig = top.tv;
   tv_sta = get_stats_field(Stats,'TimeVector');
   
   [tv_dum,ind_fig,ind_sta] = intersect(tv_fig,tv_sta);
   
   ind_select = ind_sta(intersect(ind_fig,ind_select));
   
end


