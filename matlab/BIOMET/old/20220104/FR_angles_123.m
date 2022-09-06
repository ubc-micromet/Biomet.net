function angles = FR_angels_123(meansIn,covsIn,RotationType)
% FR_ANGLES_123 Calculate rotation angels for one, two, or three rotations
%
%   angles = FR_ANGLES_123(meansIn,covsIn) returns the three 'classical'
%   rotation angles used in the three rotation procedure by Tanner and Thurtell:
%   first a rotation around the orignal z axis, into the mean wind so that v_bar=0,
%   then a rotation around the new y axis into the mean wind vector so that v_bar=0
%   & w_bar=0, and then a final rotation around the new and already final x axis 
%   making the lateral momentum flux zero so that v_bar=0 & w_bar=0 & wpvp_bar=0.
%   These are the angles as defined by Tanner & Thurtell (1969).
%
%   This procedure does rotation on time series of means and covariance matrices
%   assuming that the wind vectors [u v w] are given in rows of meansIn and that 
%   matrices have time as the last dimension.
%
%   angles = FR_ANGLES_123(meansIn,[],'one') returns only the first of these
%   angles in angles(:,1) while angles(:,2:3)=0.
%
%   angles = FR_ANGLES_123(meansIn,[],'two') or
%   angles = FR_ANGLES_123(meansIn,[],'c') returns the first two angles while 
%   angles(:,3)=0.
%
%   angles = FR_ANGLES_123(meansIn,covsIn,'three') or
%   angles = FR_ANGLES_123(meansIn,covsIn,'n') returns the full set.
%
%   This procedure does rotation on the means and covariances assuming that
%   the vectors are given in as the first three elements (uvw).
%
%   Reference: "Research and Development Technical Report ESOM 66-G22-F:
%               Anemoclinometer Measurements of Reynolds Stress and Heat Transport
%               in the Atmospheric Surface Layer", C.B.Tanner & G.W.Thurtell, Apr. 1969
%
%   See also FR_ANGLES_123, FR_ANGLES_PLANAR_FIT, FR_ROTATE_BY_ANGLE

% (c) kai*       File created:       Nov 13, 2002
%                Last modification:  Nov 13, 2002
%

% Default rotation
if ~exist('RotationType') | isempty(RotationType)
   RotationType = 'THREE';
end

%--------------------------------------------------------------------------
% First and second rotation
%--------------------------------------------------------------------------
[eta,theta,r] = cart2sph(meansIn(:,1),meansIn(:,2),meansIn(:,3));

ce = cos(eta); se = sin(eta);
ct = cos(theta); st = sin(theta);

angles = NaN * ones(length(meansIn(:,1)),3);
switch upper(RotationType)
case {'O' 'ONE'}
   angles(:,1) = 180/pi .* [eta];
   angles(:,1) = mod(angles(:,1),360); 
   angles(:,2:3) = 0;
   return
case {'C' 'TWO'}
   angles(:,1:2) = 180/pi .* [eta theta];
   angles(:,1) = mod(angles(:,1),360); 
   angles(:,3) = 0;
   return
end

%--------------------------------------------------------------------------
% Third rotation
%--------------------------------------------------------------------------
% Elements after first two rotations needed to calculate third angle
% Tanner & Thurtell eq. (22)
vp2 = squeeze(covsIn(2,2,:)).*ce.^2 + squeeze(covsIn(1,1,:)).*se.^2 - squeeze(covsIn(1,2,:)).*2.*ce.*se; 
% Tanner & Thurtell eq. (23)
wp2 = squeeze(covsIn(3,3,:)).*ct.^2 + squeeze(covsIn(1,1,:)).*st.^2.*ce.^2 + squeeze(covsIn(2,2,:)).*st.^2.*se.^2 ...
    - squeeze(covsIn(1,3,:)).*2.*ct.*st.*ce - squeeze(covsIn(2,3,:)).*2.*ct.*st.*se ...
    + squeeze(covsIn(1,2,:)).*2.*st.^2.*ce.*se; 
% Tanner & Thurtell eq. (26)
vpwp = squeeze(covsIn(2,3,:)).*ct.*ce - squeeze(covsIn(1,3,:)).*ct.*se - squeeze(covsIn(1,2,:)).*st.*(ce.^2-se.^2) ...
       + squeeze(covsIn(1,1,:)).*st.*ce.*se - squeeze(covsIn(2,2,:)).*st.*ce.*se;
    
% This replaces the iterative search in Tanner & Thurtell
% see Kai's notebook, Nov 1, 2002 for a derivation
K = (wp2 - vp2) ./ (2.*vpwp);
bet = atan( K + sqrt(1 + K.^2) );

%--------------------------------------------------------------------------
% Assemble angles as neccessary
%--------------------------------------------------------------------------
switch upper(RotationType)
case {'THREE' 'N'}
   angles(:,1:3) = 180/pi .* [eta theta bet];
   angles(:,1) = mod(angles(:,1),360); 
   angles(:,3) = mod(angles(:,3)-45,90)-45;
otherwise
   disp('Unknown rotation type - returning');
end

return
