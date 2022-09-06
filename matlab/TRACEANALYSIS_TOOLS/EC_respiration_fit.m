%EC respiration fit
EBC = 1.15;
YEAR = 2000;

if YEAR == 2000;
   addpath \\annex002\kai_data\database\2000\pa\climate\clean\mat\
   addpath \\annex002\kai_data\database\2000\pa\clean\mat\      
   
   %DATA
   load('clean_tv');
   [DOY,year] = convert_tv(clean_tv,'nod',6);
   [t] = convert_tv(clean_tv,'mtv',6);
   hour = datevec(t);
   load('ustar_lin_detrend_rotated_39m');
   load('ppfd_downwelling_36m');
   %load('neeW_ec_dn');
   load('nee_main');
   load('radiation_net_31m');
   load('le_lin_detrend_rotated_39m');
   load('h_sonic_lin_detrend_rotated_39m');
   load('energy_storage_total');
   load('soil_temperature_2cm');
   load('air_temperature_Pt_resistor_ventilated_36m');
   load('barometric_pressure');
   load('h2o_avg_licor');
   load('precipitation');
   load('wind_speed_w_avg_before_rot_gill');
   %[precipitation] = INTERPOLATION_PA (precipitation);
   WETCANOPY = precipitation;
   Ta = air_temperature_Pt_resistor_ventilated_36m;
   T22000 = soil_temperature_2cm;
   Rn = radiation_net_31m;
   QH = h_sonic_lin_detrend_rotated_39m;
   QE = le_lin_detrend_rotated_39m;
   G = energy_storage_total;
   Ra = Rn - G;
   ustar2000 = ustar_lin_detrend_rotated_39m;
   wbar = wind_speed_w_avg_before_rot_gill;
   PAR2000 = ppfd_downwelling_36m;
   %NEE = neeW_ec_dn*(-1);
   NEE2000 = nee_main*EBC;
   DAY = floor(DOY);
   LASTDAY = max(DAY);
   
   
end

%YEAR = 2001;


if YEAR == 2001;
   addpath \\annex002\kai_data\database\2001\pa\climate\clean\
   addpath \\annex002\kai_data\database\2001\pa\clean\ 
   
   clean_tv = read_bor('clean_tv',8);
   nee_main = read_bor('nee_main');
   Ta = read_bor('air_temperature_Pt_resistor_ventilated_36m');
   T22001 = read_bor('soil_temperature_2cm');
   ustar2001 = read_bor('ustar_lin_detrend_rotated_39m');
   PAR2001 = read_bor('ppfd_downwelling_36m');
   [DOY,year] = convert_tv(clean_tv,'nod',6);
   [t] = convert_tv(clean_tv,'mtv',6);
   hour = datevec(t);
   NEE2001 = nee_main*(-1)*EBC;
   DAY = floor(DOY);
   LASTDAY = max(DAY);
   
end

PAR1 = [PAR2000];
NEE1 = [NEE2000];
Tsoil1 = [T22000];
ustar = [ustar2000];

i = find(~isnan(NEE1));
Y = NEE1(i);
X = Tsoil1(i);
Q = PAR1(i);
UST = ustar(i);

i = find(~isnan(X));
Y1 = Y(i);
X1 = X(i);
Q1 = Q(i);
U1 = UST(i);

ind = find(Q1 <=1 & U1 >= 0.40 & Y1 > 0);

OBS = Y1(ind);
Tsoil = X1(ind);


%initial Guess of Parameters
PARAMETERS = [10.0 0.20 8.0];

%Fit Procedure
options = optimset('maxiter', 10^7, 'maxfunevals', 10^7, 'tolx', 10^-6);
P = fminsearch('minimize_logistic',PARAMETERS,options,Tsoil,OBS);

%PLOT THE BEST FIT
A1 = P(1);
A2 = P(2);
A3 = P(3);
TS = -5:0.01:20;
TS = TS(:);

R = A1./(1+exp(A2.*(A3-TS)));

figure,plot(Tsoil,OBS,'k.');
hold on;
plot(TS,R,'b-');
zoom on;



