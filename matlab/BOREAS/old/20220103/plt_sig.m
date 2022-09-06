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
%                               Last modification:  Dec 22, 2008
%

% Revisions:
%
%   Dec 22, 2008
%       - added plotting of 2 auxilary lines to mark the y=0 (horizontal
%       line) and x = last_day-1.  These two lines can help visually with
%       figuring out if all the data has arrived and where the zero
%       crossing is.
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
    if isempty(y_axis)
        axTMP = axis;
        y_axis = axTMP(3:4);
    end
    
	axis([ax(1:2) y_axis])

    % select the color of the auxilary lines to be plotted below
    if all(get(gcf,'color') == [0 0 0])
        aux_lin_col = [1 1 1];
    else
        aux_lin_col = [0.8 0.8 0.8];
    end
    % plot zero line if zero is visible on the graph (z Dec 22, 2008)
    if y_axis(1)<= 0 & y_axis(2)>= 0
        line(ax(1:2),zeros(1,2),'color',aux_lin_col,'linewidth',2,'linestyle','-')
    end
    % plot a vertical line where the last day starts to aid figuring out if
    % there is some missing data:
    line([1 1]* round(ax(2)-1),y_axis,'color',aux_lin_col,'linewidth',2,'linestyle','-')

	grid
	zoom on
	title(trace_name)
	xlabel(sprintf('DOY (Year = %d)',year))
	ylabel(trace_units)
end