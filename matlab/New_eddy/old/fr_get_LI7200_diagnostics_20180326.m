function diag = fr_get_LI7200_diagnostics(LI7200_diagnostic_val)

% ind_bad= find( LI7200_diagnostic_val==-999); % out of range logger becomes 0 for translation
% LI7200_diagnostic_val(ind_bad)=0;

diag_raw = dec2bin(round(LI7200_diagnostic_val));

Head     = bin2dec(diag_raw(:,1));
ToutTC   = bin2dec(diag_raw(:,2));
TinTC    = bin2dec(diag_raw(:,3));
Aux      = bin2dec(diag_raw(:,4));
DeltaP   = bin2dec(diag_raw(:,5));
Chopper  = bin2dec(diag_raw(:,6));
Detector = bin2dec(diag_raw(:,7));
PLL      = bin2dec(diag_raw(:,8));
Sync     = bin2dec(diag_raw(:,9));
AGC      = bin2dec(diag_raw(:,10:end))*6.25+6.25;

NumOfSamples = length(diag_raw(:,1));
diag.NumOfSamples = NumOfSamples;
diag.ToutTC_Sum_Bad  = NumOfSamples - sum(ToutTC);
diag.TinTC_Sum_Bad  = NumOfSamples - sum(TinTC);
diag.Aux_Sum_Bad  = NumOfSamples - sum(Aux);
diag.DeltaP_Sum_Bad  = NumOfSamples - sum(DeltaP);
diag.Chopper_Sum_Bad  = NumOfSamples - sum(Chopper);
diag.Detector_Sum_Bad = NumOfSamples - sum(Detector);
diag.PLL_Sum_Bad      = NumOfSamples - sum(PLL);
diag.Sync_Sum_Bad     = NumOfSamples - sum(Sync);
diag.AGC_Avg      = mean(AGC);
diag.AGC_Min      = min(AGC);
diag.AGC_Max      = max(AGC);
diag.AGC_Std      = std(AGC);