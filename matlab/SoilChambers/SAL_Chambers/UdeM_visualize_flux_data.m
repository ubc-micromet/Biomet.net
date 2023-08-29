function UdeM_visualize_flux_data(dateIn,chNum)
   
    currentDate = floor(dateIn(1));         % for the time being force one day only
    configIn = UdeM_init_all(currentDate);  % get config file
    try
        %%
        % The following statements will load the data set
        % in case that we are re-plotting the same date, the program
        % will check if the data file has been already loaded up and stored
        % in the base memory (Matlab's workspace) and re-read it from there
        hhourPath = configIn.hhour_path;
        ss = sprintf('whos(%slastFileProcessed%s)',39,39);
        s = evalin('base',ss);
        if ~isempty(s)
            lastFileProcessed = evalin('base','lastFileProcessed');
            if lastFileProcessed == currentDate
                dataStruct = evalin('base','dataStruct'); % read the data from the 'base' instead of reloading
            else
                load(fullfile(hhourPath,sprintf('%s_recalcs_UdeM',datestr(currentDate,'yyyymmdd'))),'dataStruct');
            end
        else
            load(fullfile(hhourPath,sprintf('%s_recalcs_UdeM',datestr(currentDate,'yyyymmdd'))),'dataStruct');
        end
        assignin('base','dataStruct',dataStruct); % save for future use (see above)
        assignin('base','lastFileProcessed',currentDate);

        %%
        %  Plot all data for the selected chamber
        numOfSamples = length(dataStruct.chamber(chNum).sample);
        co2 = NaN * ones(numOfSamples,1);
        ch4 = NaN * ones(numOfSamples,1);
        h2o = NaN * ones(numOfSamples,1);
        chi = NaN * ones(numOfSamples,1);
        pressureInlet = NaN * ones(numOfSamples,1); %#ok<*NASGU>
        pressureOutlet = NaN * ones(numOfSamples,1);
        PAR_in = NaN * ones(numOfSamples,1);
        soilTemperatureIn = NaN * ones(numOfSamples,1);
        airTemperature = NaN * ones(numOfSamples,1);
        for k = 1:numOfSamples
            co2(k) = dataStruct.chamber(chNum).sample(k).co2_dry.avg;         %#ok<*AGROW>
            ch4(k) = dataStruct.chamber(chNum).sample(k).ch4_dry.avg;
            chi(k) = dataStruct.chamber(chNum).sample(k).h2o_ppm.avg/1000;   % mmol/mol 'wet' 
            pressureInlet(k) = dataStruct.chamber(chNum).sample(k).pressureInlet.avg;
            pressureOutlet(k) = dataStruct.chamber(chNum).sample(k).pressureOutlet.avg;
            airTemperature(k) = dataStruct.chamber(chNum).sample(k).airTemperature.avg;
            if ~isempty(dataStruct.chamber(chNum).sample(k).flux)
                dcdt(k) = dataStruct.chamber(chNum).sample(k).flux.co2.dcdt;
                t0(k) = dataStruct.chamber(chNum).sample(k).flux.co2.t0;
                c0(k) = dataStruct.chamber(chNum).sample(k).flux.co2.c0;
                rmse(k) = dataStruct.chamber(chNum).sample(k).flux.co2.rmse;
            end
        end

            % does the same job as above but 4x slower!
            %  tic
            %      tempStruct = dataStruct.chamber(chNum).sample;
            %      co2 = arrayfun(@(x) x.co2_dry.avg,tempStruct);
            %      ch4 = arrayfun(@(x) x.ch4_dry.avg,tempStruct);
            %      chi = arrayfun(@(x) x.h2o_ppm.avg,tempStruct);
            %  toc

        % setup figures
        set(0,'defaultAxesFontSize',8,'defaultTextFontSize',8);        
        figure(1)
        set(1,'numbertitle','off','menubar','none','toolbar','none','name','Averages')
        clf

        ax1(1)=subplot(3,2,1);
        ax1(1).Toolbar.Visible = 'on';
        plot(co2)
        title('CO_2')
        ylabel('ppm')
        ax1(3)=subplot(3,2,3);
        plot(ch4)
        title('CH_4')
        ylabel('ppm')
        ax1(5)=subplot(3,2,5);
        plot(chi)
        title('\chi_w')
        ylabel('mmol/mol')

        ax1(2)=subplot(3,2,2);
        ax1(2).Toolbar.Visible = 'on';
        plot([pressureInlet pressureOutlet])
        title('Pressures')
        ylabel('kPa')
        legend('Inlet','Outlet')
        ax1(4)=subplot(3,2,4);
        plot(pressureInlet-pressureOutlet)
        title('Pressure difference (Pin-Pout)')
        ylabel('kPa')
        ax1(6)=subplot(3,2,6);
        plot(airTemperature)
        title('Air Temperature')
        ylabel('\circC')
        %linkaxes(ax1,'x');


        aFig = axes('units','normalized','position',[0 0.95 1 .05],'color','none','ycolor','none','xcolor','none');
        h=text(0.5,0.5,sprintf('Chamber # %d',chNum),'fontsize',14,'horizontalalignment','center');

        % Figure #2
        figure(2)
        set(2,'numbertitle','off','menubar','none','name','CO2 Flux Variables')
        clf

        ax2(1)=subplot(4,1,1);
        ax2(1).Toolbar.Visible = 'on';    
        plot(dcdt)
        title('\Delta(CO_2)/\Deltat')
        ylabel('ppm/sec')
        ax2(2)=subplot(4,1,2);
        plot(rmse)
        title('RMSE')
        ylabel('ppm')
        ax2(3)=subplot(4,1,3);
        plot(t0)
        title('t_0')
        ylabel('sec')

        ax2(4)=subplot(4,1,4);
        plot(c0)
        title('C_0')
        ylabel('ppm')
        linkaxes([ax1 ax2],'x');

        aFig = axes('units','normalized','position',[0 0.95 1 .05],'color','none','ycolor','none','xcolor','none');
        h=text(0.5,0.5,sprintf('Chamber # %d',chNum),'fontsize',14,'horizontalalignment','center');
    catch
        fprintf('Error in UdeM_visualize_flux_data.m\n');
    end
    
    
    