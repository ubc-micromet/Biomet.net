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
% Dec 17, 2003
%   - changed the syntax from if-elseif to ind=find() to vectorize the
%     function and avoid problems when used with Matlab 6.5 and higher

as = asin(sin_a);
ac = acos(cos_a);

alpha_r = NaN * zeros(size(sin_a));

ind = find(cos_a ==  1);
alpha_r(ind) = 0;
ind = find(cos_a ==  -1);
alpha_r(ind) = pi;
ind = find(sin_a ==  1);
alpha_r(ind) = pi/2;
ind = find(sin_a ==  -1);
alpha_r(ind) = pi/2*3;

ind = find(sin_a >  0 & cos_a >  0);
alpha_r(ind) = as(ind);
ind = find(sin_a >  0 & cos_a <  0);
alpha_r(ind) = pi - as(ind);
ind = find(sin_a <  0 & cos_a <  0);
alpha_r(ind) = pi - as(ind);
ind = find(sin_a <  0 & cos_a >  0);
alpha_r(ind) = 2*pi - ac(ind);


%if      cos_a ==  1,                alpha_r = 0;
%elseif  cos_a == -1,                alpha_r = pi;
%elseif  sin_a ==  1,                alpha_r = pi/2;
%elseif  sin_a == -1,                alpha_r = pi/2*3; 
%elseif  sin_a >  0 & cos_a >  0,    alpha_r = as;     
%elseif  sin_a >  0 & cos_a <  0,    alpha_r = pi - as;
%elseif  sin_a <  0 & cos_a <  0,    alpha_r = pi - as;
%elseif  sin_a <  0 & cos_a >  0,    alpha_r = 2*pi - ac;
%end

alpha_d = alpha_r / pi * 180;
