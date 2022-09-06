function [Theta_v] = tdr_msmt_conversion(dT,Lprobe,LOM,offset);
%program to convert TDR travel time to volumetric water content

 
%inputs: dT - travel time in nsec
%        Lprobe - length of probe in sec
%        LOM - OM depth in cm
%        offset - diode offset is the "return trip" travel time (nsec) by 
%               the MP9-17 reflectometer (applicable at CR)

%Note:
%oven dried dilelectric constants for Cambell River (^0.5)
%organic = 1.13
%mineral = 1.61
%0.1256 is the theoretical slope which relates volumetric water content to T/Tair
%determined by G. Ethier (UVic) for the mature Douglas-fir forest (CR)

% E. Humphreys Feb 17, 2002

if isempty(LOM) | ~exist('LOM');
    LOM = 0;                        %set default depth of OM = 0 cm
end

if isempty(offset) | ~exist('offset');
    offset = 0;                        %set default offset = 0 nsec
end


speed_of_light = 30; %cm nsec-1

Tair           = 2.*Lprobe./speed_of_light;

Tdry_Tair      = (LOM./Lprobe).*1.13 + ((Lprobe-LOM)./Lprobe).*1.61;

for i = 1:size(dT,1);
Theta_v(i,:)   = ((dT(i,:)-offset)./Tair - Tdry_Tair).*0.1256;
%Theta_v(:,i)   = ((dT(:,i)-offset)./Tair - 1.55).*0.1193;
end

disp('done');



