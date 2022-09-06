function [t_sr,t_sr_solar,t_ss,t_solnoon,daylength,solzen_deg,decl] = solar_tim(lat,long,doy,t,daysav,daytype);

% -----INPUTS--------------------------------------------------------------
% lat       latitude
% long      longitude
% t         local time
% doy       day of the year 
% daysav    daylight savings flag (=1 if daylight savings)
% daytype   if true (=1) calculate daylengths including twilight (zenith=96 deg), else
%           calculate geometric daylength (zenith=90 deg)
%--------------------------------------------------------------------------

%-----OUTPUTS--------------------------------------------------------------
% t_sr        time of sunrise in decimal hours, corrected
% t_sr_solar  time of sunrise in uncorrected solar time
% t_solnoon   time of solar noon, uncorrected
% daylength   daylength in decimal hours at input date, time and location
% solzen_deg  solar zenith at input date, time and location
% decl        declination angle at input date, time and location

% ---------test inputs-----------------------------------------------
% lat = 46.77;
% long = 117.2;
% doy = 181;
% t = 10.75;
% daysav=1;
% daytype=1;
%-------------test outputs (Campbell and Norman, p171)---------------
% t_sr = 4.43 PDT
% t_sr_solar = 3.2996 
% t_solnoon = 11.8676
% daylength = 17.1361 h
% solzen_deg = 34.6590 deg
% decl = 23.2355 deg
%---------------------------------------------------------------------

conv = pi/180; % degrees to radians conversion factor 

% calculate time of sunrise following the equations/discussion on p168-171,
% Campbell and Norman

% convert to std time if input time was daylight savings
if daysav 
    t_std = t - 1;
else
    t_std = t;
end
    
% calculate longitude correction
stdmer = 120; % closest standard meridian is 120 deg W
long_diff = stdmer - long;
LC = long_diff/15; % convert degrees to hours

% equation of time (Iqbal 1983, An Introduction to Solar Radiation, p.11)
% note: gamma in radians--formula modified to converts back to hours

gamma = (2*pi/365)*(doy-1);
ET = (0.000075 + 0.001868*cos(gamma) - 0.032077*sin(gamma) - 0.014615*cos(2*gamma) -...
    0.04089*sin(2*gamma))*(229.18/60);

% calculate time of solar noon
t_solnoon = 12 - LC - ET;

% calculate declination from Iqbal 1983, An Introduction to Solar
% Radiation, p7

decl = (0.006918 - 0.399912*cos(gamma) + 0.070257*sin(gamma) - 0.006758*cos(2*gamma) +...
       0.000907*sin(2*gamma) - 0.002697*cos(3*gamma) + 0.00148*sin(3*gamma))*(180/pi);
   
% calculate zenith angle
%solzen_rad = acos(sin(lat*conv)*sin(decl*conv)+cos(lat*conv)*cos(decl*conv)*cos((pi/12)*(t_solnoon-t_std)));
solzen_rad = acos(sin(lat*conv)*sin(decl*conv)+cos(lat*conv)*cos(decl*conv)*cos((conv*15)*(t_std-t_solnoon)));
solzen_deg = solzen_rad/conv;

% calculate half daylength
if daytype 
   zen_sr = 96; % zenith angle for daylength that includes twilight
else
   zen_sr = 90; % zenith angle for daylength from geometric sunrise to geometric sunset
end
   
daylen_rad = acos((cos(zen_sr*conv) - sin(lat*conv)*sin(decl*conv))/(cos(lat*conv)*cos(decl*conv)));
daylen_deg = daylen_rad/conv;

daylength = 2*daylen_deg/15;

% calculate time of first twilight
t_sr_solar = t_solnoon - daylen_deg/15;
t_ss_solar = t_solnoon + daylen_deg/15;
   
% calculate sunrise time
if daysav
   t_sr = t_sr_solar + LC + ET + 1;
   t_ss = t_ss_solar + LC + ET + 1;
else
   t_sr = t_sr_solar + LC + ET;
   t_ss = t_ss_solar + LC + ET;
end  