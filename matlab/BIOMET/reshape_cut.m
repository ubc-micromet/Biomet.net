function x_out = reshape_cut(x,n)
% RESHAPE_CUT Reshape x so it as many columns of n rows as possible
%
%   fc_day = reshape_cut(fc_main(1:100),48) return a 48x2 matrix, containing one day in each column.
%   The last 4 entries in fc_main are discarded.

m = floor(length(x)/n);
x_out = reshape(x(1:n*m),n,m);
