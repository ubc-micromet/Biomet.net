function diag = fr_get_CSAT3_diagnostics(diagnostic_val)
%
% Input:
% diagnostic_val           diagnostic value (decimal) from CSAT3
%
% Outputs:
% diag.NumOfSamples        the number of samples
% diag.Apm_Low_Sum_Bad     the number of bad Amp_Low points
% diag.Apm_Hi_Sum_Bad      the number of bad Amp_Hi points
% diag.Poor_Lock_Sum_Bad   the number of bad Poor_Lock points
% diag.Path_Length_Sum_Bad the number of bad Path_Length points
% diag.Pts_Sum_Bad         the number of samples with at least one error
% diag.Uz_Range_avg        mean range for Uz
% diag.Uy_Range_avg        mean range for Uy
% diag.Ux_Range_avg        mean range for Ux

%
%
% (c) Zoran Nesic           File created:       Jan 28, 2008
%                           Last modification:  Jan 29, 2008

% Revisions

diag = [];
try
    diag_raw = dec2bin(round(diagnostic_val),16);           % Convert decimal values to binary

    Uz_Range = bin2dec(diag_raw(:,9:10));                   % extract the Uz range
    Uy_Range = bin2dec(diag_raw(:,7:8));                    % extract the Uy range
    Ux_Range = bin2dec(diag_raw(:,5:6));                    % extract the Ux range

    Apm_Low     = bin2dec(diag_raw(:,4));                   % extract all individual errors
    Apm_Hi      = bin2dec(diag_raw(:,3));
    Poor_Lock   = bin2dec(diag_raw(:,2));
    Path_Length = bin2dec(diag_raw(:,1));

    Bad_Pts    = Apm_Low + Apm_Hi + Poor_Lock + Poor_Lock;  % create a flag that identifies all samples
    Bad_Pts    = Bad_Pts > 0;                               % with at least one error in the sample

    NumOfSamples             = length(diag_raw(:,1));       % Get the number of points in the hhour

    diag.NumOfSamples        = NumOfSamples;                % Setup the output structure
    diag.Apm_Low_Sum_Bad     = sum(Apm_Low);
    diag.Apm_Hi_Sum_Bad      = sum(Apm_Hi);
    diag.Poor_Lock_Sum_Bad   = sum(Poor_Lock);
    diag.Path_Length_Sum_Bad = sum(Path_Length);
    diag.Pts_Sum_Bad         = sum(Bad_Pts);
    diag.Uz_Range_avg        = mean(Uz_Range);
    diag.Uy_Range_avg        = mean(Uy_Range);
    diag.Ux_Range_avg        = mean(Ux_Range);

catch
    disp('Error in fr_get_CSAT3_diagnostic.m');
end
