function [sonic_flag] = get_sonic_flag(pth,years,indOut,ini);
%[sonic_ind] = get_sonic_flag(pth,years); program to create index of bad licor times (to remove from licor based fluxes)
% sonic_ind = 12 bit unsigned integer
% 
% Any value >= 64 indicates an error code
% Sensor issue ex: bitget(sonic_flag,8) = 1 for outside absolute limits, =0 for ok.

% E.Humphreys
% Nov 25, 2001 - developed from my create_bad_sonic_ind.m
% 


if ~exist('indOut') | isempty(indOut);
    indOut = [];
end

if ~exist('ini') | isempty(ini);
    ini = [];
end

%-----------------------------------------------
%Sonic codes
%
% Warning codes
% 1:   0 = ok
% 2: 
% 3:
% 4:
% 5:
% 6:
% Error codes
% 7:  sigma w > 5 & wT >1
% 8:  absolute limits
% 9:  absolute variance
% 10: # spikes > 5
% 11:
% 12:

if ~isempty(ini)
%-----------------------------------------------
%sonic health

sw    = read_bor(fr_logger_to_db_fileName(ini.avgbr, 'w_STD', pth),[],[],years,indOut);
wT    = read_bor(fr_logger_to_db_fileName(ini.covba, 'wTs', pth),[],[],years,indOut);

%-----------------------------------------------
%Single variables
u_max = read_bor(fr_logger_to_db_fileName(ini.avgar, 'u_MAX', pth),[],[],years,indOut);
u_min = read_bor(fr_logger_to_db_fileName(ini.avgar, 'u_MIN', pth),[],[],years,indOut);
v_max = read_bor(fr_logger_to_db_fileName(ini.avgar, 'v_MAX', pth),[],[],years,indOut);
v_min = read_bor(fr_logger_to_db_fileName(ini.avgar, 'v_MIN', pth),[],[],years,indOut);
w_max = read_bor(fr_logger_to_db_fileName(ini.avgar, 'w_MAX', pth),[],[],years,indOut);
w_min = read_bor(fr_logger_to_db_fileName(ini.avgar, 'w_MIN', pth),[],[],years,indOut);
T_max = read_bor(fr_logger_to_db_fileName(ini.avgar, 'Ts_MAX', pth),[],[],years,indOut);
T_min = read_bor(fr_logger_to_db_fileName(ini.avgar, 'Ts_MIN', pth),[],[],years,indOut);


%----------------------------------------------------------------------------------------
%Variances
u_var = read_bor(fr_logger_to_db_fileName(ini.covaa, 'u_VAR', pth),[],[],years,indOut);
v_var = read_bor(fr_logger_to_db_fileName(ini.covaa, 'v_VAR', pth),[],[],years,indOut);
w_var = read_bor(fr_logger_to_db_fileName(ini.covaa, 'w_VAR', pth),[],[],years,indOut);
T_var = read_bor(fr_logger_to_db_fileName(ini.covaa, 'Ts_VAR', pth),[],[],years,indOut);

%----------------------------------------------------------------------------------------
%#spikes

T_spikes = NaN.*ones(length(sw),1);
u_spikes = NaN.*ones(length(sw),1);
v_spikes = NaN.*ones(length(sw),1);
w_spikes = NaN.*ones(length(sw),1);
    
else
        
%-----------------------------------------------
%sonic health

sw    = read_bor([pth 'covba.6'],[],[],years,indOut);
wT    = read_bor([pth 'covba.9'],[],[],years,indOut);

%-----------------------------------------------
%Single variables
u_max = read_bor([pth 'avgar.3'],[],[],years,indOut);
u_min = read_bor([pth 'avgar.2'],[],[],years,indOut);
v_max = read_bor([pth 'avgar.7'],[],[],years,indOut);
v_min = read_bor([pth 'avgar.6'],[],[],years,indOut);
w_max = read_bor([pth 'avgar.11'],[],[],years,indOut);
w_min = read_bor([pth 'avgar.10'],[],[],years,indOut);
T_max = read_bor([pth 'avgar.15'],[],[],years,indOut);
T_min = read_bor([pth 'avgar.14'],[],[],years,indOut);

%----------------------------------------------------------------------------------------
%Variances
u_var = read_bor([pth 'covaa.1'],[],[],years,indOut);
v_var = read_bor([pth 'covaa.3'],[],[],years,indOut);
w_var = read_bor([pth 'covaa.6'],[],[],years,indOut);
T_var = read_bor([pth 'covaa.10'],[],[],years,indOut);

%----------------------------------------------------------------------------------------
%#spikes
try;
    if exist([pth 'spikes.1']);
        T_spikes = read_bor([pth 'spikes.4'],[],[],years,indOut); %
        u_spikes = read_bor([pth 'spikes.1'],[],[],years,indOut); %
        v_spikes = read_bor([pth 'spikes.2'],[],[],years,indOut); %
        w_spikes = read_bor([pth 'spikes.3'],[],[],years,indOut); %
    else
        s = findstr(lower(pth),'flux\');
        pthc = [pth(1:s-1) 'Flux_errors\'];
        T_spikes = read_bor([pthc 'spikes.4'],[],[],years,indOut); %
        u_spikes = read_bor([pthc 'spikes.1'],[],[],years,indOut); %
        v_spikes = read_bor([pthc 'spikes.2'],[],[],years,indOut); %
        w_spikes = read_bor([pthc 'spikes.3'],[],[],years,indOut); %
    end
end

if ~exist('T_spikes');
   T_spikes = NaN.*ones(length(sw),1);
   u_spikes = NaN.*ones(length(sw),1);
   v_spikes = NaN.*ones(length(sw),1);
   w_spikes = NaN.*ones(length(sw),1);
end
end


%----------------------------------------------- 
%Create index
sonic_flag = zeros(length(sw),1);

%snow/froze/baaad...
ind = find(abs(wT) > 1 | sw  >= 5);
sonic_flag(ind) = bitset(sonic_flag(ind),7);
clear ind;

%absolute limits...
ind = find(u_max > 30 | u_max  < -30 |...
      v_max > 30 | v_max  < -30 |...
      w_max > 30 | w_max  < -30 |...
      T_max > 60 | T_max  < -30);
sonic_flag(ind) = bitset(sonic_flag(ind),8);
clear ind;

%absolute variance...
ind = find(u_var < 1e-10 | v_var  < 1e-10 |...
      w_var < 1e-10 | T_var  < 1e-10);
sonic_flag(ind) = bitset(sonic_flag(ind),9);
clear ind;

%spiking...
ind = find(u_spikes > 5 | v_spikes  > 5 |...
      w_spikes > 5 | T_spikes  > 5);
sonic_flag(ind) = bitset(sonic_flag(ind),10);
clear ind;


