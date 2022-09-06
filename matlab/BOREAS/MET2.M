%==================================================================
%
%   MET2.m
%
%
%	This meta file does statistics on METxxx.BAS files.
%	- to load the data file use MET1.met
%	(it is suppose to give the same results as on line 
%	 calculation)
%
%==================================================================
%
%
%	Start of the calculation
%
%
% initialization of the vectors
format short e
u = zeros(NumOfLines,1);
v = u;
w = u;
t = u;
c = u;
h = u;
r = u;
p = u;
tmp = u;
u(:) = NumInt(:,1).*Ugain;
v(:) = NumInt(:,2).*Vgain;
w(:) = NumInt(:,3).*Wgain;
if AnemometerType == 'S'
	t(:) = (NumInt(:,4)*0.02).^2 /403 * Tgain - 273;
elseif AnemometerType == 'A'
	t(:) = NumInt(:,4) * Tgain;
end
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
%
% delay the arrays
%
c(1:NumOfLines -delay) = c(delay+1:NumOfLines) ;
h(1:NumOfLines -delay) = h(delay+1:NumOfLines) ;
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
