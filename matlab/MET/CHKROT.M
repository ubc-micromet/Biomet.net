
%
% chkrot.m
%
%   Checking the influence of the coordinate rotation.
%
% (c) Zoran Nesic & Peter Blanken       File created:       Sep 25, 1996
%                                       Last modification:  Jun 12, 1997
%

% Revisions:
%       Jun 12, 1997
%               Global path variable introduced (DATA_PATH_1994_PA)
%               It is pointing to the data base location (PA1994)
%
global DATA_PATH_1994_PA
FileName = [DATA_PATH_1994_PA '\hfubc\hfubc_' ];
DOY = 216;
DOY_shift = 152.25;
NumOfCovElements = 55;
FileExt  = '.1_2';
means = zeros(48,9);
covs  = zeros(48,53);
t = read_bor([FileName 'dt']) - DOY_shift;

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
plot(t(ind),No_WPL,'-',t(ind),No_rot,'x',t(ind),C_rot,'-',t(ind),N_rot,'--')
grid
title('- No_WPL & No_Rotation, x WPL+Canopy, -- WPL+Natural')
xlabel('DOY')
ylabel('w''h'' (gm-2s-1)')

