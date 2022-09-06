function [ds,t,H,LE] = extr_bor(DOY)
%
% extr_bor.m
%
%	Extracts one day (DOY) H and LE LICOR and plots it 
%	on the same graph.
%
%
% (c) Zoran Nesic			File created:		Oct  7, 1996
%							Last modification:	Oct  7, 1996
%

ds  = read_bor('v:\data\ffaes\ffaes_d',4);           % get date (string) from the data base
t   = read_bor('v:\data\ffaes\ffaes_dt')-152.25;     % get decimal time from the data base
LE  = read_bor('v:\data\ffaes\ffaes.8');             % get LE LICOR
H   = read_bor('v:\data\ffaes\ffaes.7');             % get H

ind = find(floor(t) == DOY);                         % select data points for DOY
H   = H(ind);
ds  = ds(ind(1),:);
t   = t(ind);
LE  = LE(ind);

plot(t,LE,t,H)
grid
s = sprintf('DOY = %d, (%s)',DOY,ds);
title(s)
xlabel('Time')
ylabel('W m^-2')


