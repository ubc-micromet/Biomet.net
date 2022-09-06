function [stationarity_flag] = get_stationarity_flag(pth,years,indOut,ini);
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
% 2:   wu
% 3:   wv
% 4:   ww
% 5:   wT
% 6:   wCO2
% 7:   wH2O

smpl  = read_bor([pth 'misc.1'],[],[],years,indOut);

%----------------------------------------------------------------------------------------
%stationarity
try;           
    if exist([pth 'stationarnr.1']);       
        stationarnr(:,1)  = read_bor([pth 'stationarnr.1'],[],[],years,indOut); %on wu 
        stationarnr(:,2)  = read_bor([pth 'stationarnr.2'],[],[],years,indOut); %on wv 
        stationarnr(:,3)  = read_bor([pth 'stationarnr.3'],[],[],years,indOut); %on ww 
        stationarnr(:,4)  = read_bor([pth 'stationarnr.4'],[],[],years,indOut); %on wT 
        stationarnr(:,5)  = read_bor([pth 'stationarnr.5'],[],[],years,indOut); %on wco2 
        stationarnr(:,6)  = read_bor([pth 'stationarnr.6'],[],[],years,indOut); %on wh2o 
    else
        s = findstr(lower(pth),'flux\');
        pthc = [pth(1:s-1) 'Flux_errors\'];
        stationarnr(:,1)  = read_bor([pthc 'stationarnr.1'],[],[],years,indOut); %on wu 
        stationarnr(:,2)  = read_bor([pthc 'stationarnr.2'],[],[],years,indOut); %on wv 
        stationarnr(:,3)  = read_bor([pthc 'stationarnr.3'],[],[],years,indOut); %on ww 
        stationarnr(:,4)  = read_bor([pthc 'stationarnr.4'],[],[],years,indOut); %on wT 
        stationarnr(:,5)  = read_bor([pthc 'stationarnr.5'],[],[],years,indOut); %on wco2 
        stationarnr(:,6)  = read_bor([pthc 'stationarnr.6'],[],[],years,indOut); %on wh2o 
    end
end

if ~exist('stationarnr(:,1)');
    stationarnr(:,1)  = NaN.*ones(length(smpl),1); %on wu 
    stationarnr(:,2)  = NaN.*ones(length(smpl),1); %on wv 
    stationarnr(:,3)  = NaN.*ones(length(smpl),1); %on ww 
    stationarnr(:,4)  = NaN.*ones(length(smpl),1); %on wT 
    stationarnr(:,5)  = NaN.*ones(length(smpl),1); %on wco2 
    stationarnr(:,6)  = NaN.*ones(length(smpl),1); %on wh2o 
end

%----------------------------------------------- 
%Create index
stationarity_flag = zeros(length(smpl),1);


ind = find(stationarnr(:,1)  > 3.5);
stationarity_flag(ind) = bitset(stationarity_flag(ind),2);
clear ind;    

ind = find(stationarnr(:,2)  > 3.5);
stationarity_flag(ind) = bitset(stationarity_flag(ind),3);
clear ind;    

ind = find(stationarnr(:,3)  > 3.5);
stationarity_flag(ind) = bitset(stationarity_flag(ind),4);
clear ind;    

ind = find(stationarnr(:,4)  > 3.5);
stationarity_flag(ind) = bitset(stationarity_flag(ind),5);
clear ind;    

ind = find(stationarnr(:,5)  > 3.5);
stationarity_flag(ind) = bitset(stationarity_flag(ind),6);
clear ind;    

ind = find(stationarnr(:,6)  > 3.5);
stationarity_flag(ind) = bitset(stationarity_flag(ind),7);
clear ind;    