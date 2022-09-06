function T = fr_calc_tc(V,N)

if ~exist('N') | isempty(N)
    N = 4;
end
[p_below_0, p_above_0] = fit_tc(N);

T = zeros(size(V));
n = find(V<=0);
T(n) = polyval(p_below_0,V(n));
n = find(V>0);
T(n) = polyval(p_above_0,V(n));


