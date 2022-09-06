function fcrnexport(SiteId,traces_fcrn)

%-------------------------------------------
% Export ascii files
%-------------------------------------------
pth_ex = '\\PAOA003\FTP_FLUXNET';
dos('net use \\PAOA003\FTP_FLUXNET arctic')

switch upper(SiteId)
case 'BS'
   dir_site = '\BERMS\SK-OldBlackSpruce';
case 'PA'
   dir_site = '\BERMS\SK-OldAspen';
case 'JP'
   dir_site = '\BERMS\SK-OldJackPine';
case 'CR'
   dir_site = 'BC_Station\BC-DFir1949';
case 'OY'
   dir_site = 'BC_Station\BC-HarvestedDFir2000';
case 'YF'
   dir_site = 'BC_Station\BC-HarvestedDFir1988';
case 'OR'
    dir_site = 'BC_Station\OR';
case 'HJP02'
    dir_site = '\BERMS\SK-HarvestedJP2002';
case 'FEN'
    dir_site = '\BERMS\SK-Fen';%added fen dec2005 Praveena
otherwise
    return
end

fcrn_table_export(traces_fcrn,'Met1',fullfile(pth_ex,dir_site,'Meteorology\Ancillary'));
fcrn_table_export(traces_fcrn,'Met2',fullfile(pth_ex,dir_site,'Meteorology\Main'));
fcrn_table_export(traces_fcrn,'Met3',fullfile(pth_ex,dir_site,'Meteorology\Summarized'));
fcrn_table_export(traces_fcrn,'Flx1',fullfile(pth_ex,dir_site,'Flux\Ancillary'));
fcrn_table_export(traces_fcrn,'Flx2',fullfile(pth_ex,dir_site,'Flux\ComputedFluxes'));
fcrn_table_export(traces_fcrn,'Flx3',fullfile(pth_ex,dir_site,'Flux\NEP'));
fcrn_table_export(traces_fcrn,'SM1',fullfile(pth_ex,dir_site,'SoilMoisture\Measured'));
fcrn_table_export(traces_fcrn,'SM3',fullfile(pth_ex,dir_site,'SoilMoisture\SpatiallyCorrected'));
