function [meansOut,covsOut, angles] = FR_rotate_123(meansIn,covIn,RotationType)
% FR_ROTATE_123 Calculate rotated statistics for one, two, or three rotations
%
%   This function should behave exactly as fr_rotate, only that it works for single
%   half-hourly statistics as well as time series.

% (c) kai*       File created:       Nov 13, 2002
%                Last modification:  Nov 13, 2002
%

% Default rotation
if ~exist('RotationType') | isempty(RotationType)
   RotationType = 'THREE';
end

[angles] = FR_angles_123(meansIn,covIn,RotationType);
[meansOut,covsOut] = FR_rotate_by_angle(meansIn,covIn,angles)

return
