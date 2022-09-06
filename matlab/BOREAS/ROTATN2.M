function [meansOld, covs1,means3, covs3, DetrendData] = rotatN2(RawData, DetrendFlag)
%
%   [meansOld, covs1,means3, covs3, DetrendData] = rotatN2(RawData, DetrendFlag)
%
%
% Inputs:
%   RawData     - input matrix, first 3 columns are u,v and w
%   DetrendFlag - if 0 do not do detrending, else detrend
%
%   This procedure calculates the natural rotation using 
%   linear detrending.
%
%
%   First generated on:     12 Jun 1996 by Paul Yang
%   Last modified on:        2 Nov 1996 by Zoran Nesic
%
[n,m] = size(RawData);
NumOfChannels = min(n,m);
if m ~= NumOfChannels
    RawData = RawData.';
end
meansOld = mean(RawData);

if nargin < 2 
    DetrendFlag = 1;
end
if DetrendFlag ~= 0
    DetrendData = zeros(size(RawData));
    for i=1:NumOfChannels;
        DetrendData(:,i) = detrend(RawData(:,i));
    end
else
    DetrendData = RawData;
end

covs1 = cov(DetrendData);

u = meansOld(1);
v = meansOld(2);
w = meansOld(3);
U = sqrt(u^2 + v^2);
UU = sqrt(u^2 + v^2 + w^2); 
ce = u ./ U;
se = v ./ U;
ct = U ./ UU;
st = w ./ UU;

ce2 = ce^2;
se2 = se^2;
ct2 = ct^2;
st2 = st^2;

covs2      = covs1;
covs2(1,1) = covs1(1,1)*ct2*ce2 + covs1(2,2)*ct2*se2 + covs1(3,3)*st2 + 2*covs1(1,2)*ct2*ce*se + 2*covs1(1,3)*ct*st*ce + 2*covs1(2,3)*ct*st*se;
covs2(2,2) = covs1(2,2)*ce2 + covs1(1,1)*se2 - 2*covs1(1,2)*ce*se; 
covs2(3,3) = covs1(3,3)*ct2 + covs1(1,1)*st2*ce2 + covs1(2,2)*st2*se2 - 2*covs1(1,3)*ct*ce*st - 2*covs1(2,3)*ct*st*se + 2*covs1(1,2)*ce*st2*se;
covs2(1,3) = covs1(1,3)*ce*(ct2-st2) - 2*covs1(1,2)*ct*ce*se*st + covs1(2,3)*se*(ct2-st2) - covs1(1,1)*ct*st*ce2 - covs1(2,2)*ct*st*se2 + covs1(3,3)*ct*st;
covs2(1,2) = covs1(1,2)*ct*(ce2-se2) + covs1(2,3)*ce*st - covs1(1,3)*st*se - covs1(1,1)*ct*ce*se + covs1(2,2)*ct*ce*se;
covs2(2,3) = covs1(2,3)*ce*ct - covs1(1,3)*ct*se - covs1(1,2)*st*(ce2-se2) + covs1(1,1)*st*ce*se - covs1(2,2)*st*ce*se;                                     

for i = 4:NumOfChannels;
    covs2(1,i) = covs1(1,i)*ct*ce + covs1(2,i)*ct*se + covs1(3,i)*st;
    covs2(2,i) = covs1(2,i)*ce - covs1(1,i)*se;
    covs2(3,i) = covs1(3,i)*ct - covs1(1,i)*st*ce - covs1(2,i)*st*se;
end

covs3 = covs2;

% Iteration procedure for getting cb and sb

cb = 1;
sb = 0;
eps = 10^(-12);
iter = 0;
%[covs2(2,3) covs2(2,2) covs2(3,3)]
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


covs3(2,2) = covs2(2,2)*cb^2 + 2*covs2(2,3)*cb*sb + covs2(3,3)*sb^2;
covs3(3,3) = covs2(3,3)*cb^2 - 2*covs2(2,3)*cb*sb + covs2(2,2)*sb^2;
covs3(1,3) = covs2(1,3)*cb - covs2(1,2)*sb;
covs3(1,2) = covs2(1,2)*cb + covs2(1,3)*sb;
covs3(2,3) = covs2(2,3)*(cb^2 - sb^2) + covs2(3,3)*cb*sb - covs2(2,2)*cb*sb;

for i = 4:NumOfChannels;
    covs3(2,i) = covs2(2,i)*cb + covs2(3,i)*sb;
    covs3(3,i) = covs2(3,i)*cb - covs2(2,i)*sb;
end

means2      = meansOld;
means2(1)   = meansOld(1) * ct * ce + meansOld(2) * ct * se + meansOld(3) * st;
v_prime     = meansOld(2) * ce - meansOld(1) * se;
w_prime     = meansOld(3) * ct - meansOld(1) * st *ce - meansOld(2) * st * se;
means2(2)   = v_prime * cb + w_prime * sb;
means2(3)   = w_prime * cb - v_prime * sb;
means2(4:8) = meansOld(4:8);

means3    = means2;
means3(2) = means2(2)*cb + means2(3)*sb;
means3(3) = means2(3)*cb - means2(2)*sb;

