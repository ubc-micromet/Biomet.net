function [irga_flag] = get_irga_flag(pth,years,indOut,ini);
%[irga_ind] = get_irga_flag(pth,years); program to create index of bad licor times (to remove from licor based fluxes)
% irga_ind = 12 bit unsigned integer
% 
% Any value >= 64 indicates an error code
% Sensor issue ex: bitget(irga_flag,8) = 1 for pump off, 0 for pump ok.

% E.Humphreys
% Nov 25, 2001 - developed from my create_bad_licor_ind.m
% 

if ~exist('indOut') | isempty(indOut);
    indOut = [];
end

if ~exist('ini') | isempty(ini);
    ini = [];
end
%-----------------------------------------------
% Codes:
%
% Warning codes
% 1: = low flow
% 2: = microcontroller off
% 3: 
% 4:
% 5:
% 6:
% Error codes
% 7:  = calibration
% 8:  = pump off
% 9:  = licor off/no data point
% 10: = absolute variance
% 11: = absolute limits
% 12: =


%-----------------------------------------------
%Single Variables

if ~isempty(ini)  
Cmin = read_bor(fr_logger_to_db_fileName(ini.avgar, 'co2_MIN', pth),[],[],years,indOut);
Cmax = read_bor(fr_logger_to_db_fileName(ini.avgar, 'co2_MAX', pth),[],[],years,indOut);
Cavg = read_bor(fr_logger_to_db_fileName(ini.avgar, 'co2_AVG', pth),[],[],years,indOut);
Havg = read_bor(fr_logger_to_db_fileName(ini.avgar, 'h2o_AVG', pth),[],[],years,indOut);
Hmin = read_bor(fr_logger_to_db_fileName(ini.avgar, 'h2o_MIN', pth),[],[],years,indOut);
Hmax = read_bor(fr_logger_to_db_fileName(ini.avgar, 'h2o_MAX', pth),[],[],years,indOut);
else
    
Cmin = read_bor([pth 'avgar.42'],[],[],years,indOut);
Cmax = read_bor([pth 'avgar.43'],[],[],years,indOut); 
Cavg = read_bor([pth 'avgar.41'],[],[],years,indOut);
Havg = read_bor([pth 'avgar.45'],[],[],years,indOut);
Hmin = read_bor([pth 'avgar.46'],[],[],years,indOut);
Hmax = read_bor([pth 'avgar.47'],[],[],years,indOut);
end

%-----------------------------------------------
%Variances
if ~isempty(ini)  
Cvar = read_bor(fr_logger_to_db_fileName(ini.covaa, 'co2_VAR', pth),[],[],years,indOut);
Hvar = read_bor(fr_logger_to_db_fileName(ini.covaa, 'h2o_VAR', pth),[],[],years,indOut);    
else
Cvar = read_bor([pth 'covaa.28'],[],[],years,indOut);
Hvar = read_bor([pth 'covaa.36'],[],[],years,indOut); 
end
%-----------------------------------------------
%licor1 health
if ~isempty(ini)  
Plicor = read_bor(fr_logger_to_db_fileName(ini.avgar, 'Pbar_AVG', pth),[],[],years,indOut);
Pgauge = NaN.*ones(length(Plicor),1);    
Tbench = NaN.*ones(length(Plicor),1);
Pbar   = read_bor(fr_logger_to_db_fileName(ini.avgar, 'Pbar_AVG', pth),[],[],years,indOut);    
else
Plicor = read_bor([pth 'avgar.53'],[],[],years,indOut);
Pgauge = read_bor([pth 'avgar.57'],[],[],years,indOut); 
Tbench = read_bor([pth 'avgar.49'],[],[],years,indOut);
Pbar   = read_bor([pth 'avgar.97'],[],[],years,indOut);
end
%----------------------------------------------- 
%Create index
irga_flag = zeros(length(Cmin),1);

%flow low
ind = find(Pgauge < 5 & Pgauge > 0.1);
irga_flag(ind) = bitset(irga_flag(ind),1);
clear ind;
%microcontroller down
ind = find(Pgauge < 0.1 & Tbench < 13 & Tbench ~= 0);
irga_flag(ind) = bitset(irga_flag(ind),2);
clear ind;

%calibration
ind = find(Cmin < 100 & Cavg ~= 0 & Plicor >70); %ensures that spiking isn't mistaken for a cal
irga_flag(ind) = bitset(irga_flag(ind),7);
clear ind;

%pump off
ind = find(Pgauge < 0.1 & abs(Plicor-Pbar) < 3);
irga_flag(ind) = bitset(irga_flag(ind),8);
clear ind;

%licor off/no data
ind = find((Pgauge == 0 & Tbench == 0 & Plicor == 0) | (Plicor > 150 | Plicor < 70));
irga_flag(ind) = bitset(irga_flag(ind),9);
clear ind;

%absolute variance
ind = find(Hvar < 1e-10 | Cvar < 1e-10);
irga_flag(ind) = bitset(irga_flag(ind),10);
clear ind;

%absolute limits
if ~isempty(ini);
    Cmax_lim = 550;
    ind = find(Havg < 0 | Havg > 30 | Cavg < 320 | Cavg > Cmax_lim);
    irga_flag(ind) = bitset(irga_flag(ind),11);
    clear ind;
else
    Cmax_lim = 550;
    ind = find(Hmin < 0 | Hmax > 30 | Cmin < 320 | Cmax > Cmax_lim);
    irga_flag(ind) = bitset(irga_flag(ind),11);
    clear ind;
end




