function [stats, statsRaw] = oy_process_stats_cp(pth,years,indOut)
%************************************************************
%
%
% Processes stats for oy site 
%
%E.Humphreys     Sept 5, 2000
%************************************************************

% Find logger ini files
ini_flxMain = fr_get_logger_ini('oy',years,[],'oy_flux_53','fl');   % main climate-logger array
ini_flx2    = fr_get_logger_ini('oy',years,[],'oy_flux_56','fl');   % secondary climate-logger array
ini_clim1   = fr_get_logger_ini('oy',years,[],'oy_clim1','cl');   % secondary climate-logger array

ini_flxMain = rmfield(ini_flxMain,'LoggerName');
ini_flx2    = rmfield(ini_flx2,'LoggerName');
ini_clim1   = rmfield(ini_clim1,'LoggerName');

ind = findstr(pth,'Flux' );
pth_clim  = [pth(1:ind-1) 'Climate\'];

n  = length(indOut);
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

stats.means(:,[1]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ux_a', pth),[],[],years,indOut);
stats.means(:,[2]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uy_a', pth),[],[],years,indOut);
stats.means(:,[3]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uz_a', pth),[],[],years,indOut);
stats.means(:,[5]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ts_a', pth),[],[],years,indOut);
try,
stats.means(:,[6]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'FW_a', pth),[],[],years,indOut);
end
stats.means(:,[7]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'co2_a', pth),[],[],years,indOut);
stats.means(:,[8]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'h2o_a', pth),[],[],years,indOut);

stats.var(:,[1])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ux_v', pth),[],[],years,indOut);
stats.var(:,[2])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uy_v', pth),[],[],years,indOut);
stats.var(:,[3])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uz_v', pth),[],[],years,indOut);
stats.var(:,[5])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ts_v', pth),[],[],years,indOut);
try,
stats.var(:,[6])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'FW_v', pth),[],[],years,indOut);
end
stats.var(:,[7])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'co2_v', pth),[],[],years,indOut);
stats.var(:,[8])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'h2o_v', pth),[],[],years,indOut);

stats.covs(:,[1])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ux_v', pth),[],[],years,indOut);
stats.covs(:,[2])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uy_v', pth),[],[],years,indOut);
stats.covs(:,[3])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uz_v', pth),[],[],years,indOut);
stats.covs(:,[4])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ux_Uy', pth),[],[],years,indOut);
stats.covs(:,[5])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uz_Ux', pth),[],[],years,indOut);
stats.covs(:,[6])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uz_Uy', pth),[],[],years,indOut);

stats.scalcovsu(:,[2])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ux_Ts', pth),[],[],years,indOut);
try,
stats.scalcovsu(:,[3])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ux_FW', pth),[],[],years,indOut);
end
stats.scalcovsu(:,[4])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ux_co2', pth),[],[],years,indOut);
stats.scalcovsu(:,[5])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ux_h2o', pth),[],[],years,indOut);

stats.scalcovsv(:,[2])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uy_Ts', pth),[],[],years,indOut);
try,
    stats.scalcovsv(:,[3])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uy_FW', pth),[],[],years,indOut);
end
stats.scalcovsv(:,[4])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uy_co2', pth),[],[],years,indOut);
stats.scalcovsv(:,[5])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uy_h2o', pth),[],[],years,indOut);

stats.scalcovsw(:,[2])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uz_Ts', pth),[],[],years,indOut);
try,
    stats.scalcovsw(:,[3])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uz_FW', pth),[],[],years,indOut);
end
stats.scalcovsw(:,[4])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uz_co2', pth),[],[],years,indOut);
stats.scalcovsw(:,[5])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uz_h2o', pth),[],[],years,indOut);

stats.const(:,[5])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ts_c_o', pth),[],[],years,indOut);
try,
    stats.const(:,[6])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'FW_c_o', pth),[],[],years,indOut);
end
stats.const(:,[7])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'co2_c_o', pth),[],[],years,indOut);
stats.const(:,[8])   = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'h2o_c_o', pth),[],[],years,indOut);

stats.max(:,[1]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ux_MAX', pth),[],[],years,indOut);
stats.max(:,[2]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uy_MAX', pth),[],[],years,indOut);
stats.max(:,[3]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uz_MAX', pth),[],[],years,indOut);
stats.max(:,[5]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ts_MAX', pth),[],[],years,indOut);
try,
    stats.max(:,[6]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'FW_MAX', pth),[],[],years,indOut);
end
stats.max(:,[7]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'co2_MAX', pth),[],[],years,indOut);
stats.max(:,[8]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'h2o_MAX', pth),[],[],years,indOut);

stats.min(:,[1]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ux_MIN', pth),[],[],years,indOut);
stats.min(:,[2]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uy_MIN', pth),[],[],years,indOut);
stats.min(:,[3]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Uz_MIN', pth),[],[],years,indOut);
stats.min(:,[5]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ts_MIN', pth),[],[],years,indOut);
try,
    stats.min(:,[6]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'FW_MIN', pth),[],[],years,indOut);
end
stats.min(:,[7]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'co2_MIN', pth),[],[],years,indOut);
stats.min(:,[8]) = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'h2o_MIN', pth),[],[],years,indOut);

stats.Pbar(:,[1]) = read_bor(fr_logger_to_db_fileName(ini_clim1, 'Pbar_AVG', pth_clim),[],[],years,indOut);
try,
    ind = find(stats.Pbar(:,1)) <= 70;
    stats.Pbar(ind,1) = 101;
end

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
%e   = (8.314./(18.02/1000)).*...
%   (stats.means(:,5)+273.15).*stats.means(:,8)./(1000.*1000); %kPa
%chi = 0.622.*e./(stats.Pbar(:,1)-e); %temporarily calc h2o mixing ratio (g h2o/g dry air)
chi = stats.means(:,8)./1000; %mol/mol dry air

stats.means(:,5)= stats.means(:,5)./(1+0.61.*chi);
stats.max(:,5)  = stats.max(:,5)./(1+0.61.*chi);
stats.min(:,5)  = stats.min(:,5)./(1+0.61.*chi);

