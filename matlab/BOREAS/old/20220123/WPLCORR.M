function [means3,covs3] = WPLcorr(means2,covs2)
%
%
%	 [means3,covs3] = WPLcorr(means2,covs2)
%
%
%	This function calculates WPL correction.
%
%
means3 = means2;
covs3 = covs2;
NumOfChannels = length(covs2);
BarometricP = means2(8);
constH = 1000/461*BarometricP/(means2(4) + 273);
constC = 1000/189*BarometricP/(means2(4) + 273);
means3(6) = means2(6)*constH;
means3(5) = means2(5)*constC;
i=1:4;
covs3(i,6) = covs2(i,6)*constH;
covs3(6,i) = covs3(i,6)';
covs3(i,5) = covs2(i,5)*constC;
covs3(5,i) = covs3(i,5)';
covs3(6,6) = covs2(6,6)*constH^2;
covs3(6,7) = covs2(6,7)*constH;
covs3(7,6) = covs3(6,7)';
covs3(5,5) = covs2(5,5)*constC^2;
covs3(5,6) = covs2(5,6)*constC*constH;
covs3(6,5) = covs3(5,6)';
covs3(5,7) = covs2(5,7)*constC;
covs3(7,5) = covs3(5,7)';
%
mu = 29/18;
Pa = 1e6*BarometricP/287/(means2(4)+273);
sigma = means3(6)/Pa;
covs3(3,7) = (1 + mu*sigma)*(covs3(3,7) + means3(6)/(means2(4) + 273)*covs2(3,4));
covs3(7,3) = covs3(3,7);
covs3(3,5) = covs3(3,5) + mu*means3(5)*covs3(3,6)/Pa;
covs3(5,3) = covs3(3,5);
covs3(3,6) = (1 + mu*sigma)*covs3(3,6);
covs3(6,3) = covs3(3,6);
