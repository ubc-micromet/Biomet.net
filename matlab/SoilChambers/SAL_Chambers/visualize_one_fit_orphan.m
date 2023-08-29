function visualize_one_fit(dataOut,chNum,slopeNum,fitType,gasType,figNumIn,flagVerbose) %#ok<*INUSL>
    arg_default('fitType','exp_L')
    arg_default('flagVerbose',false);
    arg_default('figNumIn',99)
    
    switch lower(gasType)
        case 'co2'
            gasName = 'CO2d_ppm';
            unitGain = 1;
            strYlabel = 'CO_2 (ppm)';
        case 'ch4'
            gasName = 'CH4d_ppm';   
            unitGain = 1000;
            strYlabel = 'CH_4 (ppmb)';
    end    
    try
        % Commented out data plotting for the calculations that were done 
        % with slopeNum/chNum reversed (Mar 1 and Mar 4, all before Mar 14) :-(
    %     fitOut  = dataOut.chamber(slopeNum).sample(chNum).flux.co2.(fitType).fitOut;
    %     gof     = dataOut.chamber(slopeNum).sample(chNum).flux.co2.(fitType).gof;
    %     fCO2    = dataOut.chamber(slopeNum).sample(chNum).flux.co2.(fitType).fCO2;
        fitOut  = dataOut.chamber(chNum).sample(slopeNum).flux.(gasType).(fitType).fitOut;
        gof     = dataOut.chamber(chNum).sample(slopeNum).flux.(gasType).(fitType).gof;
        fCO2    = dataOut.chamber(chNum).sample(slopeNum).flux.(gasType).(fitType).fCO2;
        optionsIn.skipPoints        = dataOut.configIn.chamber(chNum).(gasType).fit_exp.skipPoints;            
        optionsIn.deadBand          = dataOut.configIn.chamber(chNum).(gasType).fit_exp.deadBand;                      
        optionsIn.pointsToTest      = dataOut.configIn.chamber(chNum).(gasType).fit_exp.pointsToTest;         
        optionsIn.timePeriodToFit   = dataOut.configIn.chamber(chNum).(gasType).fit_exp.timePeriodToFit;


        configIn = dataOut.configIn;
        tv = dataOut.rawData.analyzer.LGR.tv;
        ch_time_hours_LGR = (tv-tv(1))*24;
        %indOut = UdeM_find_chamber_indexes(dataOut,configIn);
        indX = dataOut.indexes.analyzer.LGR(chNum).start';
        indY = dataOut.indexes.analyzer.LGR(chNum).end';

        t_fit = ch_time_hours_LGR(indX(slopeNum):indY(slopeNum));
        c_fit = dataOut.rawData.analyzer.LGR.(gasName)(indX(slopeNum):indY(slopeNum));
        %plot(t_fit,c_fit,'ro')


        dcdt = fitOut.dcdt; %#ok<*SAGROW>
        rmse_exp = fitOut.rmse;
        c0 = fitOut.c0;
        t0 = fitOut.t0;
        N_optimum = fitOut.N_optimum;
        t0All = fitOut.t0All;
        c0All = fitOut.c0All;
        dcdtAll = fitOut.dcdtAll;
        rmseAll = fitOut.rmseAll;
        if flagVerbose
            fprintf('ch: %d  h: %d  rmse: %6.4f  dcdt: %6.4f   c0: %6.2f  t0: %6.2f\n\n',chNum,slopeNum,rmse_exp*unitGain,dcdt*unitGain,c0,t0)
        end

        % ==================================================
        % First figure contains the data fits plots 
        % ==================================================
        figNum = figNumIn;
        figure(figNum);
        set(figNum,'Name',sprintf('%s  Chamber %d, hour = %d        %s',upper(gasType),chNum,slopeNum,datestr(floor(tv(1)))),'numbertitle','off','menubar','none');

        clf

        subplot(1,2,1)
        x=t_fit/24;%t_fit(optionsIn.skipPoints:end,1);
        x=(x-x(optionsIn.skipPoints))*24*60*60;
        plot(fCO2{N_optimum},x,c_fit) %(optionsIn.skipPoints:end,1))
        xlabel('t (sec)')
        ylabel(strYlabel)
        title(sprintf('%s       Chamber %d, hour = %d',datestr(floor(tv(1))),chNum,slopeNum))
        ax=axis;
        if ax(4) > 1000 & strcmpi(gasType,'co2') %#ok<*AND2>
            axis([ax(1:2) min(c_fit) max(c_fit)])
        elseif ax(4) > 5 & strcmpi(gasType,'ch4')
            axis([ax(1:2) min(c_fit) max(c_fit)])        
        end
        ax = axis;
        v = [0 ax(3);
            0 ax(4);
            optionsIn.deadBand ax(4);
            optionsIn.deadBand ax(3)];
        f=[1 2 3 4];
        h=patch('Vertices',v,'faces',f,'facecolor','g','edgecolor','none','facealpha',0.2); %#ok<*NASGU>

        v2 = [ax(1) ax(3);ax(1) ax(4);0 ax(4);0 ax(3)];
        f2=[1 2 3 4];
        h2=patch('Vertices',v2,'faces',f2,'facecolor','y','edgecolor','none','facealpha',0.3);

        v3 = [0                         max(ax(3),c0-10);
            0                         min(ax(4),c0+10);
            optionsIn.pointsToTest    min(ax(4),c0+10);
            optionsIn.pointsToTest    max(ax(3),c0-10)];
        f3=[1 2 3 4];
        h3=patch('Vertices',v3,'faces',f3,'facecolor','none','edgecolor','#0072BD','facealpha',0.7);


        %legend('Data','fit','deadband','skipped','t0 search','location','southeast')

        %hh=line(x(fitOut.N_optimum+optionsIn.skipPoints),c_fit(fitOut.N_optimum),'marker','o','markersize',10,'color','#D95319','markerfacecolor','#D95319')
        hh=line(t0,c0,'marker','+','markersize',10,'color','#D95319','markerfacecolor','#D95319','linewidth',2);

        line([t0 ax(2)],[c0 dcdt*(ax(2)-t0)+c0],'linewidth',1,'color','g')
        ind_line = find(x>=x(1)+t0 & x < x(1)+t0+60);
    %    ind_line = find(x>=x(1)+t0);
    %ind_line = ind_line(1)+[0:dataOut.configIn.chamber(chNum).fit_exp.timePeriodToFit-1];
        p = polyfit(x(ind_line+optionsIn.skipPoints-1),c_fit(ind_line+optionsIn.skipPoints-1),1);
    %    p = polyfit(x(ind_line(1)+optionsIn.skipPoints-1),c_fit(ind_line+optionsIn.skipPoints-1),1);
        y = ([t0 ax(2)] )*p(1);
        y = y-y(1)+c0;
        line([t0 ax(2)],y,'linewidth',1,'color','k')
        zoom on
        legend('Data','fit','deadband','skipped','t0 search','t0',...
            sprintf('dcdt_{exp}: %6.4f',dcdt*unitGain),...
            sprintf('dcdt_{lin}: %6.4f',p(1)*unitGain),...
            'location','southeast')


        subplot(1,2,2)

        yyaxis left
        plot(fitOut.t0All,fitOut.rmseAll,'-',fitOut.t0All(N_optimum),fitOut.rmseAll(N_optimum),'o'  )
        %axis square
        xlabel('t_0')
        ylabel('rmse')
        yyaxis right
        plot(fitOut.t0All,fitOut.dcdtAll,'-',fitOut.t0All(N_optimum),fitOut.dcdtAll(N_optimum),'o'  )
        ylabel('dcdt')
        zoom on

    %     try
    %         subplot(2,2,3)
    %         plot(t0All,dcdtAll*unitGain,'-',...
    %             t0,dcdt*unitGain,'o'  )
    %         %axis square
    %         xlabel('t_0')
    %         ylabel('dcdt')
    %     catch
    %         subplot(2,2,3)
    %         plot(1:length(dcdtAll),dcdtAll*unitGain,'-',...
    %             N_optimum,dcdt*unitGain,'o'  )
    %         %axis square
    %         xlabel('N')
    %         ylabel('dcdt')
    %     end
    %     zoom on
    catch
        fprintf('Error in visualize_one_fit.m. chNum = %d, slopeNum = %d, fitType = %s, gastType = %s\n',chNum,slopeNum,fitType,gasType);
    end