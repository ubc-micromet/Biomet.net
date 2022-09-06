function create_fcrnexport_db(SiteId,pth_ex);

arg_default('SiteId',{'BS'  'CR' 'FEN' 'HJP02' 'JP'  'OY' 'PA'  'YF'});

if pth_ex(end) ~= '\'
    pth_ex = [pth_ex '\'];
end

for i=1:length(SiteId)
    switch upper(SiteId{i})
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
    mkdir(fullfile(pth_ex,dir_site),'Meteorology\Ancillary');
    disp(['...created ' fullfile(pth_ex,dir_site) 'Meteorology\Ancillary']);
    mkdir(fullfile(pth_ex,dir_site),'Meteorology\Main');
    disp(['...created ' fullfile(pth_ex,dir_site) 'Meteorology\Main']);
    mkdir(fullfile(pth_ex,dir_site),'Meteorology\Summarized');
    disp(['...created ' fullfile(pth_ex,dir_site) 'Meteorology\Summarized']);
    mkdir(fullfile(pth_ex,dir_site),'Flux\Ancillary');
    disp(['...created ' fullfile(pth_ex,dir_site) 'Flux\Ancillary']);
    mkdir(fullfile(pth_ex,dir_site),'Flux\ComputedFluxes');
    disp(['...created ' fullfile(pth_ex,dir_site) 'Flux\ComputedFluxes']);
    mkdir(fullfile(pth_ex,dir_site),'Flux\NEP');
    disp(['...created ' fullfile(pth_ex,dir_site) 'Flux\NEP']);
    mkdir(fullfile(pth_ex,dir_site),'SoilMoisture\Measured');
    disp(['...created ' fullfile(pth_ex,dir_site) 'SoilMoisture\Measured']);
    mkdir(fullfile(pth_ex,dir_site),'SoilMoisture\SpatiallyCorrected');
    disp(['...created ' fullfile(pth_ex,dir_site) 'SoilMoisture\SpatiallyCorrected']);
    mkdir(fullfile(pth_ex,dir_site),'SoilCO2Efflux\ComputedEffluxes');
    disp(['...created ' fullfile(pth_ex,dir_site) 'SoilCO2Efflux\ComputedEffluxes']);
    
    
end