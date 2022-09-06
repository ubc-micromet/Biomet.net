function [meansOut,covsOut] = FR_rotate_by_angle(meansIn,covsIn,angles)
% FR_ROTATE_BY_ANGLE Rotate means and covs using three the three 'classic' 
%                    rotation angles.
%
%   [meansOut,covsOut] = FR_ROTATE_BY_ANGLE(meansIn,covsIn,angles)
%
%   See FR_ANGLES_123 for a defintion of the the three angles.
%
%   See also FR_ANGLES_123, FR_ANGLES_PLANAR_FIT

% (c) kai*       File created:       Nov  2, 2002
%                Last modification:  Nov  2, 2002
%

meansOut = meansIn;                              % initial values for next stage rotation
covsOut  = covsIn;                               %

[NumOfChannels] = size(covsIn,2);
n = length(meansIn(:,1));
o = zeros(n,1);
l = ones(n,1);

%--------------------------------------------------------------------------
% Caculate rot. sin and cos
ce = cos(pi/180.*angles(:,1)); se = sin(pi/180.*angles(:,1));
ct = cos(pi/180.*angles(:,2)); st = sin(pi/180.*angles(:,2));
cb = cos(pi/180.*angles(:,3)); sb = sin(pi/180.*angles(:,3));

%--------------------------------------------------------------------------
% First rotation
Ze = [ ce -se o se ce o o o l];

%---------------------------------------------------
% Second rotation 
Zt = [ ct o -st o l o st o ct];

%---------------------------------------------------
% Third rotation
Zb = [ l o o o cb -sb o sb cb];

%---------------------------------------------------
% Reshape values for multiplication
%---------------------------------------------------
Ze  = reshape(Ze',3,3,n);
Zt  = reshape(Zt',3,3,n);
Zb  = reshape(Zb',3,3,n);

% Put matrices entities on block diagonal
tau     = blkdiag_sp(covsOut(1:3,1:3,:));

% Make single column vectors of vector entities
flux_v  = reshape(shiftdim(covsOut(4:NumOfChannels,1:3,:),1),n*3,NumOfChannels-3);
wind_v  = reshape(meansOut(:,1:3)',n*3,1);

%---------------------------------------------------
% Combine the matrices as requested and rotate
%---------------------------------------------------
Ze     = blkdiag_sp(Ze);
Zt     = blkdiag_sp(Zt);
Zb     = blkdiag_sp(Zb);
Z      = Zb * Zt * Ze; 

tau    = Z * tau * Z';
flux_v = Z * flux_v;
wind_v = Z * wind_v;

%---------------------------------------------------
% Reshape values
tau_out   = full_sp(tau,n,3);

%---------------------------------------------------
% Reshape values and put cov matrices back together
%---------------------------------------------------
tau_out   = full_sp(tau,n,3);
flux_out  = reshape(flux_v',NumOfChannels-3,3,n);

covsOut(1:3,1:3,:) = tau_out;
covsOut(4:NumOfChannels,1:3,:) = flux_out;
% This is not very elegant, but right now I cannot think of anything better...
covsOut(1,4:NumOfChannels,:) = covsOut(4:NumOfChannels,1,:);
covsOut(2,4:NumOfChannels,:) = covsOut(4:NumOfChannels,2,:);
covsOut(3,4:NumOfChannels,:) = covsOut(4:NumOfChannels,3,:);

meansOut(:,1:3) = reshape(wind_v,3,n)';

return