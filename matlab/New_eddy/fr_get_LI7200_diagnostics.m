function diag = fr_get_LI7200_diagnostics(LI7200_diagnostic_val)
%  diag = fr_get_LI7200_diagnostics(LI7200_diagnostic_val)
%
% (c) Zoran Nesic               File created:
%                               Last modification:  Mar 26, 2018

% Revisions:
%
% Mar 26, 2018 (Zoran)
%   - Redone the processing to increase the speed.  Moved away from dec2bin
%     and bin2dec processing to proper bitwise calculation.  The speed
%     increase was 1000 fold.

% ind_bad= find( LI7200_diagnostic_val==-999); % out of range logger becomes 0 for translation
% LI7200_diagnostic_val(ind_bad)=0;

%diag_raw = dec2bin(round(LI7200_diagnostic_val));

Head     = bitand(uint16(round(LI7200_diagnostic_val)),uint16(2^12))>0;
ToutTC   = bitand(uint16(round(LI7200_diagnostic_val)),uint16(2^11))>0;
TinTC    = bitand(uint16(round(LI7200_diagnostic_val)),uint16(2^10))>0;
Aux      = bitand(uint16(round(LI7200_diagnostic_val)),uint16(2^9))>0;
DeltaP   = bitand(uint16(round(LI7200_diagnostic_val)),uint16(2^8))>0;
Chopper  = bitand(uint16(round(LI7200_diagnostic_val)),uint16(2^7))>0;
Detector = bitand(uint16(round(LI7200_diagnostic_val)),uint16(2^6))>0;
PLL      = bitand(uint16(round(LI7200_diagnostic_val)),uint16(2^5))>0;
Sync     = bitand(uint16(round(LI7200_diagnostic_val)),uint16(2^4))>0;
AGC      = bitand(uint16(round(LI7200_diagnostic_val)),...
                 uint16(2^3)+uint16(2^2)+uint16(2^1)+uint16(2^0));
AGC      = double(AGC)*6.25+6.25;

NumOfSamples = length(LI7200_diagnostic_val(:,1));
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