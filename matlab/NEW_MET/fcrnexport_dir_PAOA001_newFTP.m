function output_info = fcrnexport_dir(SiteId,flag_local,ftype,DISmirrorloc)

% Revisions:
%   Feb 14, 2012 (Nick)
%       -change login syntax for XP Pro networking

arg_default('flag_local',0);
arg_default('ftype',{'all'});
arg_default('DISmirrorloc','20080729'); % first local DIS archive created

switch flag_local
    case 0 
        % Feb 14, 2012 change login syntax for XP Pro networking
    pth_ex = '\\PAOA003\FTP_FLUXNET';
    disp('net use \\PAOA003\FTP_FLUXNET arctic /user:biomet')
    dos('net use \\PAOA003\FTP_FLUXNET arctic /user:biomet');
    case 1
    pth_ex = '\\PAOA003\FCRN_LOCAL';
    disp('net use \\PAOA003\FCRN_LOCAL arctic /user:biomet')
    dos('net use \\PAOA003\FCRN_LOCAL arctic /user:biomet');
    case 2
%         pcnm = fr_get_pc_name;
%         if strcmp(upper(pcnm),'FLUXNET03')
%             pth_ex = ['D:\FCRN_DIS_archive\' char(DISmirrorloc) '\' ]; 
%         else
%             pth_ex = ['\\Fluxnet03\FCRN_DIS_archive\' char(DISmirrorloc) '\' ]; 
%             disp('net use \\Fluxnet03\FCRN_DIS_archive arctic /user:biomet');
%             dos('net use \\Fluxnet03\FCRN_DIS_archive arctic /user:biomet');
%         end
        pth_ex = DISmirrorloc;
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
   if flag_local ~= 2
      dir_site = 'BC_Station\BC-HarvestedDFir2000';
   else
      dir_site = 'BC_Station\BC-HarvestDFir2000'; 
   end
case 'YF'
   if flag_local ~= 2
      dir_site = 'BC_Station\BC-HarvestedDFir1988';
   else
      dir_site = 'BC_Station\BC-HarvestDFir1988'; 
   end
case 'OR'
    dir_site = 'BC_Station\OR';
    
case 'MPB1'
   dir_site = 'BC_Station\BC-MountainPineBeetle2006'; 
  
case 'MPB2'
    dir_site = 'BC_Station\BC-MountainPineBeetle2003'; 
    
case 'MPB3'
    dir_site = 'BC_Station\BC-MountainPineBeetleSalvageHarvested2009';
case 'HJP02'
    if flag_local ~= 2
    dir_site = '\BERMS\SK-HarvestedJP2002';
   else
      dir_site = '\BERMS\SK-HarvestJP2002'; 
   end
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