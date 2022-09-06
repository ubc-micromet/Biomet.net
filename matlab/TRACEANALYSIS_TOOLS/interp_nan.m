function y = interp_nan(XX,YY)
%
% y = interp_nan(XX,YY)
%
% this function interpolates NaN data 
%
%(C)Bill Chen  							File created:  Mar. 22, 1998
%												Last modified: Mar. 22, 1998
%

ind = find(~isnan(YY));
t1 = XX(ind);
y1 = YY(ind);
y = interp1(t1,y1,XX);
