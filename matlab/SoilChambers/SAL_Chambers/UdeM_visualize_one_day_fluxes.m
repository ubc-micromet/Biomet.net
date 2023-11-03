function UdeM_visualize_one_day_fluxes(dataStruct,chNum,gasType,outputType,figNum,flagInit,sampleNumIn)


% Revisions
%
% Apr 16, 2023 (Zoran)
%  - replaced error message:
%       "'Error in UdeM_visualize_one_day.m\n'"
%    with: 
%       "'Error in UdeM_visualize_one_day_fluxes.m\n'" 
    arg_default('figNum',10)
    arg_default('flagInit',true)
    arg_default('chNum',1)
    arg_default('gasType','co2')
    arg_default('outputType','exp_L')
    arg_default('sampleNumIn',0)
    
    try
        currentDate = dataStruct.tv;

        if flagInit
            figure(figNum);
            clf
            zoom on;
            set(figNum,'Name',sprintf('%s  fluxes for chamber #%d   (%s)',gasType,chNum,datestr(currentDate)),'numbertitle','off','menubar','none');
    %         mVersion = ver('Matlab'); 
    %         % WindowsState option does not exist in older version of Matlab.
    %         if str2double(mVersion.Version) >= 9.6
    %             set(2,'Name',sprintf('Data for: %s',datestr(currentDate)),'numbertitle','off','menubar','none','WindowState','maximized');
    %         else
    %             set(2,'Name',sprintf('Data for: %s',datestr(currentDate)),'numbertitle','off','menubar','none');
    %         end
            return
        end

        % find how many valid flux calculations are in the dataStruct
        nSamples = 0;
        for count1 = 1:length(dataStruct.chamber(chNum).sample)
            if isempty(dataStruct.chamber(chNum).sample(count1).flux)
                break
            end
            nSamples = nSamples+1;
        end

        % plot only if thera are 2 or more points
        if nSamples > 1
            % extract variables required for plotting
            for sampleNum = 1:nSamples
                dcdt(sampleNum,1)       = dataStruct.chamber(chNum).sample(sampleNum).flux.(gasType).(outputType).dcdt;
                rmse_exp(sampleNum,1)   = dataStruct.chamber(chNum).sample(sampleNum).flux.(gasType).(outputType).rmse; %#ok<*AGROW>
                c0(sampleNum,1)         = dataStruct.chamber(chNum).sample(sampleNum).flux.(gasType).(outputType).c0;
                t0(sampleNum,1)         = dataStruct.chamber(chNum).sample(sampleNum).flux.(gasType).(outputType).t0; 
                fluxes(sampleNum,1)     = dataStruct.chamber(chNum).sample(sampleNum).flux.(gasType).(outputType).flux;
                N_optimum               = dataStruct.chamber(chNum).sample(sampleNum).flux.(gasType).(outputType).fitOut.N_optimum;
                try
                    % I have yet to implement r2 calculations for polynomial_fit_fast functions!!!
                    r2(sampleNum,1)         = dataStruct.chamber(chNum).sample(sampleNum).flux.(gasType).(outputType).gof{N_optimum}.rsquare;
                catch
                    r2(sampleNum,1)         = NaN;
                end
            end

            figure(figNum);
            clf
            axx(1)=subplot(6,1,1);
            plot(dcdt);if sampleNumIn > 0, line(sampleNumIn,dcdt(sampleNumIn),'color','g','marker','o');end
            ylabel({'dcdt','ppm/sec'});

            axx(2)=subplot(6,1,2);
            plot(rmse_exp);if sampleNumIn > 0, line(sampleNumIn,rmse_exp(sampleNumIn),'color','g','marker','o');end
            ylabel({'rmse','ppm'});

            axx(3)=subplot(6,1,3);
            plot(fluxes);if sampleNumIn > 0, line(sampleNumIn,fluxes(sampleNumIn),'color','g','marker','o');end
            ylabel({'flux','ppm m^{-1} s^{-1}'});

            axx(4)=subplot(6,1,4);
            plot(c0);if sampleNumIn > 0, line(sampleNumIn,c0(sampleNumIn),'color','g','marker','o');end
            ylabel('C_0');

            axx(5)=subplot(6,1,5);
            plot(t0);if sampleNumIn > 0, line(sampleNumIn,t0(sampleNumIn),'color','g','marker','o');end
            ylabel('T_0');            

            axx(6)=subplot(6,1,6);
            plot(r2);if sampleNumIn > 0, line(sampleNumIn,r2(sampleNumIn),'color','g','marker','o');end
            ylabel('r^2');            

            linkaxes(axx,'x');
            zoom on
        end
    catch
        fprintf('Error in UdeM_visualize_one_day_fluxes.m\n');
    end
    