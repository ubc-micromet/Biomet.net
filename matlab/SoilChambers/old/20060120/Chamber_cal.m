function[CO2_cal, CO2_zero, H2O_zero] = chamber_cal;

%program to sort out calibration of chamber licor at campbell river
%needs to load the file "paoa_001\gord\matlab\calibration_index"
%
%Reads the indexes from the file calibration_index and calculates
%the average temperature, pressure, CO2 mv and H2O mv during the 
%associated calibration period.  It then sends this information to the 
%program FR_cal_licor to get the associated calibration value.
%
%Created October 5, 1998


pth1 = ('\\boreas_007\chambers_dat\');
pth2 = ('c:\chambers_dat\');
Span_CO2_conc = 356;
Licor_temp = read_bor([pth1 '21x\cr_21x.10']);
Licor_pres = read_bor([pth1 '21x\cr_21x.11']);
Licor_temp_mv = Licor_temp/0.0122;
Licor_pres_mv = (Licor_pres - 58.340)/0.0151;

CO2_mv  = read_bor([pth1 '21x\cr_21x.8']);
H2O_mv  = read_bor([pth1 '21x\cr_21x.9']);
timeser = read_bor([pth1 '21x\cr_21x_tv'],8);  

ddoy = ch_time(timeser,8,0);
clear timeser Licor_temp Licor_pres;
calibration_matrix = load([pth1 'matlab\calibration_index.dat']);
[no_of_cals, cols] = size(calibration_matrix);


for i = 1:no_of_cals
   Zero_index = [calibration_matrix(i,1):calibration_matrix(i,2)];
   Span_index = [calibration_matrix(i,3):calibration_matrix(i,4)];
   Mean(i,1) = mean(Licor_temp_mv(Zero_index:Span_index)); 	%temperature
   Mean(i,2) = mean(Licor_pres_mv(Zero_index:Span_index)); 	%pressure
   Mean(i,7) = mean(ddoy(Zero_index:Span_index));
   Mean(i,3) = mean(CO2_mv(Zero_index));         				%CO2_zero
   Mean(i,4) = mean(H2O_mv(Zero_index));         				%H2O_zero 
   Mean(i,5) = mean(CO2_mv(Span_index));			 				%CO2_span
   Mean(i,6) = mean(H2O_mv(Span_index));			 				%H2O_span
   Zero_loc(i,1) = calibration_matrix(i,2);                 %location of Zero cal on index
   Span_loc(i,1) = calibration_matrix(i,4);                 %location of Span on index
   calibration_values(i) = fr_cal_licor(740, Span_CO2_conc, Mean(i,3), Mean(i,5),...
                                        Mean(i,6), Mean(i,1),Mean(i,2), Mean(i,4));
  
end

Cooked_cal_start = mean(calibration_values(1:6));
Cooked_cal_end = mean(calibration_values(no_of_cals -6 : no_of_cals));
calibration_values = [Cooked_cal_start,calibration_values,Cooked_cal_end];

Cooked_CO2_Zero_start = mean(Mean(1:6,3));
Cooked_CO2_Zero_end = mean(Mean(no_of_cals - 6:no_of_cals,3));
CO2_Zero_values = [Cooked_CO2_Zero_start;Mean(1:no_of_cals,3);Cooked_CO2_Zero_end];

Cooked_H2O_Zero_start = mean(Mean(1:6,4));
Cooked_H2O_Zero_end = mean(Mean(no_of_cals - 6:no_of_cals,4));
H2O_Zero_values = [Cooked_H2O_Zero_start;Mean(1:no_of_cals,4);Cooked_H2O_Zero_end];

Cooked_start_loc = 1;
Cooked_end_loc = 279020;
Zero_loc = [Cooked_start_loc;Zero_loc;Cooked_end_loc];

Index = [1:1:279020];
continuous_cal_values = interp1(Zero_loc, calibration_values, Index);
continuous_co2_zero = interp1(Zero_loc, CO2_Zero_values, Index);
continuous_h2o_zero = interp1(Zero_loc, H2O_Zero_values, Index);

CO2_cal = continuous_cal_values';
CO2_zero = continuous_co2_zero';
H2O_zero = continuous_h2o_zero';
