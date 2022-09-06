function Stats = fcrn_merge_stats(Stats1,Stats2,timeshift)
% Stats = fcrn_merge_stats(Stats_fcrn,Stats_site,timeshift)

if ~exist('timeshift') | isempty(timeshift)
   timeshift = 0;
end

tv_xs = get_stats_field(Stats1,'TimeVector')-timeshift;
tv_pi = get_stats_field(Stats2,'TimeVector');

[tv_dum,ind_xs,ind_pi] = intersect(round(tv_xs.*100)./100,round(tv_pi.*100)./100);
   
n = length(ind_xs);

%----------------------------------------------------
% Extract system info for both systems
%----------------------------------------------------
i1 = 1;
while isempty(Stats1(i1).Configuration)
    i1 = i1+1;
end
Stats1(ind_xs(1)).Configuration = Stats1(i1).Configuration;
i2 = 1;
while isempty(Stats2(i2).Configuration)
    i2 = i2+1;
end
Stats2(ind_pi(1)).Configuration = Stats2(i2).Configuration;

ind_pi_sys = 1:length(Stats2(i2).Configuration.System);
ind_xs_sys = 1:length(Stats1(i1).Configuration.System);

ind_pi_ins = 1:length(Stats2(i2).Configuration.Instrument);
ind_xs_ins = 1:length(Stats1(i1).Configuration.Instrument);

for i = 1:n
   
   Stats_new = Stats1(ind_xs(i));
   
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
   
   Stats_new.MiscVariables1 = Stats1(ind_xs(i)).MiscVariables;
   Stats_new.MiscVariables2 = Stats2(ind_pi(i)).MiscVariables;
   Stats_new.Configuration1 = Stats1(ind_xs(i)).Configuration;
   Stats_new.Configuration2 = Stats2(ind_pi(i)).Configuration;

   Stats(i) = Stats_new;
end

return