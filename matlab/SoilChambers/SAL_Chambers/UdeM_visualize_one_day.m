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

        tv = dataStruct.rawData.logger.CH_CTRL.tv; %#ok<*UNRCH>
        ch_time_sec_CH_CTRL = (tv-tv(1))*24; %#ok<*NASGU>
        tv = dataStruct.rawData.logger.CH_AUX_10s.tv;
        ch_time_sec_AUX_10s = (tv-tv(1))*24;
        tv = dataStruct.rawData.analyzer.LGR.tv;
        ch_time_hours_LGR = (tv-tv(1))*24;


        indX = indOut.logger.CH_AUX_10s(chNum).start';
        indY = indOut.logger.CH_AUX_10s(chNum).end';
        
        %-------------------
        % subplot 1
        %-------------------
        ax(1)=subplot(2,2,1);
        yyaxis left
        plot(ch_time_sec_AUX_10s,dataStruct.rawData.logger.CH_AUX_10s.(sprintf('CHMBR_AirTemp_Avg%d',chNum)),'-')
        title(sprintf('Chamber: %d',chNum))
        ylabel('T_{air}')
        xlabel('Hours')
        hold on
        for sampleNum=1:length(indX)
            plot(ch_time_sec_AUX_10s(indX(sampleNum):indY(sampleNum)),dataStruct.rawData.logger.CH_AUX_10s.(sprintf('CHMBR_AirTemp_Avg%d',chNum))(indX(sampleNum):indY(sampleNum)),'go')
        end
        hold off

        fieldNamePAR = sprintf('CHMBR%d_PAR_Avg',chNum);
        yyaxis right
        if isfield(dataStruct.rawData.logger.CH_AUX_10s,fieldNamePAR)
            plot(ch_time_sec_AUX_10s,dataStruct.rawData.logger.CH_AUX_10s.(fieldNamePAR),'-')
            title(sprintf('Chamber: %d',chNum))
            hold on
            for sampleNum=1:length(indX)
                plot(ch_time_sec_AUX_10s(indX(sampleNum):indY(sampleNum)),dataStruct.rawData.logger.CH_AUX_10s.(fieldNamePAR)(indX(sampleNum):indY(sampleNum)),'go')
            end
            hold off
            xlabel('Hours')
            ylabel('PAR')
        else
            plot(ch_time_sec_AUX_10s,zeros(length(ch_time_sec_AUX_10s),1))
            title('no PAR data')
            xlabel('Hours')
            ylabel('PAR')
        end
        
        indX = indOut.analyzer.LGR(chNum).start';
        indY = indOut.analyzer.LGR(chNum).end';
        %-------------------
        % subplot 2
        %-------------------
        ax(2)=subplot(2,2,2);
        traceY = medfilt1(dataStruct.rawData.analyzer.LGR.('H2O_ppm')/1000,3);   % filter out the spikes
        plot(ch_time_hours_LGR,traceY,'-')
        title(sprintf('Chamber: %d',chNum))
        ylabel('H_2O (mmol/mol)')
        xlabel('Hours')
        hold on
        for sampleNum=1:length(indX)
            plot(ch_time_hours_LGR(indX(sampleNum):indY(sampleNum)),traceY(indX(sampleNum):indY(sampleNum)),'go')
        end
        hold off
       
        %-------------------
        % subplot 4
        %-------------------
        ax(4)=subplot(2,2,4);
        traceY = medfilt1(dataStruct.rawData.analyzer.LGR.('CH4d_ppm'),3);   % filter out the spikes
        plot(ch_time_hours_LGR,traceY,'-')
        title(sprintf('Chamber: %d',chNum))
        ylabel('CH_4 (ppm)')
        xlabel('Hours')
        hold on
        for sampleNum=1:length(indX)
            plot(ch_time_hours_LGR(indX(sampleNum):indY(sampleNum)),traceY(indX(sampleNum):indY(sampleNum)),'go')
        end
        hold off

        %-------------------
        % subplot 3
        %-------------------
        ax(3)=subplot(2,2,3);
        traceY = medfilt1(dataStruct.rawData.analyzer.LGR.('CO2d_ppm'),3);   % filter out the spikes
        %     ch_time_sec(indX),dataStruct.rawData.logger.CH_AUX_10s.(sprintf('CHMBR_AirTemp_Avg%d',i))(indX),'go',...
        plot(ch_time_hours_LGR,traceY,'-')
        title(sprintf('Chamber: %d',chNum))
        ylabel('CO_2 (ppm)')
        xlabel('Hours')
  
        linkaxes(ax,'x');
        zoom on;

    catch
        fprintf('Error in UdeM_visualize_one_day.m\n');
    end
   