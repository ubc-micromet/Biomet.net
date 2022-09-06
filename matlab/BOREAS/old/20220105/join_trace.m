function [t,x] = join_trace(traceName,startDay,endDay,fileExt,pth)
%**********************************************************************************
% 	This program joins traces from Frbc CDs recalculated with the new program
%   and traces from short files downloaded from the site, stored in the directory:
%	\\Paoa_001\site_hhour\PA_site\	or
%	\\Paoa_001\site_hhour\CR_site\.
%	It has to be specified (see line 35f.), whether extension is 's.hc.mat' or '.hc.mat'!!   
%
%	inputs:     tracename	 - e.g. 'statsMisc(:,9)'
%				 startDay   - in decimals
%				 endDay     - in decimals
%				 fileExt    - '.hc.mat'  (for CR)
%				 pth        - storage of input data, e.g. '\\Frbc_002\CR_hhour\')
%	
%
%	outputs: 	t - timevector in GMT => TDOY (decimal DOY, not JulianDay!!)
%   			x - joined trace
%
%	Syntax:		e.g.  for CR 
%				pth = '\\Paoa_001\site_hhour\CR_site\';
%				st = datenum(1998,6,15,0,0,0);		% corresponding elements of the Y,M,D,H,MI,S 
%				en = datenum(1998,8,3,0,0,0);  		% arrays values.
%				[ts,Fs] = join_trace('stats.Fluxes.LinDtr(:,5)',st,en,'hc.mat',pth);  
%				or for PA   
%				pth = '\\Paoa_001\site_hhour\PA_site\';
%				[ts,Fs] = join_trace('stats.Fluxes.LinDtr(:,5)',st,en,'hp.mat',pth);  
%
%
%
%  						created on:		May 07, 1998    	by:  Zoran Nesic
%						modified on:	March 16, 1999 	by:  Eva Jork
%
%**********************************************************************************

if pth(length(pth)) ~= '\'
   pth = [pth '\'];
end

n = length(fileExt);
if fileExt(n-3:n) ~= '.mat'
   fileExt = [fileExt '.mat'];
end

t = [];
x = [];
for i=startDay:endDay
   fileName = datestr(i,2);
   fileName = fileName([7 8 1 2 4 5]);
   if exist([pth fileName '.' fileExt])
      fileName = [pth fileName '.' fileExt];
   else
      %   fileName = [pth fileName '.' fileExt];
      fileName = [pth fileName 's.' fileExt];		% for the 's-files'
   end
   eval(['load ' fileName])
   t = [t ; stats.DecDOY];
   c = [ 'x1 = ' traceName ';'];
   eval(c);
   x = [x ; x1];
end   
