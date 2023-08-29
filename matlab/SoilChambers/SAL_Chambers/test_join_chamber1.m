
%% Load all hhour files (a slow process, 20s per day, that creates huge data variable, ~10GB in Matlab space).
%  It will be modified in the future, here just to remind me of one way to do this.
filePath = 'E:\Site_DATA\WL\met-data\hhour';
clear chamber chamberOut;
k=0;
for currentDate = datenum(2019,8,1):datenum(2019,8,23)
    tx=now;
    fileName = sprintf('%s_recalcs_UdeM.mat',datestr(currentDate,'yyyymmdd'));
    try
        load(fullfile(filePath,fileName));
        fprintf('%s loaded in %6.1f seconds. \n',fileName,(now-tx)*24*3600);

        for chNum = 1:18
            chamber = dataStruct.chamber(chNum);
            allFields = fieldnames(chamber.sample);
            N = length(chamber.sample);
            for fieldName = allFields'        
                for sampleNum = 1:N
                    fName = char(fieldName);
                    switch fName
                        case 'tv'         
                            chamberOut.chamber(chNum).tv(sampleNum+k,1) = chamber.sample(sampleNum).tv;
                        case 'flux'
                            gasTypes = fieldnames(chamber.sample(sampleNum).(fName));
                            for cellGasType = gasTypes'
                                cGasType = char(cellGasType);
                                fitFieldNames = fieldnames(chamber.sample(sampleNum).(fName).(cGasType));
                                for cellFitFieldNames = fitFieldNames'
                                    cFitFieldName = char(cellFitFieldNames);

                                    % it's one of 'lin_B', 'exp_L', 'exp_B' fields
                                    fluxFieldNames = fieldnames(chamber.sample(sampleNum).(fName).(cGasType).(cFitFieldName));
                                    for cellFluxFieldNames = fluxFieldNames'
                                        cFluxFieldNames = char(cellFluxFieldNames);
                                        switch cFluxFieldNames % ' one of: 'dcdt','rmse','t0','c0','fCO2','gof','fitOut','t_elapsed'
                                            case {'fCO2','fitOut','gof'}
                                                % skip these fields                         
                                            otherwise 
                                                chamberOut.chamber(chNum).(fName).(cGasType).(cFitFieldName).(cFluxFieldNames)(sampleNum+k,1) = ...
                                                           chamber.sample(sampleNum).(fName).(cGasType).(cFitFieldName).(cFluxFieldNames);
                                        end
                                    end
                                end
                            end
                        otherwise
                            chamberOut.chamber(chNum).(fName).avg(sampleNum+k,1) = chamber.sample(sampleNum).(fName).avg;
                    end
                end                
            end  
        end
    catch
        fprintf('Missing file %s. \n',fileName);
    end
    fprintf('File processed in %4.2f seconds.\n',(now-tx)*24*3600)
    k=k+N;
    N=0;
end

return
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
    
    
ind = find(chamberOut.chamber(chNum).tv>0);
DOY = chamberOut.chamber(chNum).tv(ind) - datenum(2019,1,0);
        figure(1)
        clf
        cGasName ='co2';
        plot(DOY,[chamberOut.chamber(chNum).flux.(cGasName).exp_B.(plotFieldName)(ind) chamberOut.chamber(chNum).flux.(cGasName).lin_B.(plotFieldName)(ind)],'.')
        ax=axis;
        axis([ax(1:2) -10 10]);
        legend('exp_B','lin_B')
        ylabel(sprintf('%s (ppm  s^{-1})',cGasName)); %m^{-2}
        title(sprintf('%s for chamber #%d',plotFieldName,chNum))

        figure(2)
        clf
        cGasName = 'ch4';
         plot(DOY,[chamberOut.chamber(chNum).flux.(cGasName).lin_B.(plotFieldName)(ind)],'.')
        ylabel(sprintf('%s (ppm  s^{-1})',cGasName)); %m^{-2}
        title(sprintf('%s for chamber #%d',plotFieldName,chNum))

    pause

end


%% OLD Plot a field
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