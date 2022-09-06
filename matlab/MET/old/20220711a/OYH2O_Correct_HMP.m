function [OY_pt100, OY_IRGA_RH] = OYH2O_Correct_HMP(DateIn);

YearX = datevec(DateIn(end));
YearX = YearX(1);
pth_clim = biomet_path(YearX,'oy','cl');
pth_flux = biomet_path(YearX,'oy','fl');

% Load variables

% GMT_shift = 8/24;       %shift grenich mean time to 24hr day
% tv        = read_bor([ptha 'oy_clim1_tv'],8,[],years);tv = tv-GMT_shift;
% hrmin     = read_bor([ptha 'oy_clim1.4'],[],[],years);
% start     = datenum(years,1,1,13,0,0); %start it at 1 pm PST
% 
% indOut1    = find(tv >= start);
% 
% OY_H2O = read_bor(fullfile(ptha,'\Flux\MainEddy.Three_Rotations.Avg_6'),[],[],years,indOut1);
% OY_HMP_RH = read_bor(fullfile(ptha,'OY_Clim1.49'),[],[],years,indOut1);
% OY_Press = read_bor(fullfile(ptha,'OY_Clim1.25'),[],[],years,indOut1);
% OY_pt100 = read_bor(fullfile(ptha,'OY_Clim1.139'),[],[],years,indOut1);

tv_oy = read_bor(fullfile(pth_clim,'OY_Clim1_tv'),8);
OY_H2O = read_bor(fullfile(pth_flux,'MainEddy.Three_Rotations.Avg_6'));
OY_HMP_RH = read_bor(fullfile(pth_clim,'OY_Clim1.49'));
OY_Press = read_bor(fullfile(pth_clim,'OY_Clim1.25'));
OY_pt100 = read_bor(fullfile(pth_clim,'OY_Clim1.139'));

OY_tmp = (0.61365*exp((17.502*OY_pt100)./(240.97+OY_pt100))); % saturation vapor pressure at T 
OY_IRGA_RH = (OY_H2O.*OY_Press)./(10.*OY_tmp.*(1+(OY_H2O./1000)));
OY_IRGA_RH = 1.08.*OY_IRGA_RH +2;

[junk,junk,ind] = intersect(fr_round_hhour(DateIn,1),fr_round_hhour(tv_oy,1));
OY_IRGA_RH = OY_IRGA_RH(ind)/100;
OY_pt100 = OY_pt100(ind);

