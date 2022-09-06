%==================================================================
%
%   MET.m
%
%
%	This meta file does statistics on METxxx.BAS files.
%	(it is suppose to give the same results as on line 
%	 calculation)
%
%==================================================================
format short e
t0 = clock;
x='Loading data'
if (exist('NumInt') ~= 1),
	loadNum
end
%
% First set the constants (in the next version make this automatic)
%
delay = 17;
rotation = 'C'
Ugain = 0.01;
Vgain = 0.01;
Wgain = 0.01;
Tgain = 1;
ADconv = 1;
ADoffset = 5.3;
%
Tinternal = 39.15;
Pgauge = 22.58;
Po = 101.5;
Pconst1 = 92;
Pconst2 = 600;
%
Tco = 35.8;
Cgain = 10;
OffsetC = 1133;
ac = .1408;
bc = 2.107e-5;
cc = 1.74e-9;
%
Tho = 40.8;
OffsetH = 221;
Hgain = 10;
ah = 5.898e-3;
bh = 3.318e-6;
ch = -5.016e-11;
%
OffsetRHOV = 0;
Vox = 1733.67;
XKw = -.13381;
%
x='Loading finshed'
etime(clock,t0)
%
%
%	Start of the calculation
%
%
[NumOfLines, NumOfChannels] = size(NumInt);
% initialization of the vectors
u = zeros(NumOfLines,1);
v = u;
w = u;
t = u;
c = u;
h = u;
r = u;
p = u;
tmp = u;
x = 'start of calculation'
u(:) = NumInt(:,1).*Ugain;
v(:) = NumInt(:,2).*Vgain;
w(:) = NumInt(:,3).*Wgain;
t(:) = (NumInt(:,4)*0.02).^2 /403 * Tgain - 273;
%
TCcoeff = (Tinternal + 273)/(Tco + 273);
THcoeff = (Tinternal + 273)/(Tho + 273);
%
% Pressure correction
%
%
p(:) = ((NumInt(:,8) + ADoffset) * ADconv/1000 * Pconst1 + Pconst2)/10;
BarometricP = mean(p);
Pc = Po /( BarometricP - Pgauge) 
%
tmp(:) = ((NumInt(:,5)+ ADoffset) * ADconv / Cgain + OffsetC) * Pc;
c(:) = (tmp(:) .* ( ac + tmp(:) .* (bc + tmp(:) * cc))) * TCcoeff;
%
tmp(:) = ((NumInt(:,6)+ ADoffset) * ADconv / Hgain + OffsetH) * Pc;
h(:) = (tmp(:) .* ( ah + tmp(:) .* (bh + tmp(:) * ch))) * THcoeff;
%
r(:) = log((NumInt(:,7)+ADoffset) * ADconv / Vox) / XKw;
%
means = [	mean(u)
		mean(v)
		mean(w)
		mean(t)
		mean(c)
		mean(h)
		mean(r)
		BarometricP	]
etime(clock,t0)
%
% delay the arrays
%
c(1:NumOfLines -delay) = c(delay+1:NumOfLines) ;
h(1:NumOfLines -delay) = h(delay+1:NumOfLines) ;
% w(1:NumOfLines -delay) = w(delay+1:NumOfLines) ;
% t(1:NumOfLines -delay) = t(delay+1:NumOfLines) ;
% r(1:NumOfLines -delay) = r(delay+1:NumOfLines) ;
%
% Make the covariance matrix
%
NumReal = [ u v w t c h r ];
NumReal = NumReal (1 : NumOfLines - delay,:);
%
% clear the memory
%
%clear NumInt
clear u
clear v
clear w
clear t
clear c
clear h
clear r
clear p
pack
%
%  Calculate the covariances
%
covs = cov(NumReal)
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
x = 'end of calculation'
etime(clock,t0)