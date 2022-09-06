function nep_out = cat_nep(clean_tv,nep_in)
% nep_out = cat_nep(clean_tv,nep_in)
%
% Adds last years total NEP to the current year to give correct NEP for
% traces made up of multiple years.

ind_new_year = find(convert_tv(clean_tv,'doy') == 1);
ind_new_year = [ind_new_year; length(clean_tv)];
nep_last_year = nep_in(ind_new_year(2:end)-1);
nep_last_year = [0; nep_last_year];

for i = 1:length(ind_new_year)-1
   nep_offset(ind_new_year(i):ind_new_year(i+1)) = nep_last_year(i);
end

nep_out = nep_in + nep_offset';