function [x,t] = plt_sig( pth, ind, trace_name, year, trace_units, y_axis, t, fig_num );
%
% [x,t] = plt_sig( pth, ind, trace_name, year, trace_units, y_axis, t, fig_num )
%
% This function reads a trace from the data base and plots it.
%
%   Input parameters:
%        pth         - path and data file name
%        ind         - index to select the data points
%        trace_name  - string with the trace name,
%        trace_units - string with the trace units
%        y_axis      - [ymin ymax] axis limits
%        t           - time trace
%
%
% (c) Zoran Nesic               File created:       Jan 15, 1997
%                               Last modification:  Jul  3, 1997
%

% Revisions:
%		Nov 18, 1997
%			added :
%	   		if exist(deblank(pth))
%			to prevent errors if the file does not exist
%     Jul  3, 1997
%           - changed "clg" to "clf"
%             
if exist(deblank(pth))

	if isstr(pth)                       % if path is string then
   	 x = read_bor(pth);              % get the data from the data base
	else
   	 x = pth;                        % else pth is data so use it
	end
	x = x(ind);                         % extract the requested period
	ax = [min(t) max(t)];               % store min and max t (for the plotting purposes)
	[x,indx] = del_num(x,0,0);          % remove leading zeros from x
	t = t(indx);                        % match with t
	[x,indx] = del_num(x,0,1);          % find trailing zeros in x
   t = t(indx);                        % match with t

	figure(fig_num)
	set(fig_num,'menubar','none',...
   	         'numbertitle','off',...
      	      'Name',trace_name);
	%set(fig_num,'position',[15 288 992 420]);          % good for 1024x700
    pos = get(0,'screensize');
    set(fig_num,'position',[8 pos(4)/2-20 pos(3)-20 pos(4)/2-35]);      % universal
	%set(fig_num,'position',[6   268   790   300]);      % good for  800x600
	clf
	plot(t,x)
	% ax = axis;
	axis([ax(1:2) y_axis])

	grid
	zoom on
	title(trace_name)
	xlabel(sprintf('DOY (Year = %d)',year))
	ylabel(trace_units)
end