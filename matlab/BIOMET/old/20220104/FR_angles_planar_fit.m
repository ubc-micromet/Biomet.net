function [angles,b] = FR_angles_planar_fit(meansIn)
% FR_ANGLES_PLANAR_FIT Calculat angles for planar fit rotation 
%
%   Implements the algorithm for finding the planar fit rotation 
%   angles given in Wilczak et al (2001), BLM 99, p.127ff, and 
%   converts these angles into the classic three angles (around
%   z, intermediate y and final x axis) used in the Tanner & 
%   Thurtel (1969) definition.
%
%   [ANGLES,B] = FR_ANGLES_PLANAR_FIT(MEANSIN) returns the classic
%   angles in ANGLES(:,1:3), the angles alpha, beta and gamma
%   according to Wilczak et al (2001) in ANGLES(:,4:6), and the 
%   rotation coefficients B (eq. (39) in Wilczak et al (2001)).
%   The latter gives mean(w - b(:,1)) == 0.
% 
%   See also FR_ANGLES_123, FR_ROTATE_BY_ANGLE

% (c) Kai Morgenstern   File created:       Nov  2, 2002
%                       Last modification:  Nov  2, 2002

% Eq. no. are from Wilczak et al (2001), BLM 99, p.127ff

obs = length(meansIn);

% Select good measurements
ind = find(~isnan(sum(meansIn,2)));

%---------------------------------------------------------------
% Carry out planar fit
%---------------------------------------------------------------
% In the formulation of Wilczak et al. this is equivalent to 
% finding a unit vector perpendicular the best fit plane (i.e. 
% parallel to the new z axis and two more that depend on 
% wind direction and are parallel to the new x and y axis. 
% These together form the rotation matrix.
[b,k_single]   = find_unit_vector_k(meansIn(ind,:));
[i,j,k] = find_unit_vector_ij(meansIn,k_single);

b = repmat(b',obs,1);

%---------------------------------------------------------------
% Find rotation angles in the Wilczak et al. convetion
%---------------------------------------------------------------
% Eq.(42)
p31 = k_single(1); p32 = k_single(2); p33 = k_single(3);
% Eq.(44)
cosb =  p33/sqrt(p32^2+p33^2);
cosa = sqrt(p32^2+p33^2);
sinb = sqrt(1-cosb.^2);
sina = sqrt(1-cosa.^2);
alphabeta = ones(obs,1) * [acos(cosa) acos(cosb)];
%Eq.(37) - with P = CD multiplied out from cosb and cosa
u_m_c = meansIn - b;
u_p = cosa        .* u_m_c(:,1)                      + sina       .* u_m_c(:,3);
v_p = -sinb.*cosa .* u_m_c(:,1) + cosb .* u_m_c(:,2) - sinb.*cosa .* u_m_c(:,3);
%Eq.(46)
gamma = atan2(v_p,u_p);

angles(:,4:6) = 180/pi .* [alphabeta gamma];

%-----------------------------------------------------------------------------
% Find rotation angles that correspond to the classic eta-theta-beta convention
%-----------------------------------------------------------------------------
% The angles given in Wilczak et al. are defined with respect to their Fig. 1,
% which is different from what we normally do. 

%-----------------------------------------------------------------------------
% Findind eta and theta
% Spherical coordinate of the new x axis with respect to the old coordinate 
% are equivalent to eta and theta. 
[eta,theta,r] = cart2sph(i(:,1),i(:,2),i(:,3));

%-----------------------------------------------------------------------------
% Findind beta
% When j is expressed a coordinate frame rotated around eta and theta, the 
% angle between the new y axis and j is beta. This angle is simply the theta
% in spherical coordinate in the new frame. The eta in these new coordinates 
% will always be 90deg since only a single rotation around the new x axis 
% distinguishes the new y axis and j

% The z axis after two classic rotations is given e.g. in Tanner & Thurtel eq. (16)
ce = cos(eta); se = sin(eta);
ct = cos(theta); st = sin(theta);

j_new(:,1) =   j(:,1).*ct.*ce + j(:,2).*ct.*se + j(:,3).*st;
j_new(:,2) = - j(:,1).*se     + j(:,2).*ce;
j_new(:,3) = - j(:,1).*st.*ce - j(:,2).*st.*se + j(:,3).*ct;

[eta_new,beta,r] = cart2sph(j_new(:,1),j_new(:,2),j_new(:,3));

%-----------------------------------------------------------------------------
% Converting from the +/-180deg convetion to the 0-360deg convention
% angles(:,1:3) = mod(180/pi .* [eta theta beta],360);
angles(:,1:3) = 180/pi .* [eta theta beta];

return