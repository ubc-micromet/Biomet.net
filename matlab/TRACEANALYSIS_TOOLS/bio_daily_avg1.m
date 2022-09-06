function [xsum,xmean,OrigIntervals] = bio_daily_avg1(tx,cx_mat,td,interval_days, reject)
%**********************************************************************************
% This program calculates daily averages (e.g. 24-h) of the columns in an input matrix.
% 
%  INPUTS:	see function 'integz.m'
%       	tx    	  		- time vector in 1/48 parts per day
%       	cx_mat			- data vector corresponding to tx
%       	td      		- time vector in days
%       	interval_days  - interval of integration in days (INTEGER) 
%							  (= 1 for 24h averages)
%	       reject  		- the number of elements per averaging interval that
%				               MUST be present so the average value can be calculated
%              				(default if 24 => every day that has less then 24 valid
%                				hhours will be rejected)
%
%  OUTPUTS:
%			xsum			-	integral over interval (24h)
%			xmean			-	average over interval (24h)
%			OrigIntervals	-
%
%	Syntax:
%	e.g.  [sum_CR,av_CR,t_CR] = bio_daily_avg(Tdoy_CR,Fc_CR,[st:ed],1);
%
%		(c)  by Zoran Nesic			 created on:  June 11, 1998
%							  	         modified on: June 15, 1998			
%													- comments added by Eva	
%
%**********************************************************************************

[n,m] = size(cx_mat);
xsum = [];
xmean = [];
for i=1:m
    ind = find(~isnan(cx_mat(:,i)) & cx_mat(:,i)~=1e38);
    [xsum1,xmean1,OrigIntervals1] = integz(tx(ind),cx_mat(ind,i),td,interval_days, reject);
    xsum = [xsum xsum1(:)];
    xmean = [xmean xmean1(:)];
end
OrigIntervals = OrigIntervals1;


