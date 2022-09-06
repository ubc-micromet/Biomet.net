function [meansOut,covsOut, angles] = FR_rotate(meansIn,covsIn,RotationType)
% FR_Rotate - rotates means and covs using one, two or three rotations
%
%   [meansOut,covsOut, angles] = FR_rotate(meansIn,covsIn,RotationType)
%
%
%   This procedure does rotation on the means and covariances assuming that
%   the vectors are given in as the first three elements (uvw).
%
%   Used rotatn.m as the starting point:
%   ROTATN.M: (First generated on: June 12 1996 by Paul Yang)
%   Reference: "Research and Development Technical Report ESOM 66-G22-F:
%               Anemoclinometer Measurements of Reynolds Stress and Heat Transport
%               in the Atmospheric Surface Layer", C.B.Tanner & G.W.Thurtell, Apr. 1969
%   
%
% (c) Zoran Nesic       File created:       Oct 13, 2001
%                       Last modification:  Oct 13, 2001
%

%
% Revisions:
% Oct 8, 2002 - fixed small bug with rotation type breaks in program and angles output
%
%


NumOfChannels = length(covsIn);                  % find number of variables
angles = NaN * ones(1,3);                        % Initiate angles

meansOut = meansIn;                              % initial values for next stage rotation
covsOut  = covsIn;                               %

u = meansIn(1);
v = meansIn(2);
w = meansIn(3);
U = sqrt(u^2 + v^2);
UU = sqrt(u^2 + v^2 + w^2); 


% First rotation
ce = u ./ U;
se = v ./ U;
%output angles in degrees (0-359)
[junk, angles(1)] = get_angle(se,ce);
Ze  = [ ce  se  0; ...
       -se  ce  0; ...
         0   0  1  ];
%meansOut(1:3) = Ze * meansIn(1:3);              % rotate means

meansOut(1) = meansIn(1)*ce + meansIn(2)*se;
meansOut(2) = meansIn(2)*ce - meansIn(1)*se;

covs1 = covsIn;

covs1(1,1) = covsIn(1,1)*ce^2 + covsIn(2,2)*se^2 + 2*covsIn(1,2)*ce*se;
covs1(2,2) = covsIn(2,2)*ce^2 + covsIn(1,1)*se^2 - 2*covsIn(1,2)*ce*se;
covs1(1,2) = covsIn(1,2)*ce^2 + (covsIn(2,2) - covsIn(1,1))*ce*se - covsIn(1,2)*se^2;
covs1(2,1) = covs1(1,2);
covs1(1,3) = covsIn(1,3)*ce + covsIn(2,3)*se;
covs1(3,1) = covs1(1,3);
covs1(2,3) = covsIn(2,3)*ce - covsIn(1,3)*se;
covs1(3,2) = covs1(2,3);
i = 4:NumOfChannels;
covs1(1,i) = covsIn(1,i)*ce + covsIn(2,i)*se;
covs1(i,1) = covs1(1,i)';
covs1(2,i) = covsIn(2,i)*ce - covsIn(1,i)*se;
covs1(i,2) = covs1(2,i)';

covsOut = covs1;
y = covsOut';                               % make covsOut matrix symetric
ind= (tril(y,0)==0);                        % using its upper triangle 
y(ind) = covsOut(ind);                      %
covsOut = y;

% return if done
if strcmp(upper(RotationType),'O') | strcmp(upper(RotationType),'ONE'), return, end


