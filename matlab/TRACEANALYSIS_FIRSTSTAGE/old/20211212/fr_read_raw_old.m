function Eddy_HF_data = fr_read_raw(dateIn,SiteID)

if ~exist('SiteID')
    SiteID = FR_current_siteID;
end
 
 [EngUnits, RawData, DelTimes, FileName_p, EngUnits_DAQ, EngUnits_GillR2] = ...
    fr_read_and_convert(dateIn, SiteID);
 
% Do a plot of w Ts C and H    
if strcmp(upper(SiteID),'CR') == 1
   u = EngUnits(:,1);
   v = EngUnits(:,2);
   w = EngUnits(:,3);
   T = EngUnits(:,4);
   C = EngUnits(:,11);
   H = EngUnits(:,12);
   Tc1 = EngUnits(:,8);
   Tc2 = EngUnits(:,9);
   shift = 8;
else
   u = EngUnits(:,14);
   v = EngUnits(:,16);
   w = EngUnits(:,12);
   T = EngUnits(:,13);
   C = EngUnits(:,6);
   H = EngUnits(:,7);
   Tc1 = EngUnits(:,3);
   Tc2 = EngUnits(:,4);
   shift = 6;
end

Eddy_HF_data = [u v w T C H Tc1 Tc2];