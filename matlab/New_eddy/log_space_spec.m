function [len_spec_bins,spec_bins,Flog] = log_space_spec(f,no_spec_bins)

len_spec_bins = NaN .* zeros(no_spec_bins,1);
Flog_bins = logspace(log10(f(1)),log10(f(end)),no_spec_bins+1);

for i = 1:no_spec_bins-1;
   ind = find( f >= Flog_bins(i)-eps & f < Flog_bins(i+1)+eps );
   len_spec_bins(i) = length(ind);
end
ind = find( f >= Flog_bins(no_spec_bins));
len_spec_bins(no_spec_bins) = length(ind);

Flog     = NaN .* zeros(no_spec_bins,1);
spec_bins     = NaN .* zeros(no_spec_bins,max(len_spec_bins));
for i = 1:no_spec_bins-1;
   if len_spec_bins(i) ~= 0
      ind = find( f >= Flog_bins(i)-eps & f < Flog_bins(i+1)+eps );
      % Flog: geometric mean of the freq in spec_bin. Since they are evenly spaced
      %       just that between the first and the last
      Flog(i) = sqrt(f(ind(1)).*f(ind(end)));
      spec_bins(i,1:len_spec_bins(i)) = ind;
   end
end
ind = find( f >= Flog_bins(no_spec_bins));
Flog(no_spec_bins) = sqrt(f(ind(1)).*f(ind(end)));
spec_bins(no_spec_bins,1:len_spec_bins(no_spec_bins)) = ind;
