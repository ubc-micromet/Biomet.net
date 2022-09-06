function [x,t] = plt_sig1( t, x, trace_name, year, trace_units, ax, y_axis, fig_num, plt_symbol )
%
% [x,t] = plt_sig1( t, x, trace_name, year, trace_units, ax, y_axis, fig_num )
%
% This function plots a trace. Used with pl_sig.m.
%
%   Input parameters:
%        trace_name  - string with the trace name,
%        trace_units - string with the trace units
%        y_axis      - [ymin ymax] axis limits
%        t           - time trace
%        x           - signal trace
%        year
%        fig_num     - figure number
%        plt_symbol  - plotting symbol (as in normal plot statement)
%
%
% (c) Zoran Nesic               File created:       Jul  8, 1997
%                               Last modification:  Nov 30, 2007
%

% Revisions:
%             
% Nov 30, 2007
%   - set the plot size to match the screen resolution
% Oct 6, 1998
%   - added plt_symbol input parameter
%

if exist('plt_symbol')~=1
    plt_symbol = '-';
end
lineWidth = 2;

figure(fig_num)
set(fig_num,'menubar','none',...
            'numbertitle','off',...
            'Name',trace_name);
%set(fig_num,'position',[15 288 992 420]);          % good for 1024x700
%set(fig_num,'position',[6   268   790   300]);      % good for  800x600
pos = get(0,'screensize');
set(fig_num,'position',[8 pos(4)/2-20 pos(3)-20 pos(4)/2-35]);      % universal

clf
plot(t,x,plt_symbol,'linewidth',lineWidth)
set(gca,'FontSize',12)
set(gca,'linewidth',1.5)
set(gca,'gridlinestyle',':')

if isempty(y_axis)                                  % if y_axis is not given
    ax1 = axis;                                     % use Matlab defaults
    y_axis = ax1(3:4);
end
if isempty(ax)                                      % if ax is not given
    ax = ax1(1:2);                                  % use Matlab defaults
end

axis([ax(1:2) y_axis])                              % use it for the plot
grid
zoom on
title(trace_name)
xlabel(sprintf('DOY (Year = %d)',year))
ylabel(trace_units)