function [RD, Header] = join_raw(pth,FileNames, ChNum)
%
%
%
%
%
% (c) Zoran Nesic 			File created:		Nov 26, 1996
%					Last modification:	Nov 26, 1996
if nargin < 3
	error 'Required parameter(s) missing!'
end
[n,m] = size(FileNames);
RD = zeros(1,37500*n);
k = 1;
for i=1:n
    s = sprintf('[RawData,Header] = read_met(%s%s%s);',39,[pth FileNames(i,:)],39);
    eval(s);
    N = length(RawData);
    k1 = k+N-1;
    RD(k:k1) = RawData(ChNum,:);
    k = k1+1;
end
RD = RD(1:k-1);

    	