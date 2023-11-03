function UdeM_show_one_run(dataStruct,chNum,sampleNum,outputType)
        
    cFigNumMain = 2;
    cFigNum2 = 10;
    cFigNum3 = 11;

    % initialize figures
    UdeM_visualize_one_day(dataStruct,[], cFigNumMain,true)
    UdeM_visualize_one_day_fluxes(dataStruct,[],'co2',outputType,cFigNum2,true)
    UdeM_visualize_one_day_fluxes(dataStruct,[],'ch4',outputType,cFigNum3,true)
    
    % plot main traces (gases, water, temp, PAR) 
    UdeM_visualize_one_day(dataStruct,chNum, cFigNumMain,false)
    
    % Update main data plot (full day of data, cFigNumMain)
    tv = dataStruct.rawData.analyzer.LGR.tv;
    ch_time_hours_LGR = (tv-tv(1))*24;
    indOut = dataStruct.indexes;
    indX = indOut.analyzer.LGR(chNum).start';
    indY = indOut.analyzer.LGR(chNum).end';
    traceY = medfilt1(dataStruct.rawData.analyzer.LGR.('CO2d_ppm'),3);   % filter out the spikes
    t_fit = ch_time_hours_LGR(indX(sampleNum):indY(sampleNum));
    c_fit = traceY(indX(sampleNum):indY(sampleNum));
    figure(cFigNumMain)
    subplot(2,2,3);
    hold on
    plot(t_fit,c_fit,'go')
    hold off     
    
    % Plot fluxes
    plotDataType = outputType; %'exp_B';
    UdeM_visualize_one_day_fluxes(dataStruct,chNum,'co2',outputType,cFigNum2,false,sampleNum) 
    UdeM_visualize_one_day_fluxes(dataStruct,chNum,'ch4',outputType,cFigNum3,false,sampleNum)
    UdeM_visualize_one_fit(dataStruct,chNum,sampleNum,plotDataType,'co2',98)
    UdeM_visualize_one_fit(dataStruct,chNum,sampleNum,plotDataType,'ch4',99)
    
    