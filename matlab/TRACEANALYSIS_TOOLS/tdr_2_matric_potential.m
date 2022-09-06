function [psi_soil] = tdr_2_matric_potential(soil_moisture,depth,siteID);
%calculate soil matric potential
%
% Input: soil_moisture - clean, filled tdr/vol water content trace
%        depth - bottom depth in cm which soil_moisture represents, Note for 100 cm
%              averaged profile, use curve for top depth for 'best' results (ie set depth = < 70)
%        siteID - only works for 'CR' at this point
%
% Ouptu: PsiS - in MPa
%
%
% E.Humphreys   Nov 27, 2001
% Revisions: added OY and YF retention curve info, Jan 2003
%------------------------------------------------------------------------------------

switch upper(siteID)
   
case 'CR'
   historical = 1;
   
   if historical == 0;
      if depth <= 30 %appropriate for 0 - 30 cm
         m = 0.3504; %det. using pressure plate cores, 2002
         b = -0.1484;
         psi_soil = -((soil_moisture./m).^(1./b))./1000;
      else% appropriate for 30 - 70 cm
         m = 0.4409; %det. using pressure plate cores, 2002
         b = -0.2596;
         psi_soil = -((soil_moisture./m).^(1./b))./1000;
      end
   else %values developed in '98/'99
      %retention curve coefficients determined in lab
      coeff  = [8634.537211	1.000021519;	7267.905943	1.000020494]; %50-6cm; 70-50cm;
      C      = [0.46 0.384]; %shallow; deep
      th_r   = [-1465.56931  -1409.942528];
      
      %bin together the retention curves for a top layer and lower layer value...
      %apply retention curve coefficients to CS615
      psi_soil = NaN.*ones(size(soil_moisture));
      
      for i = 1:size(soil_moisture,2);
         if depth(:,i) > 30 & depth(:,i) < 110;
            psi_soil(:,i) = th2psi(soil_moisture,C(2),th_r(2),coeff(2,1),coeff(2,2));
         elseif depth(:,i) <= 30
            psi_soil(:,i) = th2psi(soil_moisture,C(1),th_r(1),coeff(1,1),coeff(1,2));
         end
      end
      
      %average Psi soil weighted for depth
      if size(psi_soil,2) == 4
         psi_soil = (psi_soil(:,1).*(0.06-0) + psi_soil(:,2).*(.26-0.06) + ...
            psi_soil(:,3).*(0.61-0.26) + psi_soil(:,4).*(1.01-0.61)); 
      end
   end
   
case 'OY'
   if depth <= 20 %appropriate for 0 - 20 cm
      %m = 0.5437; %det. using pressure plate cores, 2002
      %b = -0.2123;
      %psi_soil = -((soil_moisture./m).^(1./b))./1000;
      
      coeff  = [0.1231    1.2339]; %0-20cm;
      C      = [0.6227]; 
      th_r   = [0];
      psi_soil = th2psi(soil_moisture,C,th_r,coeff(1),coeff(2))./10000;
      
   else% appropriate for 20 - 50 cm
      %m = 0.3978; %det. using pressure plate cores, 2002
      %b = -0.204;
      %psi_soil = -((soil_moisture./m).^(1./b))./1000;
      
      coeff  = [0.2360    1.2128]; %0-20cm;
      C      = [0.5012]; 
      th_r   = [0];
      psi_soil = th2psi(soil_moisture,C,th_r,coeff(1),coeff(2))./10000;

   end
   
case 'YF'
   %appropriate for 0 - 50 cm
   m = 0.3688; %det. using pressure plate cores, 2002
   b = -0.0928;
   psi_soil = -((soil_moisture./m).^(1./b))./1000;
   
   
   coeff  = [51.5338    1.0947]; %0-50cm;
   C      = [0.6965]; 
   th_r   = [0];
   psi_soil = th2psi(soil_moisture,C,th_r,coeff(1),coeff(2))./10000;

otherwise
   disp('This program not setup for sites other than CR');
   return
end


%------------------------------------------------------------------------------------
function [out] = th2psi(th,th_sat,th_r,coeffa,coeffb);

th_n = (th-th_r)./(th_sat-th_r);
m = 1-(1./coeffb);

tmp  = 1./(th_n.^(1./m));
tmp2 = (tmp-1).^(1./coeffb);
out  = tmp2./coeffa;
out  = -out./10; %MPa