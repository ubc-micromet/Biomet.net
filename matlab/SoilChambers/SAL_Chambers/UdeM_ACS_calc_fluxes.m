function dataStruct = UdeM_ACS_calc_fluxes(dataStruct,chNum,sampleNum)
%
% Flux calculations for one sample of one chamber. Processing is done for
% all gases and all types of fits (program will look for all existing dcdt-s
% and calculate fluxes.
%
%
%
%
%
%

% Revisions:
%
% Mar 25, 2020 (Zoran)
%   - removed the input parameter "gasType". Made it self adapting to 
%     all gasType-s and all fit methods

gasType = 'none';
fitType = 'none';


    try
        % loop for all existing gas types (CO2, CH4, N2O)
        cellGasTypes = fieldnames(dataStruct.chamber(chNum).sample(sampleNum).flux)';
        for cGasType = cellGasTypes
            gasType = char(cGasType);
            % loop for all existing types of fits (exp_L, exp_B, lin_L, lin_B,quad_L/B)
            cellFitTypes = fieldnames(dataStruct.chamber(chNum).sample(sampleNum).flux.(gasType))';
            for cFitType = cellFitTypes
                fitType = char(cFitType);            
                dataStruct = chamber_flux_calc(dataStruct,chNum,sampleNum,gasType,fitType);
            end
        end
    catch
        fprintf('Error in UdeM_ACS_calc_fluxes. chNum = %d, sampleNum = %d, gasType = %s, fitType = %s',...
                    chNum,sampleNum,gasType,fitType);
    end
    
end

%% Local functions

% --------------------------------------------------------------------------------------
    function dataStruct = chamber_flux_calc(dataStruct,chNum,sampleNum,gasType,fitType)
        % The equation below is the standard flux calculation equation
        % It can be found in the LI-8100A manual.
        % flux = chVolume*Pbarometer*(1-chi/1000)/chArea/absTair/R *dcdt;
        %
        % Note:
        %   - One should use initial values for chi and Tair.  Using averages
        %     causes a bit of an error (<1.2%, worst case dT = 6 deg, dChi = 3mmol/mol (dT/2)/300+(dChi/2)/1000)
        %     Fix if you can by storing t0 values for h2o_ppm and Tair
        %
        %
        chVolume    = dataStruct.configIn.chamber(chNum).chVolume;
        chArea      = dataStruct.configIn.chamber(chNum).chArea;
        absTair     = (dataStruct.chamber(chNum).sample(sampleNum).airTemperature.avg + 273.15);
        if isnan(absTair)
            absTair = dataStruct.configIn.Tair_default;   % if Tair is missing, use 20 degC as the default.
                                                          % QAQC should look for missing Tsoil, Pbarometer and sort it out in
                                                          % post processing
        end
        if isfield(dataStruct.chamber(chNum).sample(sampleNum),'Pbarometer')
            Pbarometer = dataStruct.chamber(chNum).sample(sampleNum).Pbarometer.avg;
        else
            % if pressure is not measured take the default value from the config file
            Pbarometer = dataStruct.configIn.Pbar_default;
        end
        dcdt        = dataStruct.chamber(chNum).sample(sampleNum).flux.(gasType).(fitType).dcdt;
        % it should be chi(t0) below, but instead I use chi_avg. Something to improve on:
        chi         = dataStruct.chamber(chNum).sample(sampleNum).h2o_ppm.avg / 1000 ; % mmol/mol
        R = 8.314;    % Pa m3 / (mol K)
        flux = chVolume*Pbarometer*(1-chi/1000)/(chArea*absTair*R) * dcdt;
        dataStruct.chamber(chNum).sample(sampleNum).flux.(gasType).(fitType).flux = flux;
        
    end