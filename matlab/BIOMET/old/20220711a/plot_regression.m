function [fitstats]=plot_regression(xIn, yIn, plot_min, plot_max, selection)
%  plot_regression(xIn, yIn, plot_min, plot_max)
%
%  1:1 regression plot of variables with the same range.
%   plot_min  - minimum of plot & regression
%   plot_max  - maximum of plot & regression
%   selection - 'none'         uses all data in range and OLS (default)
%               'ortho'        uses all data in range and orthogonal regression
%               'mad'          uses all data in range and MAD
%               'lms'          uses all data in range and least meadian of squares
%			    'polyfit_plus' uses that function to take out outliers
%
% OLS regression assumes that the X-data has no errors and hence optimizes the
% sum of the squares of the vertical distances of data points from the regression 
% line. Therefore the slope may change if X and Y data are switched.
% 'Orthogonal' or type II regression assumes that both the X and Y data have errors and 
% hence optimizes the orthogonal distance of data points from the regression line.
% The slope for this type of regression does not depend on which data are X and which are Y.
%
%  Function assumes that xIn and yIn are of the same length

%  kai* 29.06.2000                              last modified: Oct 16, 2007
%
%  Revisions:
% Oct 16, 2007
%   -enabled output of regression results in fitstats sturctured variable
%   (Nick)
% kai* May 25, 2004
%                Bug fix for MAD option
% kai* June 20, 2001
%                Added option with all points in regression

% Check assumption
if ~(length(xIn) == length(yIn))
    disp('Input data vector must be of the same length');
    return
end

% Default parameter values
if ~exist('plot_min') | isempty(plot_min)
    ind = find(~isnan(xIn.*yIn));
    plot_min = min([min(xIn(ind)) min(yIn(ind))]);
end
if ~exist('plot_max') | isempty(plot_max)
    ind = find(~isnan(xIn.*yIn));
    plot_max = max([max(xIn(ind)) max(yIn(ind))]);
end
if ~exist('selection') | isempty(selection)
    selection = 'none';
end

ind = find(xIn >= plot_min & yIn >= plot_min & xIn <= plot_max & yIn <= plot_max);
    
% Do the regression
switch selection
case 'none'
    [p, r2, sigma, s, Y_hat] = polyfit1(xIn(ind), yIn(ind),1);
    one = (plot_min:(plot_max-plot_min)/(length(xIn)-1):plot_max)';
    reg = p(1) .* one + p(2);
    xReg = NaN .* ones(size(reg));
    yReg = NaN .* ones(size(reg));
    I = ind;
    %------Oct 16, 2007------
    if nargout>0
        fitstats.p = p;
        fitstats.r2 = r2;
        fitstats.sigma = sigma;
        fitstats.R = s.R;
        fitstats.df = s.df;
        fitstats.normr = s.normr;
        fitstats.Yhat = Y_hat;
        fitstats.regrtype = 'OLS';
    end
    %--------------
 case 'ortho'
    a = linregression_orthogonal(xIn(ind), yIn(ind));
    p = a(1:2);
    one = (plot_min:(plot_max-plot_min)/(length(xIn)-1):plot_max)';
    reg = p(1) .* one + p(2);
    xReg = NaN .* ones(size(reg));
    yReg = NaN .* ones(size(reg));
    r2 = a(8);
    I = ind;
    %-------Oct 16, 2007--------
    if nargout>0
        fitstats.a = a;
        fitstats.regrtype = 'Orthogonal Regression';
    end
    %--------------------------
case {'mad' 'robust'} % the later is for legacy reasons
    % Get initial parameter estimate
    [param0] = polyfit1(xIn(ind), yIn(ind),1);
    % Straight line as inline function
    f = inline('param(1) .* x + param(2)','param','x');
    options = fr_optimset('method', 'mad');
    [p,y,outstat] = fr_function_fit(f,param0,yIn(ind),options,xIn(ind));
    r2 = outstat.R2;
    one = (plot_min:(plot_max-plot_min)/(length(xIn)-1):plot_max)';
    reg = p(1) .* one + p(2);
    xReg = NaN .* ones(size(reg));
    yReg = NaN .* ones(size(reg));
    I = ind;
    %-------Oct 16, 2007-----------
    if nargout>0
        fitstats.p = p;
        fitstats.y = y;
        fitstats.outstat = outstat;
        fitstats.regrtype = 'MAD';
    end
    %-----------------------------
case 'lms'
    [p, angle, e] = regress_lms (xIn(ind), yIn(ind), 0.5, 0.05);
    r2 = p(3);
    one = (plot_min:(plot_max-plot_min)/(length(xIn)-1):plot_max)';
    reg = p(1) .* one + p(2);
    xReg = NaN .* ones(size(reg));
    yReg = NaN .* ones(size(reg));
    I = ind;
    %--------Oct 16, 2007--------------
    if nargout>0
        fitstats.p = p;
        fitstats.angle = angle;
        fitstats.e = e;
        fitstats.regrtype = 'LMS';
    end
    %---------------------------------
case 'polyfit_plus'
    try
        [p,xReg,yReg,r2] = polyfit_plus(xIn(ind), yIn(ind),1);
        one = (plot_min:(plot_max-plot_min)/(length(xIn)-1):plot_max)';
        reg = p(1) .* one + p(2);
        [temp,I] = setdiff([xIn yIn], [xReg yReg],'rows');
        %----------Oct 16, 2007--------------
        if nargout>0
            fitstats.p = p;
            fitstats.xReg = xReg;
            fitstats.yReg = yReg;
            fitstats.r2 = r2;
            fitstats.regrtype = 'Polyfit';
        end
        %------------------------------------
    catch
        disp(lasterr);
    end
 end  

RMSE_reg = sqrt(sum(((p(1).*xIn(ind)+p(2))-yIn(ind)).^2)/(length(ind)-2));
% Create the plot (using line to preserve defaulttextfontsize, which plot
% would change)
cla
set(gca,'Box','on');
line(xIn, yIn,'Color','r','Marker','x','LineStyle','none');
line(xReg, yReg,'Color','b','Marker','o','LineStyle','none');
line(one, reg,'Color','b');
line(one, one,'Color','k','LineStyle',':');
axis([plot_min plot_max plot_min plot_max]);
reg_line_str = sprintf('y = %3.3gx%+3.2g\nr^2=%3.2g\nRMSE = %4.3f\nn = %i',p(1),p(2),r2,RMSE_reg,length(ind));

t=text(plot_min+(plot_max-plot_min)/2,plot_min+(plot_max-plot_min)/4,reg_line_str);

font_size_default = get(gca,'DefaultTextFontSize');
set(t,'FontSize',ceil(font_size_default*4/5));
