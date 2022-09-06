function Stats = fcrn_merge_stats(Stats1,Stats2,timeshift)
% Stats = fcrn_merge_stats(Stats_fcrn,Stats_site,timeshift)

if ~exist('timeshift') | isempty(timeshift)
   timeshift = 0;
end

tv_xs = get_stats_field(Stats1,'TimeVector')-timeshift;
tv_pi = get_stats_field(Stats2,'TimeVector');
tv_all = fr_round_hhour([min(tv_xs;tv_pi):1/48:max(tv_xs;tv_pi)]);

[tv_dum,ind_xs,ind_all_xs] = intersect(fr_round_hhour(tv_xs),tv_all);
[tv_dum,ind_xs,ind_all_pi] = intersect(fr_round_hhour(tv_pi),tv_all);

n = length(tv_all);

%----------------------------------------------------
% Extract system info for both systems
%----------------------------------------------------
ind_pi_sys = 1:length(Stats2(1).Configuration.System);
ind_xs_sys = 1:length(Stats1(1).Configuration.System);

ind_pi_ins = 1:length(Stats2(1).Configuration.Instrument);
ind_xs_ins = 1:length(Stats1(1).Configuration.Instrument);

for i = 1:n
   if ~isempty(find(i == ind_all_xs))
       ind_cur = find(i == ind_all_xs);
       Stats_new = Stats1(ind_xs(ind_cur));
   % Done up to here - this is getting to complicated for now
   
   % Add other systems
   for j = ind_pi_sys 
      field = Stats2(1).Configuration.System(j).FieldName;
      eval(['Stats_new.' field ' = Stats2(ind_pi(i)).' field ';']);
   end
   for j = ind_pi_ins 
      try
          Stats_new.Instrument(ind_xs_ins(end)+j) = Stats2(ind_pi(i)).Instrument(j);
      catch
          %Stats_new.Instrument(ind_xs_ins(end)+j) = NaN;
      end
   end
   
   Stats(i) = Stats_new;
end

return