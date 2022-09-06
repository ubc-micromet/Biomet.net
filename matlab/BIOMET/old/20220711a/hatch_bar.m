function [g_out,h_out] = hatch_bar(varargin)
%HATCH_BAR Bar graph with hatched bars.
%    Works like BAR as long as the 'grouped','stacked' 
%    arguments are not used.
%
%    BAR(X,Y) draws the columns of the M-by-N matrix Y as M groups of N
%    vertical bars.  The vector X must be monotonically increasing or
%    decreasing.
%
%    BAR(Y) uses the default value of X=1:M.  For vector inputs, BAR(X,Y)
%    or BAR(Y) draws LENGTH(Y) bars.  The colors are set by the colormap.
%
%    BAR(X,Y,WIDTH) or BAR(Y,WIDTH) specifies the width of the bars. Values
%    of WIDTH > 1, produce overlapped bars.  The default value is WIDTH=0.8
%
%    BAR(...,LINESPEC) uses the line color specified (one of 'rgbymckw').
%
%    [H,G] = BAR(...) returns vectors of patch handles and the line handles 
%    that describe the hatch lines.
%
%    Examples: bar_hatch(0:.25:1,rand(5),1,'k')
%
%    See also HIST, PLOT, BAR.

g = bar(varargin{:});
for i = 1:length(g)
   h(i) = hatch_pattern(g(i),i);
end

if nargout > 0
   g_out = g;
   h_out = h;
end

% The last thing - plaster a fat zero line over the little dots that hatch leaves
lw = get(0,'DefaultAxesLineWidth');
xlim = get(gca,'XLim');
hold on
plot(xlim,[0 0],'k','LineWidth',lw);
hold off
return