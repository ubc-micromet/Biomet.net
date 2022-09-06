function [ row, col] = vec2mat(x, MaxCol)
%
%
%	[row, col] = vec2mat(x, MaxCol)
%
%	Converting a vector array coordinate to matrix coordinats
%	(MaxCol - the number of colons)
%
row = ceil(x/MaxCol);
col = x - MaxCol*(row-1);