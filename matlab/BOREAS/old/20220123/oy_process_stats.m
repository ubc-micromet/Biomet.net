function [stats, statsRaw] = oy_process_stats(stats)
%************************************************************
%
%
% Processes stats for oy site 
%
%E.Humphreys     Sept 5, 2000
%************************************************************

rawstats = stats;
clear stats;

n  = length(rawstats);
m  = 8;
ms = 5;

%stats.meansall        = zeros(n,m,5);
stats.means           = zeros(n,m);
stats.var             = zeros(n,m);
stats.covs            = zeros(n,6);
%stats.scalcovs       = zeros(n,ms,3);
stats.scalcovsu       = zeros(n,ms);
stats.scalcovsv       = zeros(n,ms);
stats.scalcovsw       = zeros(n,ms);
stats.const           = zeros(n,m);
stats.max             = zeros(n,m);
stats.min             = zeros(n,m);
stats.Pbar            = zeros(n,4);

%stats.meansall(:,:,1)     = rawstats(:,5:12);
%stats.meansall(:,:,2)     = rawstats(:,41:48);
%stats.meansall(:,:,3)     = rawstats(:,49:56);
%stats.meansall(:,:,4)     = rawstats(:,13:20);
%stats.meansall(:,[4:8],5) = rawstats(:,57:61);

stats.means           = rawstats(:,[6 7 5 8:12]);
stats.var             = rawstats(:,13:20);
stats.covs            = rawstats(:,[13 14 15 28 21 22]);
%stats.scalcovs(:,:,1) = rawstats(:,29:33);
%stats.scalcovs(:,:,2) = rawstats(:,34:38);
%stats.scalcovs(:,:,3) = rawstats(:,23:27);

stats.scalcovsu       = rawstats(:,29:33);
stats.scalcovsv       = rawstats(:,34:38);
stats.scalcovsw       = rawstats(:,23:27);
stats.const(:,[4:8])  = rawstats(:,57:61);
stats.max             = rawstats(:,41:48);
stats.min             = rawstats(:,49:56);
stats.Pbar            = rawstats(:,1:4);

%
%apply constant from means, min, max 
%
%stats.meansall(:,:,1:3)  = stats.meansall(:,:,1:3) + stats.meansall(:,:,5);
stats.means     = stats.means + stats.const;
stats.max       = stats.max + stats.const;
stats.min       = stats.min + stats.const;

statsRaw        = stats;

%
%convert to engineering units used in rest of calculations;
%
%CSAT3 T from virtual temp to actual temp
e   = (8.314./(18.02/1000)).*...
   (stats.means(:,5)+273.15).*stats.means(:,8)./(1000.*1000); %kPa
chi = 0.622.*e./(stats.Pbar(:,1)-e); %temporarily calc h2o mixing ratio (g h2o/g dry air)

stats.means(:,5)= stats.means(:,5)./(1+0.61.*chi);
stats.max(:,5)  = stats.max(:,5)./(1+0.61.*chi);
stats.min(:,5)  = stats.min(:,5)./(1+0.61.*chi);

%li7500 h2o from g/m3 to mmol h2o /mol wet air

stats.means(:,8)= stats.means(:,8).*...
   (8.314./(18.02/1000))./1000.*(stats.means(:,5)+273.15)./stats.Pbar(:,1);
stats.max(:,8)  = stats.max(:,8).*...
   (8.314./(18.02/1000))./1000.*(stats.means(:,5)+273.15)./stats.Pbar(:,1);
stats.min(:,8)  = stats.min(:,8).*...
   (8.314./(18.02/1000))./1000.*(stats.means(:,5)+273.15)./stats.Pbar(:,1);

%krypton kh20 h2o from g/m3 to mmol h2o/mol wet air
stats.means(:,4)= stats.means(:,4).*...
   (8.314./(18.02/1000))./1000.*(stats.means(:,5)+273.15)./stats.Pbar(:,1);
stats.max(:,4)  = stats.max(:,4).*...
   (8.314./(18.02/1000))./1000.*(stats.means(:,5)+273.15)./stats.Pbar(:,1);
stats.min(:,4)  = stats.min(:,4).*...
   (8.314./(18.02/1000))./1000.*(stats.means(:,5)+273.15)./stats.Pbar(:,1);

%li7500 co2 from mg/m3 to umol co2 /mol wet air
stats.means(:,7)= stats.means(:,7).*...
   (8.314./44).*(stats.means(:,5)+273.15)./stats.Pbar(:,1);
stats.max(:,7)  = stats.max(:,7).*...
   (8.314./44).*(stats.means(:,5)+273.15)./stats.Pbar(:,1);
stats.min(:,7)  = stats.min(:,7).*...
   (8.314./44).*(stats.means(:,5)+273.15)./stats.Pbar(:,1);