% Second rotation (done from scratch, didn't take advantage of the 
% results in the previous step

ct = U ./ UU;
st = w ./ UU;
%output angles in degrees (0-359)
[junk, angles(2)]= get_angle(st,ct);
Zth = [ ct   0  st ; ...
         0   1   0 ; ...
       -st   0  ct ];

means2  = meansIn;
covs2   = covsIn;

means2(1) = u*ct*ce + v*ct*se + w*st;
means2(2) = v*ce - u*se;
means2(3) = w*ct - u*st*ce - v*st*se;

ce2 = ce^2;
se2 = se^2;
ct2 = ct^2;
st2 = st^2;
covs2(1,1)  = covsIn(1,1)*ct2*ce2 + covsIn(2,2)*ct2*se2 + covsIn(3,3)*st2 + ...
              2*covsIn(1,2)*ct2*ce*se + 2*covsIn(1,3)*ct*st*ce + 2*covsIn(2,3)*ct*st*se;
covs2(2,2)  = covsIn(2,2)*ce2 + covsIn(1,1)*se2 - 2*covsIn(1,2)*ce*se; 
covs2(3,3)  = covsIn(3,3)*ct2 + covsIn(1,1)*st2*ce2 + covsIn(2,2)*st2*se2 - ...
              2*covsIn(1,3)*ct*ce*st - 2*covsIn(2,3)*ct*st*se + 2*covsIn(1,2)*ce*st2*se;
covs2(1,3)  = covsIn(1,3)*ce*(ct2-st2) - 2*covsIn(1,2)*ct*ce*se*st + ...
              covsIn(2,3)*se*(ct2-st2) - covsIn(1,1)*ct*st*ce2 - ...
              covsIn(2,2)*ct*st*se2 + covsIn(3,3)*ct*st;
covs2(1,2)  = covsIn(1,2)*ct*(ce2-se2) + covsIn(2,3)*ce*st - covsIn(1,3)*st*se - ...
              covsIn(1,1)*ct*ce*se + covsIn(2,2)*ct*ce*se;
covs2(2,3)  = covsIn(2,3)*ce*ct - covsIn(1,3)*ct*se - covsIn(1,2)*st*(ce2-se2) + ...
              covsIn(1,1)*st*ce*se - covsIn(2,2)*st*ce*se;                                     

for i = 4:NumOfChannels;
    covs2(1,i) = covsIn(1,i)*ct*ce + covsIn(2,i)*ct*se + covsIn(3,i)*st;
    covs2(2,i) = covsIn(2,i)*ce - covsIn(1,i)*se;
    covs2(3,i) = covsIn(3,i)*ct - covsIn(1,i)*st*ce - covsIn(2,i)*st*se;
end

meansOut = means2;
covsOut = covs2;

y = covsOut';                               % make covsOut matrix symetric
ind= (tril(y,0)==0);                        % using its upper triangle 
y(ind) = covsOut(ind);                      %
covsOut = y;

% return if done
if strcmp(upper(RotationType),'C') | strcmp(upper(RotationType),'TWO'), return, end

% Iteration procedure for getting cb and sb

cb = 1;
sb = 0;
eps = 10^(-12);
iter = 0;

% if error is about to happen (when calculating k), set all the outputs to
% NaNs, print a message on the screen and quit. Mar 11, 1999
if covs2(2,3) == 0 | (covs2(2,2)-covs2(3,3))== 0
    meansOut = NaN * zeros(size(meansOut));
    covsOut =  NaN * zeros(size(covsOut));
    disp('Error in FR_rotate.m. All outputs will be set to NaN!');
    return
else
    k = covs2(2,3)./(covs2(2,2)-covs2(3,3));
end

for i = 1:100
    sb0 = sb;
    cb0 = cb;
    sb = 0.25*(-cb0 + sqrt(cb0^2+8*k^2))./k;
    cb = sqrt(abs(1-sb^2));
    iter = iter + 1;
    if abs(sb - sb0) <= eps & abs(cb - cb0) <= eps
        break
    end
end

%output angles in degrees (0-359)
[junk, angles(3)] = get_angle(sb,cb);


meansOut(2) = means2(2)*cb + means2(3)*sb;
meansOut(3) = means2(3)*cb - means2(2)*sb;

covsOut(2,2) = covs2(2,2)*cb^2 + 2*covs2(2,3)*cb*sb + covs2(3,3)*sb^2;
covsOut(3,3) = covs2(3,3)*cb^2 - 2*covs2(2,3)*cb*sb + covs2(2,2)*sb^2;
covsOut(1,3) = covs2(1,3)*cb - covs2(1,2)*sb;
covsOut(1,2) = covs2(1,2)*cb + covs2(1,3)*sb;
covsOut(2,3) = covs2(2,3)*(cb^2 - sb^2) + covs2(3,3)*cb*sb - covs2(2,2)*cb*sb;

for i = 4:NumOfChannels;
    covsOut(2,i) = covs2(2,i)*cb + covs2(3,i)*sb;
    covsOut(3,i) = covs2(3,i)*cb - covs2(2,i)*sb;
end

y = covsOut';                               % make covsOut matrix symetric
ind= (tril(y,0)==0);                        % using its upper triangle 
y(ind) = covsOut(ind);                      %
covsOut = y;


