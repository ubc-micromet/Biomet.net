function [coefficients,r2]= poly_fit(x,y,order);
%*****************************************************************%
% THIS MATLAB FUNCTION FITS AND PLOTS A POLYNOMIAL TO YOUR DATA   %
%                                                                 %
%          function polynomial_fit = poly_fit(x,y,order);         %
%                                                                 %
%          INPUT:                                                 %
%          x = column file name containing the x data             %
%          y = column file name containing the y data             %
%          order = order of fit (1 = linear;2  = quadratic...)    %
%                                                                 %
%          OUTPUT:                                                %
%          correlation coefficient, polynomial coefficeint(s),    %
%          plot showing your data and the polynomial              %
%*****************************************************************%        

ind = find(~isnan(x) & ~isnan(y));
r2 = corrcoef(x(ind),y(ind)).^2;
coefficients = polyfit(x(ind),y(ind),order);
fit = polyval(coefficients,x(ind)); 
figure = plot(x(ind),y(ind),'o',x(ind),fit,'-');
axis('square');
grid;
