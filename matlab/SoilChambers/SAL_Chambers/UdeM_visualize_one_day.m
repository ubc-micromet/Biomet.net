function UdeM_visualize_one_day(dataStruct,chNum, figNum,flagInit)
%
% Revisions:
%   Mar 7, 2021 (Zoran)
%       - Fixed bug- the figure number was fixed to 2 in the line: "set(figNum,'Name',sprintf('Data fo..." 
    
    
    arg_default('flagInit',true)
    arg_default('chNum',1)
    arg_default('figNum',99)
    currentDate = dataStruct.tv;
    
    try
        figure(figNum);
        clf
        if flagInit
                 set(figNum,'Name',sprintf('Data for: %s',datestr(currentDate)),'numbertitle','off','menubar','none');
            return
        end
        
        indOut = dataStruct.indexes;

        % Find traces sources
        [~,strAnalyzerName] = findRawTraceName(dataStruct.configIn,chNum,'co2_dry');
        
        tv = dataStruct.rawData.analyzer.(strAnalyzerName).tv;
        ch_time_hours_Analyzer = (tv-tv(1))*24;
        
        %-------------------
        % subplot 1 (airTemperature and PAR_in)
        %-------------------
        ax(1)=subplot(2,2,1);
        
        sigTairName = 'airTemperature';
        [strTairName, strTairInstrumentName,strTairInstrumentType] = findRawTraceName(dataStruct.configIn,chNum,sigTairName);
        
        sigPARName = 'PAR_in';
        [strPARName, strPARInstrumentName,strPARInstrumentType] = findRawTraceName(dataStruct.configIn,chNum,sigPARName);

        sigTsoilName = 'soilTemperature_in';
        [strTsoilName, strTsoilInstrumentName,strTsoilInstrumentType] = findRawTraceName(dataStruct.configIn,chNum,sigTsoilName);        
        
        % If there is PAR data, create yy and xxaxis and plot PAR
        if ~isempty(strPARName)
            sigPARTV = (dataStruct.rawData.(strPARInstrumentType).(strPARInstrumentName).tv ...
                      - dataStruct.rawData.(strPARInstrumentType).(strPARInstrumentName).tv(1))*24;
            sigPARY  =  dataStruct.rawData.(strPARInstrumentType).(strPARInstrumentName).(strPARName);  
            indX  = indOut.logger.(strPARInstrumentName)(chNum).start';
            indY = indOut.logger.(strPARInstrumentName)(chNum).end';            
            yyaxis righ	                            
            plot(sigPARTV,sigPARY,'-')
            hold on
            for sampleNum=1:length(indX)
                plot(sigPARTV(indX(sampleNum):indY(sampleNum)),...
                     sigY(indX(sampleNum):indY(sampleNum)),'go')
            end
            hold off
            ylabel('PAR')
            yyaxis left        
        end

        % Plot Tair
        sigTairTV = (dataStruct.rawData.(strTairInstrumentType).(strTairInstrumentName).tv ...
                   - dataStruct.rawData.(strTairInstrumentType).(strTairInstrumentName).tv(1))*24;
        sigTairY  =  dataStruct.rawData.(strTairInstrumentType).(strTairInstrumentName).(strTairName);
        indTairX  = indOut.logger.(strTairInstrumentName)(chNum).start';
        indTairY = indOut.logger.(strTairInstrumentName)(chNum).end';       
        
        plot(sigTairTV,sigTairY,'-')
        if ~isempty(strPARName)            
            title(sprintf('Chamber: %d',chNum))
        else
            title({sprintf('Chamber: %d',chNum),'no PAR data'})
        end
        ylabel('T_{air}')
        xlabel('Hours')
        hold on
        for sampleNum=1:length(indTairX)
            plot(sigTairTV(indTairX(sampleNum):indTairY(sampleNum)),sigTairY(indTairX(sampleNum):indTairY(sampleNum)),'go')
        end
        
        % Plot Tsoil
        if ~isempty(strTsoilName)
            sigTsoilTV = (dataStruct.rawData.(strTsoilInstrumentType).(strTsoilInstrumentName).tv ...
                        - dataStruct.rawData.(strTsoilInstrumentType).(strTsoilInstrumentName).tv(1))*24;
            sigTsoilY  =  dataStruct.rawData.(strTsoilInstrumentType).(strTsoilInstrumentName).(strTsoilName);   
            indX  = indOut.logger.(strTsoilInstrumentName)(chNum).start';
            indY = indOut.logger.(strTsoilInstrumentName)(chNum).end';               
            plot(sigTsoilTV,sigTsoilY,'-')
            if ~isempty(strPARName)            
                title(sprintf('Chamber: %d',chNum))
            else
                title({sprintf('Chamber: %d',chNum),'no PAR data'})
            end
            ylabel('T_{air} and T_{soil}')
            hold on
            for sampleNum=1:length(indX)
                plot(sigTsoilTV(indX(sampleNum):indY(sampleNum)),sigTsoilY(indX(sampleNum):indY(sampleNum)),'ko')
            end
        end
        hold off

        
        indX = indOut.analyzer.(strAnalyzerName)(chNum).start';
        indY = indOut.analyzer.(strAnalyzerName)(chNum).end';
        %-------------------
        % subplot 2 (h2o_ppm)
        %-------------------
        [strTraceName, ~,~] = findRawTraceName(dataStruct.configIn,chNum,'h2o_ppm');
        ax(2)=subplot(2,2,2);
        traceY = medfilt1(dataStruct.rawData.analyzer.(strAnalyzerName).(strTraceName)/1000,3);   % filter out the spikes
        plot(ch_time_hours_Analyzer,traceY,'-')
        title(sprintf('Chamber: %d',chNum))
        ylabel('H_2O (mmol/mol)')
        xlabel('Hours')
        hold on
        for sampleNum=1:length(indX)
            plot(ch_time_hours_Analyzer(indX(sampleNum):indY(sampleNum)),traceY(indX(sampleNum):indY(sampleNum)),'go')
        end
        hold off
       
        %-------------------
        % subplot 4
        %-------------------
        ax(4)=subplot(2,2,4);
        [strTraceName, ~,~] = findRawTraceName(dataStruct.configIn,chNum,'ch4_dry');
        traceY = medfilt1(dataStruct.rawData.analyzer.(strAnalyzerName).(strTraceName),3);   % filter out the spikes
        plot(ch_time_hours_Analyzer,traceY,'-')
        title(sprintf('Chamber: %d',chNum))
        ylabel('CH_4 (ppm)')
        xlabel('Hours')
        hold on
        for sampleNum=1:length(indX)
            plot(ch_time_hours_Analyzer(indX(sampleNum):indY(sampleNum)),traceY(indX(sampleNum):indY(sampleNum)),'go')
        end
        hold off

        %-------------------
        % subplot 3
        %-------------------
        ax(3)=subplot(2,2,3);
        [strTraceName, ~,~] = findRawTraceName(dataStruct.configIn,chNum,'co2_dry');
        traceY = medfilt1(dataStruct.rawData.analyzer.(strAnalyzerName).(strTraceName),3);   % filter out the spikes
        %     ch_time_sec(indX),dataStruct.rawData.logger.CH_AUX_10s.(sprintf('CHMBR_AirTemp_Avg%d',i))(indX),'go',...
        plot(ch_time_hours_Analyzer,traceY,'-')
        title(sprintf('Chamber: %d',chNum))
        ylabel('CO_2 (ppm)')
        xlabel('Hours')
  
        linkaxes(ax,'x');
        zoom on;

    catch
        fprintf('Error in UdeM_visualize_one_day.m\n');
    end
   