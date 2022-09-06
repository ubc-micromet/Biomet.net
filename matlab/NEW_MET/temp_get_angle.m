
function [alpha_r, alpha_d] = get_angle(sin_a, cos_a)
%
% Get a four quadrant angle alpha for given
%   cos(alpha) and sin(alpha)
%
% Inputs:
%   sin_a       - sine of alpha
%   cos_a       - cosine of alpha
%
% Outputs:
%   alpha_r     - angle in radians (0 to 2pi-)
%   alpha_d     - angle in degrees (0 to 360deg-)
%
% Last modification:    Feb  8, 1998
%
% Revisions
%

as = asin(sin_a);
ac = acos(cos_a);

if      cos_a ==  1,                alpha_r = 0;        alpha_d = 1;
elseif  cos_a == -1,                alpha_r = pi;       alpha_d = 2;
elseif  sin_a ==  1,                alpha_r = pi/2;     alpha_d = 1;
elseif  sin_a == -1,                alpha_r = pi/2*3;   alpha_d = 4;
elseif  sin_a >  0 & cos_a >  0,    alpha_r = as;         alpha_d = 1;
elseif  sin_a >  0 & cos_a <  0,    alpha_r = pi - as;    alpha_d = 2;
elseif  sin_a <  0 & cos_a <  0,    alpha_r = pi - as;    alpha_d = 3;
elseif  sin_a <  0 & cos_a >  0,    alpha_r = 2*pi - ac;  alpha_d = 4;
end
