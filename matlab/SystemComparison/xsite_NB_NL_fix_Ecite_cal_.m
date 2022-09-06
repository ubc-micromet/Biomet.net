load D:\kai_data\Projects_data\XSITE\Experiments\NB_NL\Met-data\hhour\calibrations.cX8 -mat

% Make sure Sep 2 cal gets used before (licor was switched off)
cal_values(10) = cal_values(9);

cal_values(9).TimeVector = cal_values(9).TimeVector-1;

save D:\kai_data\Projects_data\XSITE\Experiments\NB_NL\Met-data\hhour\calibrations.cX8 cal_values -mat