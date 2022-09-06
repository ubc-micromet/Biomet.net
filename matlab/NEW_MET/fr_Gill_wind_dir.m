function direction   = fr_Gill_wind_dir(wind,sonicType) 

DegRad      =   pi/180;
U = wind(1,:);
V = wind(2,:);

if      strcmp(sonicType,'GILLR2')
    ThetaU    =   210 * DegRad;                             % u_axis offset from North
    ThetaV    =   120 * DegRad;                             % v_axis offset from u_axis
    north     = -(U * cos(ThetaU) + V * cos(ThetaV));
    east      = -(U * sin(ThetaU) + V * sin(ThetaV));
elseif strcmp(sonicType,'GILLR3')
    ThetaU    =    30 * DegRad;                             % u_axis offset from North
    ThetaV    =   120 * DegRad;                             % v_axis offset from u_axis
    north     = U * cos(ThetaU) + V * cos(ThetaV);
    east      = -(U * sin(ThetaU) + V * sin(ThetaV));
end

direction = zeros(size(east));
ind = find( north ~= 0 );
direction(ind) = atan(abs(east(ind) ./ north(ind))) / DegRad;
ind = find(east < 0 & north >= 0);
direction(ind) = 360 - direction(ind);
ind = find(east < 0 & north < 0);
direction(ind) = 180 + direction(ind);
ind = find(east >= 0 & north < 0);
direction(ind) = 180 - direction(ind);
direction = 360 - direction;                                % fixed wind_dir error (Apr 15, 1998)
