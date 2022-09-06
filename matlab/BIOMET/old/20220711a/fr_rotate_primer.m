function fr_rotate_primer
% FR_ROTATE_PRIMER Demonstrate and verify the fr_rotate_package
%   Execute this file to get plots of comparisons between the old and new
%   rotation algorithms.
%
%   See also ASSEMBLE_MATRIX, FR_ANGLES_123, FR_ANGLES_PLANAR_FIT, 
%   FR_ROTATE_BY_ANGLE, FR_ROTATE_123, FR_ROTATE_PF, BLKDIAG_SP, and FULL_SP

%--------------------------------------------------------------------------
% Handling time series of matrices in MATLAB
%--------------------------------------------------------------------------
%
% Time series of matrices occur in eddy correlation when a different rotation 
% matrix is needed for each individual half-hour. The natural way of handling
% these series in MATLAB is to have time as the third dimension, i.e. for size(R)
% of [3 3 N] squeeze(R(:,:,i)) yields the 3x3 rotation matrix for the i-th half-hour
% in the set. 
%
% To see why this is natural in MATLAB try

A = reshape(1:18,3,3,2)
squeeze(A(:,:,1))

% versus

A = reshape(1:18,2,3,3)
squeeze(A(1,:,:))

% In both cases A(:) == 1:18, but in the former case this actually coincides
% with the order of elements in the 3x3 matrixes, i.e. the first three numbers
% are the first column of the first matrx etc. This property is used extensively
% throughout the rotation functions described here.

%--------------------------------------------------------------------------
% Creating time series of matrices from the database
%--------------------------------------------------------------------------
%
% To recreate the time series of covariance matrices from biomet database the 
% function ASSEMBLE_MATRIX is used. Try

help assemble_matrix

% to see what is does. This function returns the time series of covariance matrices 
% when the traces from the database are assembled as they are numbered, i.e.
Years = 2000;
SiteId = 'cr';

pthin = biomet_path(Years,SiteId,'Flux');
ind_cov = [1:36]; % Covers all covariances between u v w T Tc1 Tc2 C and H
for i = 1:length(ind_cov)
	C(:,i) = read_bor([pthin 'covba.' num2str(i)]);
end

covsIn = assemble_matrix(C);

% For reference purposes we are alson going to need these
eta = read_bor([pthin 'angle.1']);
the = read_bor([pthin 'angle.2']);
bet = read_bor([pthin 'angle.3']);
ind_the = find(the>180);
the(ind_the) = the(ind_the)-360;
ind_bet = find(bet>180);
bet(ind_bet) = bet(ind_bet)-360;

pthin = biomet_path(Years,SiteId,'Flux\Clean');
clean_tv = read_bor([pthin 'clean_tv'],8);
u = read_bor([pthin 'wind_speed_u_avg_before_rot_gill']);
v = read_bor([pthin 'wind_speed_v_avg_before_rot_gill']);
w = read_bor([pthin 'wind_speed_w_avg_before_rot_gill']);
tv_doy = convert_tv(clean_tv,'nod');

meansIn = [u v w];

%--------------------------------------------------------------------------
% Rotation by angles
%--------------------------------------------------------------------------
%
% The function FR_ROTATE_BY_ANGLE is used to carry out any rotation defined
% by the three 'classical' angles used in the three rotation procedure by Tanner
% and Thurtell - first a rotation around the orignal z axis, then a rotation 
% around the new y axis, and then a final rotation around the new and already 
% final x axis.
% 
% For any rotation algorithm these angles can be calculated and then used to
% carry out the rotation. So far there are four rotation algorithms implemented: 
% one rotation (into the mean wind, v_bar=0), two rotations (into the mean wind
% vector, v_bar=0 & w_bar=0), three rotations (into the mean wind vector and
% making the lateral momentum flux zero, v_bar=0 & w_bar=0 & wpvp_bar=0, the 
% original Tanner & Thurtell rotation). The angles associated with these three 
% are calculated by FR_ANGLES_123. The forth method is the planar fit (making 
% w_bar disapear on average and rotating into the mean wind). The algorithm for
% finding the angles given by Wilczak et al. is implemented in the function 
% FR_ANGLES_PLANAR_FIT.
% 
% The classical rotations are done like this:

angles_2 = FR_angles_123(meansIn,[],'two');
[means_2,covs_2] = FR_rotate_by_angle(meansIn,covsIn,angles_2);

angles_3 = FR_angles_123(meansIn,covsIn,'three');
[means_3,covs_3] = FR_rotate_by_angle(meansIn,covsIn,angles_3);

plot([eta,the,bet],angles_3,'.');

% For reference purposes there is also a function FR_ROTATE_123 that executes the
% last two steps. When given a single wind vector and covariance matrix it should
% behave exactly like FR_ROTATN and FR_ROTATE but it can of course also deal with 
% time series of wind vectors and matrices.

[means_new,covs_new,angles_new] = FR_rotatn(meansIn(48+24,:),covsIn(:,:,48+24))
[means_rot,covs_rot,angles_rot] = FR_rotate_123(meansIn(48+24,:),covsIn(:,:,48+24))

% A planar fit application would look like this
[angles_pf,b] = FR_angles_planar_fit(meansIn);
meansIn_cor(:,1:2) = meansIn(:,1:2);
meansIn_cor(:,3) = meansIn(:,3) - b(:,1);
[means_pf,covs_pf] = FR_rotate_by_angle(meansIn_cor,covsIn,angles_pf);

% These three steps are summarized in FR_ROTATE_PF
[means_a,covsO_a,angles_a,b_a] = FR_rotate_pf(meansIn,covsIn);

% They do something reasonable
plot(eta,meansIn(:,3),'.',eta,means_pf(:,3),'.',eta,means_a(:,3),'.')
plot(eta,the,'.',eta,angles_pf(:,2),'.',eta,angles_a(:,2),'.')

% We can verify this procedure by applying it to a circle of vectors
deg = [0:365]';
obs = length(deg);
u = cos(pi/180.*deg);
v = sin(pi/180.*deg);
w = 0.1.*cos(pi/180.*(deg-30));

% Normalisation to length 1
circIn = [u v w]./repmat(sqrt(u.^2+v.^2+w.^2),1,3);
cirCovs = assemble_matrix([ones(obs,1) zeros(obs,1) ones(obs,1) zeros(obs,1) zeros(obs,1) ones(obs,1)]);

[means_cir,covs_cir,angles_cir,b_cir] = FR_rotate_pf(circIn,circCovs);

plot(deg,means_cir(:,3),'.',deg,circIn(:,3),'.')
plot(deg,means_cir(:,2),'.',deg,circIn(:,2),'.')
plot(deg,means_cir(:,1),'.',deg,circIn(:,1),'.')

return

%--------------------------------------------------------------------------
% Internal workings of FR_ROTATE_BY_ANGLE
%--------------------------------------------------------------------------
%
% FR_ROTATE_BY_ANGLE is taking advantage of MATLAB's matrix multiplication 
% capability by first creating three rotation matrices from the three rotation
% angles and then multiplying them to get the total rotation matrix. The time
% series are handled by putting the individual matrices on the diagonal of a large
% sparse matrix using the function BLKDIAG_SP. The large sparse rotation matrix
% R and covariance matrix C for the wind component are then multiplied using 
% C_rot = R*C*R'; The result is a sparse matrix with the rotated covariance 
% matrices at the diagonal. It is converted back into the time series format using
% the function FULL_SP. The wind vector time series U and the flux time
% series F are multiplied according to U_rot = R * U; and F_rot = R * F;
% a single step; The later is also used to put the complete rotated covariance
% matrix back together.
