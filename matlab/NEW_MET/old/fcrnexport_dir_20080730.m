function output_info = fcrnexport_dir(SiteId,flag_local,ftype)

arg_default('flag_local',0);
arg_default('ftype',{'all'});

if flag_local == 0
    pth_ex = '\\PAOA003\FTP_FLUXNET';
    disp('net use \\PAOA003\FTP_FLUXNET arctic')
    dos('net use \\PAOA003\FTP_FLUXNET arctic');
else
    pth_ex = '\\PAOA003\FCRN_LOCAL';
    disp('net use \\PAOA003\FCRN_LOCAL arctic')
    dos('net use \\PAOA003\FCRN_LOCAL arctic');
end

switch upper(char(SiteId))
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
 
% output_info(1).pth = fullfile(pth_ex,dir_site,'Meteorology\Ancillary');
% output_info(2).pth = fullfile(pth_ex,dir_site,'Meteorology\Main');
% output_info(3).pth = fullfile(pth_ex,dir_site,'Meteorology\Summarized');
% output_info(4).pth = fullfile(pth_ex,dir_site,'Flux\Ancillary');
% output_info(5).pth = fullfile(pth_ex,dir_site,'Flux\ComputedFluxes');
% output_info(6).pth = fullfile(pth_ex,dir_site,'Flux\NEP');
% output_info(7).pth = fullfile(pth_ex,dir_site,'SoilMoisture\Measured');
% output_info(8).pth = fullfile(pth_ex,dir_site,'SoilMoisture\SpatiallyCorrected');
% output_info(9).pth = fullfile(pth_ex,dir_site,'SoilCO2Efflux\ComputedEffluxes');
% 
% output_info(1).fileId = 'Met1';
% output_info(2).fileId = 'Met2';;
% output_info(3).fileId = 'Met3';
% output_info(4).fileId = 'Flx1';
% output_info(5).fileId = 'Flx2';
% output_info(6).fileId = 'Flx3';
% output_info(7).fileId = 'SM1';
% output_info(8).fileId = 'SM3';
% output_info(9).fileId = 'SR2';

for k=1:length(ftype)
    switch char(ftype{k})
        case 'all'
            output_info(1).pth = fullfile(pth_ex,dir_site,'Meteorology\Ancillary');
            output_info(2).pth = fullfile(pth_ex,dir_site,'Meteorology\Main');
            output_info(3).pth = fullfile(pth_ex,dir_site,'Meteorology\Summarized');
            output_info(4).pth = fullfile(pth_ex,dir_site,'Flux\Ancillary');
            output_info(5).pth = fullfile(pth_ex,dir_site,'Flux\ComputedFluxes');
            output_info(6).pth = fullfile(pth_ex,dir_site,'Flux\NEP');
            output_info(7).pth = fullfile(pth_ex,dir_site,'SoilMoisture\Measured');
            output_info(8).pth = fullfile(pth_ex,dir_site,'SoilMoisture\SpatiallyCorrected');
            output_info(9).pth = fullfile(pth_ex,dir_site,'SoilCO2Efflux\ComputedEffluxes');

            output_info(1).fileId = 'Met1';
            output_info(2).fileId = 'Met2';
            output_info(3).fileId = 'Met3';
            output_info(4).fileId = 'Flx1';
            output_info(5).fileId = 'Flx2';
            output_info(6).fileId = 'Flx3';
            output_info(7).fileId = 'SM1';
            output_info(8).fileId = 'SM3';
            output_info(9).fileId = 'SR2';
        case 'Met1'
            output_info(k).fileId = 'Met1';
            output_info(k).pth = fullfile(pth_ex,dir_site,'Meteorology\Ancillary');
        case 'Met2'
            output_info(k).fileId = 'Met2';
            output_info(k).pth = fullfile(pth_ex,dir_site,'Meteorology\Main');
        case 'Met3'
            output_info(k).fileId = 'Met3';
            output_info(k).pth = fullfile(pth_ex,dir_site,'Meteorology\Summarized');
        case 'Flx1';
            output_info(k).fileId = 'Flx1';
            output_info(k).pth = fullfile(pth_ex,dir_site,'Flux\Ancillary');
        case 'Flx2'
            output_info(k).fileId = 'Flx2';
            output_info(k).pth = fullfile(pth_ex,dir_site,'Flux\ComputedFluxes');
        case 'Flx3'
            output_info(k).fileId = 'Flx3';
            output_info(k).pth = fullfile(pth_ex,dir_site,'Flux\NEP');
        case 'SM1'
            output_info(k).fileId = 'SM1';
            output_info(k).pth = fullfile(pth_ex,dir_site,'SoilMoisture\Measured');
        case 'SM3'
            output_info(k).fileId = 'SM3';
            output_info(k).pth = fullfile(pth_ex,dir_site,'SoilMoisture\SpatiallyCorrected');
        case 'SR2'
            output_info(k).fileId = 'SR2';
            output_info(k).pth = fullfile(pth_ex,dir_site,'SoilCO2Efflux\ComputedEffluxes');
    end
end

return