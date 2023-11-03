
%% Load all hhour files (a slow process, 20s per day, that creates huge data variable, ~10GB in Matlab space).
%  It will be modified in the future, here just to remind me of one way to do this.
filePath = 'E:\Site_DATA\WL\met-data\hhour';
clear chamber;
k=1;
for currentDate = datenum(2019,7,1):datenum(2019,7,31)
    tic;
    fileName = sprintf('%s_recalcs_UdeM.mat',datestr(currentDate,'yyyymmdd'));
    try
        load(fullfile(filePath,fileName));
        fprintf('loaded file %s in %6.1f seconds. \n',fileName,toc);
        for chNum = 1:18
            if k==1
                chamber{chNum} = dataStruct.chamber(chNum);
            else
                chamber{chNum}.sample = [chamber{chNum}.sample dataStruct.chamber(chNum).sample];
            end
        end
        k=0;
    catch
        fprintf('Missing file %s. \n',fileName);
    end
end


%% Extract all the traces from a huge data structure (chambers) into a much smaller 
%  structure (chambersOut) and change the indexing so the traces can be easily plotted.
% Note for self: this is good for plotting and data processing but bad for Biomet data base
%                automated procedure.  Change the indexing so that sample(sampleNum) becomes the
%                first level in the tree not the last.  That works with Biomet data base programs.

clear chamberOut
N = length(chamber{1}.sample);
chamberOut.chamber(18).tv = NaN * zeros(N,1);
allFields = fieldnames(chamber{1}.sample);
for chNum = 1:18
%     N = length(chamber{chNum}.sample);
    for fieldName = allFields'        
        for sampleNum = 1:N
            fName = char(fieldName);
            switch fName
                case 'tv'         
                    chamberOut.chamber(chNum).tv(sampleNum,1) = chamber{chNum}.sample(sampleNum).tv;
                case 'flux'
                    gasTypes = fieldnames(chamber{chNum}.sample(sampleNum).(fName));
                    for cellGasType = gasTypes'
                        cGasType = char(cellGasType);
                        fitFieldNames = fieldnames(chamber{chNum}.sample(sampleNum).(fName).(cGasType));
                        for cellFitFieldNames = fitFieldNames'
                            cFitFieldName = char(cellFitFieldNames);

                            % it's one of 'lin_B', 'exp_L', 'exp_B' fields
                            fluxFieldNames = fieldnames(chamber{chNum}.sample(sampleNum).(fName).(cGasType).(cFitFieldName));
                            for cellFluxFieldNames = fluxFieldNames'
                                cFluxFieldNames = char(cellFluxFieldNames);
                                switch cFluxFieldNames % ' one of: 'dcdt','rmse','t0','c0','fCO2','gof','fitOut','t_elapsed'
                                    case {'fCO2','fitOut','gof'}
                                        % skip these fields                         
                                    otherwise 
                                        chamberOut.chamber(chNum).(fName).(cGasType).(cFitFieldName).(cFluxFieldNames)(sampleNum,1) = ...
                                                   chamber{chNum}.sample(sampleNum).(fName).(cGasType).(cFitFieldName).(cFluxFieldNames);
                                end
                            end
                        end
                    end
                otherwise
                    chamberOut.chamber(chNum).(fName).avg(sampleNum,1) = chamber{chNum}.sample(sampleNum).(fName).avg;
            end
        end
    end
end

%% Plot a field
plotFieldName = 'flux';
for chNum = 1:18
    k = 1;
    DOY = chamberOut.chamber(chNum).tv - datenum(2019,1,0);
    for gasName = fieldnames(chamberOut.chamber(chNum).flux)'
        figure(k)
        cGasName = char(gasName);
        
        ax(1) = subplot(2,1,1);
        plot(DOY,[chamberOut.chamber(chNum).flux.(cGasName).exp_B.(plotFieldName) chamberOut.chamber(chNum).flux.(cGasName).lin_B.(plotFieldName)])
        legend('exp_B','lin_B')
        ylabel(sprintf('%s (ppm  s^{-1})',cGasName)); %m^{-2}
        title(sprintf('%s for chamber #%d',plotFieldName,chNum))

        ax(2) = subplot(2,1,2);
        plot(DOY,(chamberOut.chamber(chNum).flux.(cGasName).lin_B.(plotFieldName)./chamberOut.chamber(chNum).flux.(cGasName).exp_B.(plotFieldName))*100)
        ylabel(sprintf('%s ratio lin/exp',plotFieldName)); %m^{-2}
        linkaxes(ax,'x');
        k = k+1;
    end
    pause

