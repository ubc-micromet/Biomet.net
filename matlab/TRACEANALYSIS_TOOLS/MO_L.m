function [L] = MO_L(ustar, T, H2Omix, covwT, covwH2O);
%
%***********************************************************
%Program to calculate Monin Obukhov scaling length, L      *
%                                                          *
%***********************************************************
UBC_biomet_constants;

%load variables
%covwT   = read_bor([pth 'coval.9'],[],[],years,indOut); %w1, sonic T rotated and linear detrended
%covwH2O = read_bor([pth 'coval.31'],[],[],years,indOut); %w1, H2O rotated and linear detrended

%clean variables

%ind = find(covwH2O > 600/2540 | covwH2O < -80/2540);
%covwH2O = clean(covwH2O, 2, ind);
%clear ind;

%ind = find(covwT == 0 | covwT > 600/1200 | covwT <-300/1200);
%covwT = clean(covwT, 2, ind);
%clear ind;

%take 30 min avg of covwGT, mean GT+273.15 and covwr and transform to cov_w_theta_v
%[r] = H2O_conv(H2O, T, P, 9); %mixing ratio (g/g)
T   = ZeroK + T; %temperature in Kelvins
Tv  = T.*(1 + 0.61.*H2Omix./1000);
%virtual temperature assuming that (Po/P)^0.286 = 1 for work in the boundary layer
%where Po is the surface pressure such that Tv = potential Tv (Stull, pg8)

%calculate w'potTv' = covw'T' + 0.61*T*covw'r'
cov_w_potTv = covwT + (0.61.*T.*covwH2O.*Mw/Ma/1000);

%calculate Monin Obukhov scaling length, L

L = (-Tv.*ustar.^3)./(k.*g.*cov_w_potTv);




