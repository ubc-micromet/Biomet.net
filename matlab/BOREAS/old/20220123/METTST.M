%==============================================================================
%
%   MET_tst.m
%
%   This file is used on met_tst.dat to compare (check) the calculations
%   done by met-calc.bas
%
%
%
% (c) Zoran Nesic                           File created:       Feb 14, 1996
%                                           Last modification:  Feb 15, 1996
%==============================================================================
%
%
%   Start of the calculation
%
%

%
% Initialization of constants
%
Tinternal = 41.7;
Tco =  36.4;
Tho = 41.7;
Po = 101.3;
DelayTime = 19;
rotation = 'C';
RunMeanBarometricP = 0.99;
RunMeanPgauge = 0.99;
% load data

format short e
load met_tst.dat;
NumOfLines = length(met_tst);
u = met_tst(1 : NumOfLines - DelayTime,1);
v = met_tst(1 : NumOfLines - DelayTime,2);
w = met_tst(1 : NumOfLines - DelayTime,3);
t = met_tst(1 : NumOfLines - DelayTime,4);
c = met_tst(DelayTime + 1 : NumOfLines,5) ;
h = met_tst(DelayTime + 1 : NumOfLines,6) ;
r = met_tst(1 : NumOfLines - DelayTime,7);
p = met_tst(1 : NumOfLines - DelayTime,8);
g = met_tst(1 : NumOfLines - DelayTime,9);
clear met_tst;

%p_filt = filter([0 1-RunMeanBarometricP], [1  -RunMeanBarometricP],p,p(1));
%g_filt = filter([0 1-RunMeanPgauge], [1  -RunMeanPgauge],g,g(1));
 

%
% Pressure and temperature corrections
%
%
%TCcoeff = (Tinternal + 273)/(Tco + 273);
%THcoeff = (Tinternal + 273)/(Tho + 273);
%Pc = Po ./( p_filt - g_filt ); 

%
% Make the covariance matrix
%
NumReal = [ u v w t c h r p g];
%
% clear the memory
%
clear u
clear v
clear w
clear t
clear c
clear h
clear r
clear p
%
%  Calculate the covariances
%
means = mean(NumReal)'
covs = cov(NumReal);
triu(covs)
%
%  Rotation
%
if rotation == 'C'
    [means1,covs1] = rotatC (means,covs);
else
    [means1,covs1] = rotatN (means,covs);
end
[means2,covs2] = WPLcorr (means1,covs1);
means2
triu(covs2)
%
% Output the results
%
junk = [triu(covs) ; triu(covs1) ; triu(covs2)];
save met_cov.txt junk -ascii
save met_avg.txt means -ascii
save met_avg1.txt means1 -ascii
save met_avg2.txt means2 -ascii

