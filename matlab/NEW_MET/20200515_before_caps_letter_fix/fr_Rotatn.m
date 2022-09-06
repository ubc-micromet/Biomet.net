function [means3,covs3, angles] = FR_rotatN(means1,covs1)
%
%
%   [means3,covs3, angles] = rotatN(means1,covs1)
%
%
%   This procedure calculates the natural rotation.
%
% Used rotatn.m as the starting point:
% ROTATN.M: (First generated on: June 12 1996 by Paul Yang)
%   
%
% (c) Zoran Nesic       File created:       Feb  8, 1998
%                       Last modification:  Mar 11, 1999
%

%
% Revisions:
%
%   Mar 11, 1999
%       - added proper handling of fault values when calculating k.
%   Feb 11, 1998
%       -   comments
%   Feb 10, 1998
%       -   Made the output matrix covs3 symetric around its diagonal
%


NumOfChannels = length(covs1);
means2 = means1;
covs2 = covs1;
u = means1(1);
v = means1(2);
w = means1(3);
U = sqrt(u^2 + v^2);
UU = sqrt(u^2 + v^2 + w^2); 
ce = u ./ U;
se = v ./ U;
ct = U ./ UU;
st = w ./ UU;

means2(1) = u*ct*ce + v*ct*se + w*st;
means2(2) = v*ce - u*se;
means2(3) = w*ct - u*st*ce - v*st*se;

ce2 = ce^2;
se2 = se^2;
ct2 = ct^2;
st2 = st^2;
covs2(1,1)  = covs1(1,1)*ct2*ce2 + covs1(2,2)*ct2*se2 + covs1(3,3)*st2 + ...
              2*covs1(1,2)*ct2*ce*se + 2*covs1(1,3)*ct*st*ce + 2*covs1(2,3)*ct*st*se;
covs2(2,2)  = covs1(2,2)*ce2 + covs1(1,1)*se2 - 2*covs1(1,2)*ce*se; 
covs2(3,3)  = covs1(3,3)*ct2 + covs1(1,1)*st2*ce2 + covs1(2,2)*st2*se2 - ...
              2*covs1(1,3)*ct*ce*st - 2*covs1(2,3)*ct*st*se + 2*covs1(1,2)*ce*st2*se;
covs2(1,3)  = covs1(1,3)*ce*(ct2-st2) - 2*covs1(1,2)*ct*ce*se*st + ...
              covs1(2,3)*se*(ct2-st2) - covs1(1,1)*ct*st*ce2 - ...
              covs1(2,2)*ct*st*se2 + covs1(3,3)*ct*st;
covs2(1,2)  = covs1(1,2)*ct*(ce2-se2) + covs1(2,3)*ce*st - covs1(1,3)*st*se - ...
              covs1(1,1)*ct*ce*se + covs1(2,2)*ct*ce*se;
covs2(2,3)  = covs1(2,3)*ce*ct - covs1(1,3)*ct*se - covs1(1,2)*st*(ce2-se2) + ...
              covs1(1,1)*st*ce*se - covs1(2,2)*st*ce*se;                                     

for i = 4:NumOfChannels;
    covs2(1,i) = covs1(1,i)*ct*ce + covs1(2,i)*ct*se + covs1(3,i)*st;
    covs2(2,i) = covs1(2,i)*ce - covs1(1,i)*se;
    covs2(3,i) = covs1(3,i)*ct - covs1(1,i)*st*ce - covs1(2,i)*st*se;
end

means3 = means2;
covs3 = covs2;

% Iteration procedure for getting cb and sb

cb = 1;
sb = 0;
eps = 10^(-12);
iter = 0;

% if error is about to happen (when calculating k), set all the outputs to
% NaNs, print a message on the screen and quit. Mar 11, 1999
if covs2(2,3) == 0 | (covs2(2,2)-covs2(3,3))== 0
    angles=[NaN NaN NaN];
    means3 = NaN * zeros(size(means3));
    covs3 =  NaN * zeros(size(covs3));
    disp('Error in FR_rotatn.m. All outputs will be set to NaN!');
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

means3(2) = means2(2)*cb + means2(3)*sb;
means3(3) = means2(3)*cb - means2(2)*sb;

covs3(2,2) = covs2(2,2)*cb^2 + 2*covs2(2,3)*cb*sb + covs2(3,3)*sb^2;
covs3(3,3) = covs2(3,3)*cb^2 - 2*covs2(2,3)*cb*sb + covs2(2,2)*sb^2;
covs3(1,3) = covs2(1,3)*cb - covs2(1,2)*sb;
covs3(1,2) = covs2(1,2)*cb + covs2(1,3)*sb;
covs3(2,3) = covs2(2,3)*(cb^2 - sb^2) + covs2(3,3)*cb*sb - covs2(2,2)*cb*sb;

for i = 4:NumOfChannels;
    covs3(2,i) = covs2(2,i)*cb + covs2(3,i)*sb;
    covs3(3,i) = covs2(3,i)*cb - covs2(2,i)*sb;
end

y = covs3';                         % make covs3 matrix symetric
ind= (tril(y,0)==0);                % using its upper triangle 
y(ind) = covs3(ind);                %
covs3 = y;

%output angles in degrees (0-359)
[junk, e] = get_angle(se,ce);
[junk, th]= get_angle(st,ct);
[junk, b] = get_angle(sb,cb);

angles=[e th b];