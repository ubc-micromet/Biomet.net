function [meansOut,covsOut,angles,b] = FR_rotate_pf(meansIn,covsIn)
% FR_Rotate - rotates means and covs using the planar fit method as
%             described by Wilczak.
%
%   [meansOut,covsOut, angles] = FR_rotate(meansIn,covsIn)
%
%   See FR_ANGLES_PLANAR_FIT for a detailed explanation
%
%   See also FR_ROTATE_BY_ANGLE

% (c) kai*       File created:       Oct 31, 2002
%                Last modification:  Oct 31, 2002
%

[angles,b] = FR_angles_planar_fit(meansIn);
meansIn(:,3) = meansIn(:,3) - b(:,1);
[meansOut,covsOut] = FR_rotate_by_angle(meansIn,covsIn,angles);

return
