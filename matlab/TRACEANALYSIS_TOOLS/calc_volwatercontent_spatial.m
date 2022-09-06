function[theta_int_spatial, theta_int] = calc_volwatercontent_spatial(tv,...
   TDRin,depths,proportions,siteID,selection,old);

%
% Inputs: TDRin - a matrix m rows (time series) x n columns (# of CS615 measurements)
%         depths - a matrix 2 rows (2 depths) x n columns (# of CS615 measurements)
%               indicating the depths covered by each CS615 
%         proportions - a matrix 1 row x n columns (# of CS615 measurements)
%               indicating the proportion of the profile covered by each CS615 
%         selection - 1 = 'top' --> usually refers to top 30 cm of soil profile
%                   - 2 = 'profile' --> usually refers to top 1 m of soil profile
%						  - 3 = '60cm'
%         tv - time vector in datenum format
%         old - use '98,'99 parameters
%
% E. Humphreys  25.03.01
% Revisions Jul 18, 2005 - Changed threshold for profile to 13% to deal with flattening of trace in 1998 (smoothes
%                          the transition between polynomial and straight line)
%           Mar 3, 2002 - upgrade of old CS615_2_tdr
%           Jan 20, 2003 - added new CR calibrations parameters based on 2001 automated UVic measurements
%            so use 10 for old top, 20 for old profile
%                        - added new OY, YF parameters

if ~isstr(selection)
   profile_depth = {'top' 'profile' '60cm'};
   selection = char(profile_depth(selection));
end

if nargin > 6;
   useold = 1;
else
   useold = 0;
end


switch upper(siteID)
case 'CR'
   %coefficients to convert integrated 100 cm and 30 cm theta from one CS615 profile 
   %to spatial integrated theta based on 10 tdr stations (based on 1998 and 1999 
   %manual measurements of Gilbert's UVic system)
   
   if useold == 1;
      coeff_100_2 = [0.2789    5.7876    0.0989]; %dry conditions after 1999
      coeff_100_1 = [0.3017    3.7009    0.0993]; %dry conditions before 1999
      p_100        = [1.3395    0.0491];           %wet conditions
      
      coeff_30_1  = [0.2696    6.3342    0.0834];%[0.2876    6.6722    0.0815];
      coeff_30_2  = [0.2339    8.7584    0.0943];%[0.2633    8.2464    0.0942];
      p_30        = [1.6180   -0.0077];%[1.4928    0.0361];
   else
      coeff_100_1  = [0.1987    16.0211    0.1057]; %dry conditions 2001
      p_100        = [0.5878    0.1177];           %wet conditions
      
      coeff_60_1   = [0.2158    10.6822    0.0915]; %dry conditions 2001
      p_60         = [0.7622    0.1101];           %wet conditions
      
      coeff_30_1   = [0.2424   7.1682    0.0961]; %dry conditions 2001
      p_30         = [0.4490   0.1596];           %wet conditions
   end
case 'OY'
   p_30         = [0.821   -0.0118];           %
   p_60         = [1.143   -0.0069];           %
case 'YF'
   p_30         = [1.3949   -0.1159];           %
   p_60         = [1.0247   -0.0268];           %
   
otherwise
   disp('program not initialized for this site');
   return
end

%calculate new spatially integrated vol water contents:
%CR is a special case, do it alone

if upper(siteID) == 'CR'
   
   switch selection
   case 'top'
      if ~exist('proportions') & isempty(proportions)
         proportions = [0.2 0.8]; %CR defaults
      end
      
      theta_int           = TDRin(:,1).*proportions(1) + TDRin(:,2).*proportions(2);
      
      theta_int_spatial   = NaN.*ones(length(tv),1);
      
      if useold == 1;
         ind                    = find(theta_int <=0.15 & tv < datenum(1999,1,1));
         theta_int_spatial(ind) = coeff_30_1(1).*...
            (theta_int(ind).^coeff_30_1(2)./(coeff_30_1(3).^coeff_30_1(2) +...
            theta_int(ind).^coeff_30_1(2)));
         
         ind                    = find(theta_int <=0.15 & tv >= datenum(1999,1,1));
         theta_int_spatial(ind) = coeff_30_2(1).*...
            (theta_int(ind).^coeff_30_2(2)./(coeff_30_2(3).^coeff_30_2(2) + ...
            theta_int(ind).^coeff_30_2(2)));
      else
         ind                    = find(theta_int <=0.15);
         theta_int_spatial(ind) = coeff_30_1(1).*...
            (theta_int(ind).^coeff_30_1(2)./(coeff_30_1(3).^coeff_30_1(2) +...
            theta_int(ind).^coeff_30_1(2)));
      end
      
      ind                    = find(theta_int >0.15);
      theta_int_spatial(ind) = polyval(p_30,theta_int(ind));
      
   case 'profile'
      if ~exist('proportions') & isempty(proportions)
         proportions = [0.05 0.2 0.35 0.4];  %CR defaults
      end
      
      theta_int           = TDRin(:,1).*proportions(1) + TDRin(:,2).*proportions(2) + ...
         TDRin(:,3).*proportions(3) + TDRin(:,4).*proportions(4);
      
      theta_int_spatial   = NaN.*ones(length(tv),1);
      
      if useold == 1;
         
         ind                 = find(theta_int <=0.15 & tv < datenum(1999,1,1));
         theta_int_spatial(ind)       = coeff_100_1(1).*...
            (theta_int(ind).^coeff_100_1(2)./(coeff_100_1(3).^coeff_100_1(2) + ...
            theta_int(ind).^coeff_100_1(2)));
         
         ind                   = find(theta_int <=0.15 & tv >= datenum(1999,1,1));
         theta_int_spatial(ind)= coeff_100_2(1).*...
            (theta_int(ind).^coeff_100_2(2)./(coeff_100_2(3).^coeff_100_2(2) + ...
            theta_int(ind).^coeff_100_2(2)));
      else
         ind                 = find(theta_int <=0.13 ); % Changed from 15 to 13% to deal with 1998
         theta_int_spatial(ind)       = coeff_100_1(1).*...
            (theta_int(ind).^coeff_100_1(2)./(coeff_100_1(3).^coeff_100_1(2) + ...
            theta_int(ind).^coeff_100_1(2)));
      end
      
      ind                   = find(theta_int >0.13); % Changed from 15 to 13% to deal with 1998
      theta_int_spatial(ind)= polyval(p_100,theta_int(ind));
      
   case '60cm'
      if ~exist('proportions') & isempty(proportions)
         proportions = [0.08 0.25 0.67];  %CR defaults
      end
      
      theta_int           = TDRin(:,1).*proportions(1) + TDRin(:,2).*proportions(2) + ...
         TDRin(:,3).*proportions(3);
      
      theta_int_spatial   = NaN.*ones(length(tv),1);
      
      
      ind                 = find(theta_int <=0.15 );
      theta_int_spatial(ind)       = coeff_60_1(1).*...
         (theta_int(ind).^coeff_60_1(2)./(coeff_60_1(3).^coeff_60_1(2) + ...
         theta_int(ind).^coeff_60_1(2)));
      
      ind                   = find(theta_int >0.15);
      theta_int_spatial(ind)= polyval(p_60,theta_int(ind));
   end
else %if not CR
   switch selection
      
   case 'top'
      if ~exist('proportions') & isempty(proportions)
         proportions = [0.2 0.8]; %CR defaults
      end
      
      theta_int           = TDRin(:,1).*proportions(1) + TDRin(:,2).*proportions(2);
      theta_int_spatial   = polyval(p_30,theta_int );
      
   case 'profile'
      if ~exist('proportions') & isempty(proportions)
         proportions = [0.05 0.2 0.35 0.4];  %CR defaults
      end
      
      theta_int           = TDRin(:,1).*proportions(1) + TDRin(:,2).*proportions(2) + ...
         TDRin(:,3).*proportions(3) + TDRin(:,4).*proportions(4);
      theta_int_spatial   = polyval(p_30,theta_int );
      
   case '60cm'
      if ~exist('proportions') & isempty(proportions)
         proportions = [0.08 0.25 0.67];  %CR defaults
      end
      
      theta_int           = TDRin(:,1).*proportions(1) + TDRin(:,2).*proportions(2) + ...
         TDRin(:,3).*proportions(3);
      theta_int_spatial   = polyval(p_60,theta_int );
   end
end

