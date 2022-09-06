function y = ustar_correction(params,x)
% Calculates value of the u* correction
%
% For details on the u* correction see Peter Blanken's thesis p.31
%
% y = ustar_correction(params,x)
%
% Input:    params - parameters of the function
%           x      - well...
%
% Output:   y - value of function at x
%
% (C) Kai Morgenstern				File created:  07.09.00
%											Last modified: 07.09.00                                    

% Revision:

% y=(params(1)-params(4))./(1 + exp(params(2).*(params(3)-x))) + params(4);
y=1./(1 + exp(-params(1).*(x-params(2))));

