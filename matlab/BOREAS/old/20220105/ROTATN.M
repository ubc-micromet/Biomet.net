function [means3,covs3] = rotatN(means1,covs1)
%
%
%   [means3,covs3] = rotatN(means1,covs1)
%
%
%   This procedure calculates the natural rotation.
%
%
%   First generated on:     12 June 1996 by Paul Yang
%   Last modified on:       20 Aug  1994 by Zoran Nesic
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
covs2(1,1) = covs1(1,1)*ct2*ce2 + covs1(2,2)*ct2*se2 + covs1(3,3)*st2 + 2*covs1(1,2)*ct2*ce*se + 2*covs1(1,3)*ct*st*ce + 2*covs1(2,3)*ct*st*se;
covs2(2,2) = covs1(2,2)*ce2 + covs1(1,1)*se2 - 2*covs1(1,2)*ce*se; 
covs2(3,3) = covs1(3,3)*ct2 + covs1(1,1)*st2*ce2 + covs1(2,2)*st2*se2 - 2*covs1(1,3)*ct*ce*st - 2*covs1(2,3)*ct*st*se + 2*covs1(1,2)*ce*st2*se;
%covs2(1,3) = covs1(1,3)*ce*(ct2-st2) - 2*covs1(1,2)*ct*ce*se*st + covs1(2,3)*se*(ct2-st2) - covs1(1,2)*ct*st*ce2 - covs1(2,2)*ct*st*se2 + covs1(3,3)*ct*st;                                
covs2(1,3) = covs1(1,3)*ce*(ct2-st2) - 2*covs1(1,2)*ct*ce*se*st + covs1(2,3)*se*(ct2-st2) - covs1(1,1)*ct*st*ce2 - covs1(2,2)*ct*st*se2 + covs1(3,3)*ct*st;
covs2(1,2) = covs1(1,2)*ct*(ce2-se2) + covs1(2,3)*ce*st - covs1(1,3)*st*se - covs1(1,1)*ct*ce*se + covs1(2,2)*ct*ce*se;
covs2(2,3) = covs1(2,3)*ce*ct - covs1(1,3)*ct*se - covs1(1,2)*st*(ce2-se2) + covs1(1,1)*st*ce*se - covs1(2,2)*st*ce*se;                                     

for i = 4:NumOfChannels;
    covs2(1,i) = covs1(1,i)*ct*ce + covs1(2,i)*ct*se + covs1(3,i)*st;
    covs2(2,i) = covs1(2,i)*ce - covs1(1,i)*se;
    covs2(3,i) = covs1(3,i)*ct - covs1(1,i)*st*ce - covs1(2,i)*st*se;
end

% Removed by Zoran, Aug 20, 1996
%   (wrong way of making a mirror image of the upper triangle)
%
%for i = 1:NumOfChannels;
%    for j = 1:NumOfChannels;
%        covs2(i,j) = covs2(j,i)';
%    end    
%end

means3 = means2;
covs3 = covs2;

% Iteration procedure for getting cb and sb

cb = 1;
sb = 0;
eps = 10^(-12);
iter = 0;
k = covs2(2,3)./(covs2(2,2)-covs2(3,3));
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

%for i = 1:NumOfChannels;
%    for j = 1:NumOfChannels;
%        covs3(i,j) = covs3(j,i)';
%    end    
%end
