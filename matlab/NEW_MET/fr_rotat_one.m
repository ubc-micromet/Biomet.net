function [means1, covs1, angles] = fr_rotat_one(means,covs)
%-------------------------------------------------------------------------------------
%
%Direct modification of rotatc.  This program calculates the rotation 
%to make mean(V) = 0 
%
%then uses get angle to calculate the rotation angle.  
%
%
%  August 27, 2000  -GBD
%
%
%-------------------------------------------------------------------------------------

NumOfChannels = length(covs);
means1 = means;
covs1 = covs;
co = means(1)/sqrt(means(1)^2 + means(2)^2);
si = means(2)/sqrt(means(1)^2 + means(2)^2);
means1(1) = means(1)*co + means(2)*si;
means1(2) = means(2)*co - means(1)*si;
covs1(1,1) = covs(1,1)*co^2 + covs(2,2)*si^2 + 2*covs(1,2)*co*si;
covs1(2,2) = covs(2,2)*co^2 + covs(1,1)*si^2 - 2*covs(1,2)*co*si;
covs1(1,2) = covs(1,2)*co^2 + (covs(2,2) - covs(1,1))*co*si - covs(1,2)*si^2;
covs1(2,1) = covs1(1,2);
covs1(1,3) = covs(1,3)*co + covs(2,3)*si;
covs1(3,1) = covs1(1,3);
covs1(2,3) = covs(2,3)*co - covs(1,3)*si;
covs1(3,2) = covs1(2,3);
i = 4:NumOfChannels;
covs1(1,i) = covs(1,i)*co + covs(2,i)*si;
covs1(i,1) = covs1(1,i)';
covs1(2,i) = covs(2,i)*co - covs(1,i)*si;
covs1(i,2) = covs1(2,i)';

%output angles in degrees (0-359)
[junk, e] = get_angle(si,co);

angles=[e NaN NaN];

