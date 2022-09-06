function [e_39,T_39] = temp_39(time);

% function grives long-term best-estimate of air temp
% and vapour pressure (kPa) at 39 m from AES & SRC data


%   Revisions:
%       Jun 12, 1997 (Zoran Nesic)
%               Introduced global variables for the data paths
%

% Set the global path for the data base
global DATA_PATH_1994_PA DATA_PATH_PETER_1


dp = dbload( DATA_PATH_PETER_1 ,'dewpt',3,3);
dp = cle_data(dp,3,-39);
e_39 = sat_vp(dp);

% load and calculate vapour pressure from AES HMP
T_39 = dbload(DATA_PATH_1994_PA,'src  ',13,52);
T_39 = cle_data(T_39,3,-60);

SRC_RH_39 = dbload(DATA_PATH_1994_PA,'src  ',23,52);
SRC_RH_39 = cle_data(SRC_RH_39,3,10);

SRC_e = sat_vp(T_39).*(SRC_RH_39./100);

% load and calculate vapour pressure from AES HMP
AES_T_39 = dbload(DATA_PATH_1994_PA,'meaes',10,53);
AES_T_39 = cle_data(AES_T_39,3,-100);
AES_T_39 = cle_data(AES_T_39,2,40);

AES_RH_39 = dbload(DATA_PATH_1994_PA,'src  ',23,52);
AES_RH_39 = cle_data(AES_RH_39,3,10);
AES_RH_39 = AES_RH_39 - 0.18;

AES_e = sat_vp(AES_T_39).*(AES_RH_39./100);

% replace SRC e with AES e when former not available
ind = find(isnan(SRC_e) & ~isnan(AES_e));
SRC_e(ind) = AES_e(ind);

% replace dewpoint e with SRC e when former not available
ind = find(isnan(e_39)&~isnan(SRC_e));
e_39(ind) = SRC_e(ind);

% replace SRC T with AES T  when former not available
ind = find(isnan(T_39)&~isnan(AES_T_39));
T_39(ind) = AES_T_39(ind);