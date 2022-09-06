function [wT_rot, wH_rot, wc_rot] = rotate_cov_matrices(meansIn, C1, C2, T_w)

% Rotation function and WPL for raw covariances (Amanda July 2010)                                 July 2010


%load mean wind vector
% pth = biomet_path(YearX, SiteID);
% u = read_bor(fullfile(pth, 'Flux_Logger', 'u_wind_Avg'));
% v = read_bor(fullfile(pth, 'Flux_Logger', 'v_wind_Avg'));
% w = read_bor(fullfile(pth, 'Flux_Logger', 'w_wind_Avg'));
% 
% meansIn = [u v w];    


% load raw covariances 

% c, H, u, v, w
% c_c = read_bor(fullfile(pth,'Flux_Logger\CO2_cov_Cov1'));
% c_H = read_bor(fullfile(pth,'Flux_Logger\CO2_cov_Cov2'));
% c_u = read_bor(fullfile(pth,'Flux_Logger\CO2_cov_Cov3'));
% c_v = read_bor(fullfile(pth,'Flux_Logger\CO2_cov_Cov4')); 
% c_w = read_bor(fullfile(pth,'Flux_Logger\CO2_cov_Cov5'));   
% H_H = read_bor(fullfile(pth,'Flux_Logger\CO2_cov_Cov6')); 
% H_u = read_bor(fullfile(pth,'Flux_Logger\CO2_cov_Cov7'));
% H_v = read_bor(fullfile(pth,'Flux_Logger\CO2_cov_Cov8'));
% H_w = read_bor(fullfile(pth,'\Flux_Logger\CO2_cov_Cov9'));
% u_u = read_bor(fullfile(pth,'\Flux_Logger\CO2_cov_Cov10'));
% u_v = read_bor(fullfile(pth,'\Flux_Logger\CO2_cov_Cov11'));
% u_w = read_bor(fullfile(pth,'\Flux_Logger\CO2_cov_Cov12'));
% v_v = read_bor(fullfile(pth,'\Flux_Logger\CO2_cov_Cov13'));
% v_w = read_bor(fullfile(pth,'\Flux_Logger\CO2_cov_Cov14'));
% w_w = read_bor(fullfile(pth,'\Flux_Logger\CO2_cov_Cov15'));
% 
% % Tsonic, u, v, w
% T_T = read_bor(fullfile(pth,'Flux_Logger\Tsonic_cov_Cov1'));
% T_u = read_bor(fullfile(pth,'Flux_Logger\Tsonic_cov_Cov2'));
% T_v = read_bor(fullfile(pth,'Flux_Logger\Tsonic_cov_Cov3'));
% T_w = read_bor(fullfile(pth,'Flux_Logger\Tsonic_cov_Cov4'));
% note that we don't need to load the wind covs again--that was done above


% 1. first create matrices with one raw covariance per column, C1 for C and H
% covariances, C2 for Tsonic covariances--note that the wind covariances
% are common to the two covariance matrixes. Note that the columns have to
% be arranged in a specific order so that the covariance matrix formed from it
% in the next step will have right covariances in the right places (see
% assemble_matrix)

%C1 = [u_u  u_v  v_v  u_w  v_w  w_w  c_u  c_v  c_w  c_c  H_u  H_v  H_w  c_H  H_H ];

% we want to reshape C1 into a 3D covariance matrix which will be the same
% length, (i.e. 17520 half-hours), but will be 2D for each half-hour with the following
% entries:

%   | u    v    w    c   H    
% -------------------------
% u | uu   uv   uw   uc  uH   
% v | vu   vv   vw   vc  vH   
% w | wu   wv   ww   wc  wH   
% c | cu   cv   cw   cc  cH   
% H | Hu   Hv   Hw   Hc  HH   

%2.  We do the same thing for the Tsonic covariances, i.e.
 
%C2 = [u_u  u_v  v_v  u_w  v_w  w_w  T_u  T_v  T_w  T_T];

% we want to reshape C2 into a 3D covariance matrix which will be the same
% length, (i.e. 17520 half-hours), but will be 2D for each half-hour,
% with the following entries .

%   | u    v    w    T
% ---------------------
% u | uu  uv   uw   uT   
% v | uv  vv   vw   vT   
% w | uw  vw   ww   wT   
% T | uT  vT   wT   TT   

% 3. Now reshape C1 and C2 into 3D matrices, i.e. one covariance matrix per half-hour
% for the entire year
covsIn1 = assemble_matrix(C1);
covsIn2 = assemble_matrix(C2);

% 4. Now we apply the rotation function to both C1 and C2

% preallocate the output matrices
covsOut1=NaN.*ones(size(covsIn1));
meansOut1 = NaN.*ones(size(meansIn));
angles1 = NaN * ones(length(T_w),3); 
covsOut2=NaN.*ones(size(covsIn2));
meansOut2 = NaN.*ones(size(meansIn));
angles2 = NaN * ones(length(T_w),3); 
for i=1:length(T_w)
%   sprintf('%d of %d\n',i,length(T_w))
   [meansOut1(i,:),covsOut1(:,:,i), angles1(i,:)] = FR_rotate(meansIn(i,:),covsIn1(:,:,i),'THREE');
   [meansOut2(i,:),covsOut2(:,:,i), angles2(i,:)] = FR_rotate(meansIn(i,:),covsIn2(:,:,i),'THREE');
end

% 5. extract w_c, w_H and w_T rotated covariances from covsOut1 and covsOut2

% preallocate output matrices back to 2D (row length = c_w, column length=1)
wc_rot = NaN.*ones(length(T_w),1);
wH_rot = NaN.*ones(length(T_w),1);
wT_rot = NaN.*ones(length(T_w),1);

wc_rot(:) = covsOut1(3,4,:);       % rotated covariances
wH_rot(:) = covsOut1(3,5,:);
wT_rot(:) = covsOut2(3,4,:);

% Input rotated covariances into WPL equation

% load inputs
% cc = read_bor(fullfile(pth,'\Flux_Logger\CO2_Avg'));              % cc is molar CO2 density (mmol/m3)
% cv = read_bor(fullfile(pth,'\Flux_Logger\H2O_Avg'));              % cv is molar water vapour density (mmol/m3)
% T = read_bor(fullfile(pth,'\Flux_Logger\Tsonic_avg')) + 273.15;   % load T and convert to K
% P = read_bor(fullfile(pth,'\Flux_Logger\Irga_P_Avg')) .* 1000;
% c = P ./ (T.*8.314) .* 1000;
% cd = c - cv - cc;
% 
% % calculate
% Fc_rot = (wc_rot + (cc./cd) .* (wH_rot + (c.*wT_rot ./ T))) .* 1000;   % CO2 flux
% 
% E_rot = (1 + (cv./cd)) .* (wH_rot + (cv.*wT_rot ./ T));              % H20 flux
% 
%  % plot graph
%  tv = read_bor(fullfile(pth ,'Flux_Logger\Clean_tv'),8);
%  doy = tv-datenum(2010,1,0)-8/24;
%  plot(doy,Fc_rot);
%  ax=axis;
%  axis([ax(1:2) -20 10]);

    

