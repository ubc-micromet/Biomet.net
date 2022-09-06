function OutData = met_out(meansS, covsS,meansS1, covsS1,meansS2, covsS2, header, NumOfLines);
%
%
%
%
%   Calculates fluxes for the UBC eddy corr. system using the means
%   and the covariances calculated by met_calc.m
%
%   OutData (PageNum, channelNum)
%
% (c) Zoran Nesic               File created:       Jan 28, 1997
%                               Last modification:  Jan 28, 1997
OutData = zeros(2,100);
NumOfChannels = header(1);
Tair = meansS(4)+273.16;        % absolute air temp. (degK)
WaterMoleFraction = meansS(6);  %
BarometricP = meansS(8);        %
uw = covsS2(1,3);               % covariance u^w
wT = covsS2(3,4);               % covariance w^T
wc = covsS2(3,5);               % covariance w^C
wh = covsS2(3,6);               % covariance w^h
wr = covsS2(3,7);               % covariance w^Rho
hr = covsS2(6,7);               % covariance h^Rho
hh = covsS2(6,6);               % variance h^h
rr = covsS2(7,7);               % variance Rho^Rho

% LE LICOR
LELicor   = wh * 1918.06 * ( Tair / (Tair - 33.91) ) ^ 2;

% LE Krypton
LEKrypton = wr * 1918.06 * ( Tair / (Tair - 33.91) ) ^ 2;

% H
Sensible  = wT * BarometricP * ( 29*(1-WaterMoleFraction/1000) + 18*WaterMoleFraction/1000 )... 
                * 1000 / Tair / 8.314 * 1.004;

% BowenRation LICOR
if LELicor == 0
    BowenRatioLICOR = 1e38;
else
    BowenRatioLICOR = Sensible / LELicor;
end

% BowenRation Krypton
if LEKrypton == 0
    BowenRatioKrypton = 1e38;
else
    BowenRatioKrypton = Sensible / LEKrypton;
end

% WaterUseEfficiency
if wh == 0
    WaterUseEfficiency = 1e38;
else
    WaterUseEfficiency = - wc / wh;
end

% Ustar
Ustar = abs( uw ) ^ 0.5;

% Penergy
Penergy = -10.47 * wc;

% h-r correlation coeff
if hh == 0 | rr == 0
    HRcoeff = 1e38;
else
    HRcoeff = hr / abs( hh * rr ) ^ 0.5;
end

%
% Page one
%
OutData(1,1) = NumOfChannels;               % NumOfChannels
OutData(1,2) = NumOfLines;
OutData(1,3) = header(8);                   % Rotation
OutData(1,4) = header(5);                   % Delay time

OutData(1,4+[1:NumOfChannels]) = meansS;
k = 24;
p = 10;
for i=1:NumOfChannels
    n = 1:NumOfChannels-i+1;
    %    n+i-1
    %    k+n
    OutData(1,k+n) = covsS(i,n+i-1);
    k = k + p - i + 1;
end    
%
% Page two
%
OutData(2,1) = NumOfChannels;               % NumOfChannels
OutData(2,2) = NumOfLines;
OutData(2,3) = header(8);                   % Rotation
OutData(2,4) = header(5);                   % Delay time
OutData(2,4+[1:NumOfChannels]) = meansS2;
k = 24;
p = 10;
for i=1:NumOfChannels
    n = 1:NumOfChannels-i+1;
    %    n+i-1
    %    k+n
    OutData(2,k+n) = covsS2(i,n+i-1);
    k = k + p - i + 1;
end    

OutData(2,80:88) = [ HRcoeff Sensible LELicor LEKrypton BowenRatioLICOR BowenRatioKrypton ...
                     WaterUseEfficiency Ustar Penergy ];


