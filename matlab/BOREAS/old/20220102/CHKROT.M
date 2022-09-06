
%
% chkrot.m
%
%   Checking the influence of the coordinate rotation.
%
% (c) Zoran Nesic & Peter Blanken       File created:       Sep 25, 1996
%                                       Last modification:  Oct 23, 1996
%

FileName = 'v:\data\hfubc\hfubc_' ;
DOY = 216;
DOY_shift = 152.25;
NumOfCovElements = 55;
FileExt  = '.1_2';
means = zeros(48,9);
covs  = zeros(48,53);
t = read_bor([ FileName 'dt']) - DOY_shift;

ind = find(floor(t) == DOY);
for i = 1:9
    s = sprintf('tmp = read_bor(%s%s%s%s%s);',39,FileName,deblank(num2str(i+4)),FileExt,39);
    eval(s);
    means(:,i) = tmp(ind);    
end    
for i = 1:NumOfCovElements
    s = sprintf('tmp = read_bor(%s%s%s%s%s);',39,FileName,deblank(num2str(i+24)),FileExt,39);
    eval(s);
    covs(:,i) = tmp(ind);    
end    

[No_WPL,No_rot,C_rot, N_rot] = reclccov(means,covs,1:48,[3 6]);

% l = 2442; %latent heat of vaporization (Jg)
temp = read_bor([ FileName '8.1_2']);
Ta = (temp(ind));
BarometricP = read_bor([FileName '12.1_2']);
Pa = (BarometricP(ind));
constH = 1000/461*Pa./(Ta+273);                     % mmol/mol -> g / m^3
l = 1918.06*( (Ta +273)./(Ta +273 -33.9) ).^2;      % (J/g) conversion
l1 = l .* constH;
plot(t(ind),No_WPL.*l1,'-',t(ind),No_rot.*l,'x',t(ind),C_rot.*l,'-',t(ind),N_rot.*l,'--')
grid
title('- No_WPL & No_Rotation, x WPL+Canopy, -- WPL+Natural')
xlabel('DOY')
ylabel('w''h'' (W m-2)')

LE = [ mean(No_WPL.*l1) mean(No_rot.*l) mean(C_rot.*l) mean(N_rot.*l)]
LE ./mean(No_rot.*l)

