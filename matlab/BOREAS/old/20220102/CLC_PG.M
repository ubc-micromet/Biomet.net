function [PgF, Pg, v] = clc_Pg(RD,HD)
%
% Calculate Pgauge from the raw data.
%
%   RD = RawData(:,9)
% 	HD = header([37 72 73 78 79])
%
%       see read_met.m
%
%
% (c) Zoran Nesic               File created:       Nov 26, 1996
%                               Last modification:  Nov 26, 1996
%
v = RD .* HD(3) + HD(2);      			            % Voltage (mV) 
Pg =  v .* HD(4) + HD(5);			                % kPa (before filtering)
PgF = filter( 1-HD(1), [1 -HD(1)], Pg, Pg(1) );   	% kPa (after filtering)

