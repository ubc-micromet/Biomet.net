function [means3,covs3, scalcovsu3, scalcovsv3, scalcovsw3, angles] = ...
   oy_rotatN(means1,covs1,scalcovsu1,scalcovsv1,scalcovsw1)
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
% (c) E. Humphreys      File created:       Aug 29, 2000
%                       Last modification:  
%
%
% Revisions:
%
%   Aug 29, 2000
%       - capable of vector calcs for hhour-style data
%   Mar 11, 1999
%       - added proper handling of fault values when calculating k.
%   Feb 11, 1998
%       -   comments
%   Feb 10, 1998
%       -   Made the output matrix covs3 symetric around its diagonal
%


NumOfChannels = size(scalcovsu1,2);
means2 = means1;
covs2 = covs1;
scalcovsu2 = scalcovsu1;
scalcovsv2 = scalcovsv1;
scalcovsw2 = scalcovsw1;

u = means1(:,1);
v = means1(:,2);
w = means1(:,3);
U = sqrt(u.^2 + v.^2);
UU = sqrt(u.^2 + v.^2 + w.^2); 
ce = u ./ U;
se = v ./ U;
ct = U ./ UU;
st = w ./ UU;

means2(:,1) = u.*ct.*ce + v.*ct.*se + w.*st;
means2(:,2) = v.*ce - u.*se;
means2(:,3) = w.*ct - u.*st.*ce - v.*st.*se;

ce2 = ce.^2;
se2 = se.^2;
ct2 = ct.^2;
st2 = st.^2;
covs2(:,1)  = covs1(:,1).*ct2.*ce2 + covs1(:,2).*ct2.*se2 + covs1(:,3).*st2 + ...
              2.*covs1(:,4).*ct2.*ce.*se + 2.*covs1(:,5).*ct.*st.*ce + 2.*covs1(:,6).*ct.*st.*se;
covs2(:,2)  = covs1(:,2).*ce2 + covs1(:,1).*se2 - 2.*covs1(:,4).*ce.*se; 
covs2(:,3)  = covs1(:,3).*ct2 + covs1(:,1).*st2.*ce2 + covs1(:,2).*st2.*se2 - ...
              2.*covs1(:,5).*ct.*ce.*st - 2.*covs1(:,6).*ct.*st.*se + 2.*covs1(:,4).*ce.*st2.*se;
covs2(:,5)  = covs1(:,5).*ce.*(ct2-st2) - 2.*covs1(:,4).*ct.*ce.*se.*st + ...
              covs1(:,6).*se.*(ct2-st2) - covs1(:,1).*ct.*st.*ce2 - ...
              covs1(:,2).*ct.*st.*se2 + covs1(:,3).*ct.*st;
covs2(:,4)  = covs1(:,4).*ct.*(ce2-se2) + covs1(:,6).*ce.*st - covs1(:,5).*st.*se - ...
              covs1(:,1).*ct.*ce.*se + covs1(:,2).*ct.*ce.*se;
covs2(:,6)  = covs1(:,6).*ce.*ct - covs1(:,5).*ct.*se - covs1(:,4).*st.*(ce2-se2) + ...
              covs1(:,1).*st.*ce.*se - covs1(:,2).*st.*ce.*se;                                     

for i = 1:NumOfChannels;
   scalcovsu2(:,i) = scalcovsu1(:,i).*ct.*ce + scalcovsv1(:,i).*ct.*se + ...
      scalcovsw1(3,i).*st;
   scalcovsv2(:,i) = scalcovsv1(:,i).*ce - scalcovsu1(:,i).*se;
   scalcovsw2(:,i) = scalcovsw1(:,i).*ct - scalcovsu1(:,i).*st.*ce - scalcovsv1(:,i).*st.*se;
end

means3 = means2;
covs3 = covs2;
scalcovsu3 = scalcovsu2;
scalcovsv3 = scalcovsv2;
scalcovsw3 = scalcovsw2;

% Iteration procedure for getting cb and sb

cb = 1;
sb = 0;
eps = 10.^(-12);
iter = 0;

% if error is about to happen (when calculating k), set all the outputs to
% NaNs, print a message on the screen and quit. Mar 11, 1999
if covs2(:,6) == 0 | (covs2(:,2)-covs2(:,3))== 0
    angles=[NaN NaN NaN];
    means3 = NaN * zeros(size(means3));
    covs3 =  NaN * zeros(size(covs3));
    disp('Error in FR_rotatn.m. All outputs will be set to NaN!');
    return
else
    k = covs2(:,6)./(covs2(:,2)-covs2(:,3));
end

for i = 1:100
    sb0 = sb;
    cb0 = cb;
    sb = 0.25.*(-cb0 + sqrt(cb0.^2+8.*k.^2))./k;
    cb = sqrt(abs(1-sb.^2));
    iter = iter + 1;
    if abs(sb - sb0) <= eps & abs(cb - cb0) <= eps
        break
    end
end

means3(:,2) = means2(:,2).*cb + means2(:,3).*sb;
means3(:,3) = means2(:,3).*cb - means2(:,2).*sb;

covs3(:,2) = covs2(:,2).*cb.^2 + 2.*covs2(:,6).*cb.*sb + covs2(:,3).*sb.^2;
covs3(:,3) = covs2(:,3).*cb.^2 - 2.*covs2(:,6).*cb.*sb + covs2(:,2).*sb.^2;
covs3(:,5) = covs2(:,5).*cb - covs2(:,4).*sb;
covs3(:,4) = covs2(:,4).*cb + covs2(:,5).*sb;
covs3(:,6) = covs2(:,6).*(cb.^2 - sb.^2) + covs2(:,3).*cb.*sb - covs2(:,2).*cb.*sb;

for i = 1:NumOfChannels;
    scalcovsv3(:,i) = scalcovsv2(:,i).*cb + scalcovsw2(:,i).*sb;
    scalcovsw3(:,i) = scalcovsw2(:,i).*cb - scalcovsv2(:,i).*sb;
end

%y = covs3';                         % make covs3 matrix symetric
%ind= (tril(y,0)==0);                % using its upper triangle 
%y(ind) = covs3(ind);                %
%covs3 = y;

%output angles in degrees (0-359)
[junk, e] = get_angle(se,ce);
[junk, th]= get_angle(st,ct);
[junk, b] = get_angle(sb,cb);

angles=[e th b];