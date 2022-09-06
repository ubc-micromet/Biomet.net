function new_le = corrle(time,le_39);
%*****************************************************************%
% THIS MATLAB FUNCTION RECALCULATES THE AES LATENT HEAT FLUX      %
% TO PROVIDE THE MOST ACCURATE LE(39) AS OF JUNE 20/96            %
%                                                                 %
%        new_le = corrle(time,le_39)                              %
%                                                                 %
%        time = column containing decimal time                    %
%        le = aes latent heat flux prior to recalculation (W m-2) %
%                                                                 %
%*****************************************************************%     

%   Revisions:
%       Jun 12, 1997 (Zoran Nesic)
%               Introduced global variables for the data paths
%

% Set the global path for the data base
global DATA_PATH_1994_PA
global DATA_PATH_PETER_1

% load and calculate vapour pressure from dewpoint hygrometer
dp = dbload(DATA_PATH_PETER_1,'dewpt',3,3);
dp = cle_data(dp,3,-39);
e = sat_vp(dp);

% load and calculate vapour pressure from AES HMP
SRC_T_39 = dbload(DATA_PATH_1994_PA,'src  ',13,52);
SRC_T_39 = cle_data(SRC_T_39,3,-60);

SRC_RH_39 = dbload(DATA_PATH_1994_PA,'src  ',23,52);
SRC_RH_39 = cle_data(SRC_RH_39,3,10);

SRC_e = sat_vp(SRC_T_39).*(SRC_RH_39./100);

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
ind = find(isnan(e)&~isnan(SRC_e));
e(ind) = SRC_e(ind);

% calculate forest LE with Harold's correction
ind = find(time < 153);
new_le(ind) = le_39(ind).*0.843;

ind = find(time >= 153);
new_le(ind) = le_39(ind).*(0.9527 + 0.2888.*e(ind));

% apply 13% increase from 5-day 1:1 comparison
new_le = new_le*1.13;
new_le = new_le';

% remove bad data
new_le = cle_data(new_le,2,600);
new_le = cle_data(new_le,3,-100);