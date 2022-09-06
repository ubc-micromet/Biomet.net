function diag = fr_get_LI7500_diagnostics(LI7500_diagnostic_val)

diag_raw = dec2bin(round(LI7500_diagnostic_val));

Chopper  = bin2dec(diag_raw(:,1));
Detector = bin2dec(diag_raw(:,2)); 
PLL      = bin2dec(diag_raw(:,3));
Sync     = bin2dec(diag_raw(:,4));
AGC      = bin2dec(diag_raw(:,5:end))*6.25;

NumOfSamples = length(diag_raw(:,1));
diag.NumOfSamples = NumOfSamples;
diag.Chopper_Sum_Bad  = NumOfSamples - sum(Chopper);
diag.Detector_Sum_Bad = NumOfSamples - sum(Detector);
diag.PLL_Sum_Bad      = NumOfSamples - sum(PLL);
diag.Sync_Sum_Bad     = NumOfSamples - sum(Sync);
diag.AGC_Avg      = mean(AGC);
diag.AGC_Min      = min(AGC);
diag.AGC_Max      = max(AGC);
diag.AGC_Std      = std(AGC);