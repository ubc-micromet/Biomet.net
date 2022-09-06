function x = plt_sig( pth, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,coeff,offset );
%
% x = plt_sig( pth, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,coeff );
%
% This function reads multiple traces from the data base and plots them.
%
%   Input parameters:
%        pth         - data file names
%        ind         - index to select the data points
%        trace_name  - string with the trace names,
%        trace_units - string with the trace units
%        y_axis      - [ymin ymax] axis limits
%        t           - time trace
%        fig_num     - figure number
%        coeff       - multipliers for each trace
%        offset      - offsets for each trace
%
% (c) Zoran Nesic               File created:       Jan 15, 1997
%                               Last modification:  Nov 18, 1997
%

% Revisions:
%
%   May 25, 1998
%       comment out 'axes(h)': see below
%	Nov 18, 1997
%		added :
%	   	if exist(deblank(pth(i,:)))
%		to prevent errors if the file does not exist
%		- changed:
%				~isempty(trace_legend)
%		  to
%				if ~isempty(legend_string)
%		  in the last "if" statement, to avoid plotting a non-existant legend
%
%	Nov 13, 1997
%		changed ~=[] to ~isempty()
%   May 27, 1997
%           - changed legend plotting. Now legend can be []
%           - changed how program deals with a large number of traces
%             (now it should work for more than 10 traces per graph)
%

[n,m] = size(pth);
if n > m
    error 'Wrong path matrix format: num.of rows > num.of columns!';
end
if nargin < 11
    offset = zeros(1,n);
end
if nargin < 10
    coeff = ones(1,n);
end
if nargin < 9
    error 'Input parameter(s) missing'
end
LineTypes = str2mat('y-','r--','g-.','m:','b-','y--','r-','g:','m-','b--');
N = n;                              % find the number of traces
x = [];

figure(fig_num)
set(fig_num,'menubar','none',...
            'numbertitle','off',...
            'Name',trace_name);
%set(fig_num,'position',[15 288 992 420]);          % good for 1024x748
set(fig_num,'position',[6   268   790   300]);      % good for  800x600
clf
hold on
ax = [min(t) max(t)];                   % store min and max t (for the plotting purposes)
kk = 0;
legend_string = [];
for i=1:N
   if exist(deblank(pth(i,:)))
    tmp = read_bor(deblank(pth(i,:)));  % get the data from the data base
    x   = [x tmp(ind)];                 % extract the requested period
    [tmp,indx] = del_num(tmp(ind),0,0); % remove leading zeros from tmp
    tx = t(indx);                       % match with tx
    [tmp,indx] = del_num(tmp,0,1);      % find trailing zeros in tmp
    tx = tx(indx);                      % match with tx

    kk = kk + 1;
    if kk > 10 
        kk = 1;
    end

    plot(tx,tmp*coeff(i) - offset(i),LineTypes(kk,:))
    if ~isempty(trace_legend)
        if i == 1
            legend_string = sprintf('%s%s%s,',39,trace_legend(i,:),39);
        else
            legend_string = sprintf('%s%s%s%s,',legend_string,39,trace_legend(i,:),39);
        end
     end
   end
end
hold off
%ax = axis;
axis([ax(1:2) y_axis])
grid
zoom on
title(trace_name)
xlabel(sprintf('DOY (Year = %d)',year))
ylabel(trace_units)
if ~isempty(legend_string)
    c = sprintf('h = legend(%s,-1);',legend_string(1:length(legend_string)-1));
    eval(c);
%    axes(h); %commented out by Rick, to save graph axis info May 25, 1998
end
