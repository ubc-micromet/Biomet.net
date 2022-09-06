function[T_spatial] = calc_soiltemperature_spatial(tv,Tin,siteID,selection);

%
% Inputs: Tin - soil temperature to be spatially corrected
%         selection - 1 = '2cm' (use an average of 2, 3 2cm tc's for Tin)
%                   - 2 = '5cm' 
%						  - 3 = '10cm'
%         tv - time vector in datenum format
%
% E. Humphreys  Jan 2003
% Revisions 
%

if ~isstr(selection)
   profile_depth = {'2cm' '5cm' '10cm'};
   selection = char(profile_depth(selection));
end

switch upper(siteID)
case 'CR'
   %coefficients to convert database hhour 2cm, 5cm, 10cm soil temperature 
   %to spatial integrated soil temperatures based on 10 tdr/soil resp'n stations (based on 2002 
   %manual measurements)
   p_2          = [0.929    0.721];      
   p_5          = [0.955    0.716];        
   p_10         = [0.888    1.184];      
case 'OY'
   p_2          = [1.052   -1.516];      
   p_5          = [1.064   -0.987];        
   p_10         = [1.171   -1.578];      
case 'YF'
   p_2          = [1.105   -0.584];      
   p_5          = [0.923    1.098];        
   p_10         = [1.001    0.395];      
   
otherwise
   disp('program not initialized for this site');
   return
end

%calculate new spatially integrated soil temperatures:
switch selection
case '2cm'
   T_spatial  = polyval(p_2,Tin);
case '5cm'
   T_spatial  = polyval(p_5,Tin);
case '10cm'
   T_spatial  = polyval(p_10,Tin);
end

