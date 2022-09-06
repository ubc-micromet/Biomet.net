function [y_predicted,y_error] = linprediction(a,x)
% [y_predicted,y_error] = linprediction(a,x)
%
% Linear prediction using the output a of linreg. The error returned 
% is the one standard deviation error progression.

y_predicted = a(1) .* (x-a(3)) + a(4);
y_error     = sqrt(a(7).^2+(a(5).*(x-a(3))).^2);