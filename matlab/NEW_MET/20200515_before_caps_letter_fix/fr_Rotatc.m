function [means2, covs2, angles] = fr_rotatC(means1,covs1)
%
%
%   [means2,covs2, angles] = rotatC(means1,covs1)
%
%
% This procedure calculates the 'canopy' rotation.
% Rotates only 2 ways: the x,y plane is rotated about the z-axis and y_axis such that
% mean w = mean v = 0 through angles eta and theta
% without rotation about the x-axis as in fr_rotatn.m (angle beta)
%
% Used rotatc.m as the starting point:
% ROTATc.M: (First generated on: June 12 1996 by Paul Yang)
%   
%
% (c) E. Humphreys      26.02.01  
%

%
% Revisions:
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

y   = covs2';                        % make covs2 matrix symetric
ind = (tril(y,0)==0);                % using its upper triangle 
y(ind) = covs2(ind);                 %
covs2  = y;

%output angles in degrees (0-359)
[junk, e] = get_angle(se,ce);
[junk, th]= get_angle(st,ct);

angles=[e th NaN];

