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
%                               Last modification:  Feb  4, 2011
%

% Revisions:
% 
%  Feb  4, 2011 (Zoran)
%       - added removal of the plot values larger than 1e10 to avoid a
%       Matlab bug when it needs to scale down a figure with a large number
%       of data points on the plots with some of them going over 1e30.
%       This fix: 
%           tmp(find(abs(tmp)>1e10)) = NaN; 
%       may cause problems if we ever want to plot large values (>1e10).
%  June 21, 2010 (Nick)
%        - added to fix bug in handling data passed as input: assumes
%          data is already extracted from pl_msig (and therefore
%          year-long traces crashed the program).
%   Jan 5, 2010 (Zoran)
%       - fixed a bug that prevented graphs from plotting if there was a
%       missing trace.  Now the program creates a NaN trace of the same
%       length as the input "ind"
%   Dec 22, 2008
%       - added plotting of 2 auxilary lines to mark the y=0 (horizontal
%       line) and x = last_day-1.  These two lines can help visually with
%       figuring out if all the data has arrived and where the zero
%       crossing is.
%   Jan 4, 2008 (Zoran)
%      - added try-catch to avoid having all view_sites graphs closed when one
%      plot fails.
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

figure(fig_num)
set(fig_num,'menubar','none',...
            'numbertitle','off',...
            'Name',trace_name);
%set(fig_num,'position',[15 288 992 420]);          % good for 1024x748
pos = get(0,'screensize');
set(fig_num,'position',[8 pos(4)/2-20 pos(3)-20 pos(4)/2-35]);      % universal
clf
hold on

try
    if exist('pth') & isstr(pth)
        [N,m] = size(pth);
        if N > m
            error 'Wrong path matrix format: num.of rows > num.of columns!';
        end
        LOAD_DATA = 1;
    else
        [m,N] = size(pth);              % if pth is not a string than assume that it containes data
        LOAD_DATA = 0;                  % flag that enables data loading is set to FALSE
    end
    if nargin < 11
        offset = zeros(1,N);
    end
    if nargin < 10
        coeff = ones(1,N);
    end
    if nargin < 9
        error 'Input parameter(s) missing'
    end

    LineTypes = str2mat('y-','r--','g-.','m:','b-','y--','r-','g:','m-','b--');
    %N = n;                              % find the number of traces
    x = [];

    ax = [min(t) max(t)];                   % store min and max t (for the plotting purposes)
    kk = 0;
    legend_string = [];
    for i=1:N
        if LOAD_DATA == 1 
            if exist(deblank(pth(i,:)))
                tmp = read_bor(deblank(pth(i,:)));  % get the data from the data base
                x   = [x tmp(ind)];                 % extract the requested period
                [tmp,indx] = del_num(tmp(ind),0,0); % remove leading zeros from tmp
                tx = t(indx);                       % match with tx
                [tmp,indx] = del_num(tmp,0,1);      % find trailing zeros in tmp
                tx = tx(indx);                      % match with tx
            else
                % if the current trace does not exist 
                % plot NaNs (Zoran 20100105)
                tx = t(ind);
                tmp = NaN * ones(length(ind),1);
                x = [x tmp];
            end
        else
            tx = t;
            % June 21, 2010 (Nick)
            % added to fix bug in handling data passed as input: assumes
            % data is already extracted from pl_msig (and therefore
            % year-long traces crashed the program).
            tmp = pth(:,i);
            if length(tmp) > length(ind)
                tmp = tmp(ind);
            end
            x = pth;
        end

        kk = kk + 1;
        if kk > 10 
            kk = 1;
        end
        
        tmp(find(abs(tmp)>1e10)) = NaN; 
        plot(tx,tmp.*coeff(i) - offset(i),LineTypes(kk,:))
        if ~isempty(trace_legend)
            if i == 1
                legend_string = sprintf('%s%s%s,',char(39),trace_legend(i,:),char(39));
            else
                legend_string = sprintf('%s%s%s%s,',legend_string,char(39),trace_legend(i,:),char(39));
            end
        end
    end
    hold off
    %ax = axis;
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
    if ~isempty(legend_string) & N > 1
        c = sprintf('h = legend(%s,-1);',legend_string(1:end-1));
        eval(c);
    %    axes(h); %commented out by Rick, to save graph axis info May 25, 1998
    end
catch
    clf
    text(0.03,0.5,'Error while plotting (function: plt\_msig.m)');
    if exist('i') & exist('pth')
        text(0.03,0.4,deblank(pth(i,:)));
    end
    text(0.03,0.3,'Error message:');
    xxx = lasterror;
    text(0.03,0.2,['"' xxx.message '"' ]);
end