end
%% Saving traces

% Create an output matrix (reserve more space than needed)

for chNum=1:18
    dataOut = NaN * zeros(N,50);
    strHeader = '';
    colCount = 0;
    colCount = colCount+1; strHeader = [strHeader 'END time']; dataOut(:,colCount) = chamberOut.chamber(chNum).tv; %#ok<*AGROW>
    tvEndHour = ceil(rem(chamberOut.chamber(chNum).tv*24,24));
    colCount = colCount+1; strHeader = [strHeader ',END hour']; dataOut(:,colCount) = tvEndHour;
    colCount = colCount+1; strHeader = [strHeader ',Tair']; dataOut(:,colCount) = chamberOut.chamber(chNum).airTemperature.avg;
    colCount = colCount+1; strHeader = [strHeader ',PAR']; dataOut(:,colCount) = chamberOut.chamber(chNum).PAR_in.avg;
    colCount = colCount+1; strHeader = [strHeader ',Tsoil']; dataOut(:,colCount) = chamberOut.chamber(chNum).soilTemperature_in.avg;
    colCount = colCount+1; strHeader = [strHeader ',VWC']; dataOut(:,colCount) = chamberOut.chamber(chNum).soilVWC_in.avg;
    colCount = colCount+1; strHeader = [strHeader ',H2O']; dataOut(:,colCount) = chamberOut.chamber(chNum).h2o_ppm.avg;
    colCount = colCount+1; strHeader = [strHeader ',CO2']; dataOut(:,colCount) = chamberOut.chamber(chNum).co2_dry.avg;
    colCount = colCount+1; strHeader = [strHeader ',CH4']; dataOut(:,colCount) = chamberOut.chamber(chNum).ch4_dry.avg;      
    for cellGasNames = {'co2','ch4'}    
        cGasName = char(cellGasNames); 
        for cellFitFieldNames = {'lin_B','exp_B'}            
            cFitName = char(cellFitFieldNames);
            colCount = colCount+1; strHeader = [strHeader ',' cGasName '_dcdt_' cFitName]; dataOut(:,colCount) = chamberOut.chamber(chNum).flux.(cGasName).(cFitName).dcdt;
            colCount = colCount+1; strHeader = [strHeader ',' cGasName '_flux_' cFitName]; dataOut(:,colCount) = chamberOut.chamber(chNum).flux.(cGasName).(cFitName).flux;
            colCount = colCount+1; strHeader = [strHeader ',' cGasName '_rmse_' cFitName]; dataOut(:,colCount) = chamberOut.chamber(chNum).flux.(cGasName).(cFitName).rmse;
        end
    end
    fileName = fullfile('E:\Site_DATA\WL\met-data\csv',sprintf('chamber_%02d.csv',chNum));
    fid = fopen(fileName,'w');
    if fid>0
        fprintf(fid,'%s\n',strHeader);
        for sampleNum = 1:size(dataOut,1)
            for rowNum=1:colCount
                if rowNum==1
                    fprintf(fid,'%s,',datestr(dataOut(sampleNum,rowNum),0));
                else
                    fprintf(fid,'%12.4e,',dataOut(sampleNum,rowNum));
                end
            end
            fprintf(fid,'\n');
        end
        fclose(fid);
    else
        fprintf('Error!! Could not write file: %s. Probably opened in Excel.\n',fileName);
    end                 
end
fprintf('%s - Finished saving csv files.\n\n',datestr(now));       


%% Correcting the missing lin_B fluxes
%  Use the same constant that multiplied exp_B dcdt to get flux for lin_B
for chNum=1:18
    chamberOut.chamber(chNum).flux.co2.lin_B.flux = chamberOut.chamber(chNum).flux.co2.exp_B.flux ./ chamberOut.chamber(chNum).flux.co2.exp_B.dcdt ...
                                                .* chamberOut.chamber(chNum).flux.co2.lin_B.dcdt;
    chamberOut.chamber(chNum).flux.ch4.lin_B.flux = chamberOut.chamber(chNum).flux.ch4.exp_B.flux ./ chamberOut.chamber(chNum).flux.ch4.exp_B.dcdt ...
                                                .* chamberOut.chamber(chNum).flux.ch4.lin_B.dcdt;                                         
end