function direction   = FR_Sonic_wind_direction(wind,sonicType) 
% FR_Sonic_wind_direction - calculates wind direction for various anemometers
%
% (c) Zoran Nesic           File created:       xxx  , 1998
%                           Last revision:      Sep  1, 2004

%Revisions:
%  Sep 1, 2004
%       - Joe found and fixed wind direction for CSAT3.  from east = V to east = -V
%   Aug 22, 2002
%       - Added RMY sonic (RMYoung 810000) - Natascha

DegRad      =   pi/180;
U = wind(1,:);
V = wind(2,:);
direction = zeros(size(U));

if      strcmp(upper(sonicType),'GILLR2')
    ThetaU    =   150 * DegRad;                             % u_axis offset from North
    ThetaV    =   240 * DegRad;                             % v_axis offset from u_axis
    north     =  -(U * cos(ThetaU) + V * cos(ThetaV));
    east      =   -U * sin(ThetaU) - V * sin(ThetaV);
elseif strcmp(upper(sonicType),'GILLR3')
    ThetaU    =   -30 * DegRad;                             % u_axis offset from North
    ThetaV    =  -120 * DegRad;                             % v_axis offset from u_axis
    north     = -(U * cos(ThetaU) + V * cos(ThetaV));       % 
    east      = -(U * sin(ThetaU) + V * sin(ThetaV));
elseif strcmp(upper(sonicType),'CSAT3')
    % CSAT3 =>  U,V,W <=> X,Y,Z.
    % For CSAT3 x and y are orthogonal. BIOMET group will assume
    % that x>0 is wind from North. It follows (from CSAT3 manual, Figure 4-1) that y<0 is
    % is East wind. 
    north = U;                                              
    east  = -V;                                              %
elseif strcmp(upper(sonicType),'RMY')
    % For RMY x and y are orthogonal.
    % It follows from the RMY manual (Page 6) that
    % u > 0 is wind from the east, v > 0 is wind from the north
    north = V;
    east  = U;
else
    return    
end

direction =atan2(east,north)/DegRad;
ind = find(direction<0);
direction(ind) = direction(ind) + 360;
