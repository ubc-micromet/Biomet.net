function co2_storage = calc_co2_storage_multi_level(clean_tv,co2_mixratio,h2o_mixratio,air_temp,p_bar,heights,int_time,depth)
%   CALC_CO2_STORAGE_MULTI_LEVEL Calculates the co2 storage flux 
%   from a single level or a multi level profile system.
%
%   CO2_STORAGE = CALC_CO2_STORAGE_MULTI_LEVEL(TV,CO2_MIXRATIO,H2O_MIXRATIO,AIR_TEMP,P_BAR,HEIGHTS) 
%   calculates the storage flux given co2 and water vapour mixing ratios, and temperature profiles or 
%   single values and barometric surface pressure.
 

% Created by David Gaumont-Guay  Dec  5, 2001
% Revised by kai*                Dec 31, 2002
%                                April, 2003 E. Humphreys - allow 1800 s integration time (enter 1800 in int_time),
%                                        and depth rather than height input

%-----------------------------------------------------------------------------------
% delta z
%-----------------------------------------------------------------------------------
nbr_heights = length(heights);

if exist('depth') & ~isempty(depth);
   delta_z = depth;
else
if nbr_heights>1 
   heights_mid    = (heights(1:end-1) + heights(2:end)) ./ 2;
   delta_z        = [NaN diff(heights_mid)];    
   delta_z(1)     = heights_mid(1);
   delta_z(nbr_heights) = heights(end) - heights_mid(end);
else
   delta_z        = heights;
end
end

delta_z_profile = ones(length(co2_mixratio),1) * delta_z;

%-----------------------------------------------------------------------------------
% Gap filling of profiles & creation of pressure profile
%-----------------------------------------------------------------------------------
% This is done here since the demand on these are different than for second stage
[n,m] = size(air_temp);

% Interpolate in time
for i=1:m 
   air_temp(:,i)   = ta_interp_points(air_temp(:,i),4);
end

% --- Create pressure profile ---
P_profile = p_bar*ones(1,m);
P_profile = P_profile-9.81 .* P_profile ./ (287.04*((mean(air_temp,2)*ones(1,m))+273.15)) .* (ones(n,1)*heights);

for i=1:m 
   co2_mixratio(:,i) = ta_interp_points(co2_mixratio(:,i),4);
   P_profile(:,i)    = ta_interp_points(P_profile(:,i),4); 
end

%-----------------------------------------------------------------------------------
% co2 storage - works for single and multi level 
%-----------------------------------------------------------------------------------
% For a derivation of the formula see kai*'s pamphlet on storage
% co2 storage_tmp is integrated over an hour (3600 sec.)
rho =  (1000*P_profile)./(8.3145.*(air_temp+273.15));

int_sec = 3600;
k = 3;

if nargin > 6; 
   %no smoothing - to avoid violating the conservation equation if this smoothing is also not done to the eddy flux
   %Finnigan et al. 2003 BLM
   if int_time == 1800; 
      int_sec = 1800;      
      k = 2;      
   end
end

co2_storage = delta_z_profile(2:end-(k-2),:) .* rho(2:end-(k-2),:)./(1+h2o_mixratio(2:end-(k-2),:)./1000)...
   .* (co2_mixratio(k:end,:) - co2_mixratio(1:end-k+1,:)) ./ int_sec;
%co2_storage = delta_z_profile(2:end-1,:) .* rho(2:end-1,:)./(1+h2o_mixratio(2:end-1,:)./1000)...
%   .* (co2_mixratio(k:end,:) - co2_mixratio(1:end-k+1,:)) ./ int_sec;

fill = NaN.*zeros(1,nbr_heights);   
if length(co2_storage) == length(rho)-2;
   co2_storage  = [fill;co2_storage;fill];    
   co2_storage  = sum(co2_storage,2);     
elseif length(co2_storage) == length(rho)-1;
   co2_storage  = [fill;co2_storage];    
   co2_storage  = sum(co2_storage,2); 
end
