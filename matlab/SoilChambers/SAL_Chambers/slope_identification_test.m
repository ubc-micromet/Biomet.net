% First choose/create test data set
create_test_data

% Run processing
start_ind = 1;
rmse = NaN*zeros(numOfSlopes,1);
rmse_firstorder = NaN*zeros(numOfSlopes,1);
rmse_exp = NaN*zeros(numOfSlopes,1);
dcdt = NaN*zeros(numOfSlopes,1);
dcdt1 = NaN*zeros(numOfSlopes,1);
dcdt_firstorder= NaN*zeros(numOfSlopes,1);
dcdt_exp_fit= NaN*zeros(numOfSlopes,1);
figure(1)

h=[];

figure(1);
set(1,'Name','Soil flux slope testing','numbertitle','off','menubar','none','WindowState','maximized');
Msubplot=2; Nsubplot=2;
for cntSubplot=1:Msubplot*Nsubplot
    axH(cntSubplot) = subplot(Msubplot,Nsubplot,cntSubplot); %#ok<*SAGROW>
    zoom on
end
linkaxes(axH(2:3),'x');
zoom on

% Exponential fit parameters
co2fitType = fittype('cs+(c0-cs)*exp(A*(t-t0))','problem',{'c0','t0'},'independent','t');
co2fitOptions = fitoptions('Method','NonlinearLeastSquares',...
                        'Robust','off',...
                        'StartPoint',[500 -0.1],...
                        'Lower',[-Inf 0],...
                        'Upper',[0 5000],...
                        'TolFun',1e-8,...
                        'TolX',1e-8,...
                        'MaxIter',800,...
                        'DiffMinChange',1e-8,...
                        'DiffMaxChange',0.1,...
                        'MaxFunEvals',1600);
tic
% Exponetial fit
deadBand = 80;
co2_curvefit = co2(deadBand:end);
t_curvefit   = t_sec(deadBand:end);

for i=skipPoints:skipPoints+pointsToTest
    ind = [start_ind:start_ind+slope_length-1]+i-1; %#ok<*NBRAK>
    x_one = t_sec(ind)-t_sec(ind(1));
    y_one = co2(ind);
    [p,s] = polyfit(x_one,y_one,N_poly); 
    co2_line = polyval(p,x_one); 
    rmse(i) = sqrt(mean((co2(ind)-co2_line).^2));
 [p_firstorder,s_firstorder] = polyfit(x_one,y_one,1);
 dcdt_firstorder(i) = p_firstorder(1);
 co2_line_firstorder = polyval(p_firstorder,x_one);
 rmse_firstorder(i) = sqrt(mean((co2(ind)-co2_line_firstorder).^2));
 
 % Exponetial fit
 co2fit_c0 = co2fit_c0_const;
 co2fit_t0 = t_sec(ind(1));
 [fCO2,gg] = fit(t_curvefit,co2_curvefit,co2fitType,co2fitOptions,'problem',{co2fit_c0, co2fit_t0});
 dcdt_exp_fit(i) = -fCO2.A*(fCO2.cs-co2fit_c0);
 rmse_exp(i) = sqrt(gg.sse/length(t_curvefit));
 fprintf('%d  dcdt: %6.4f (%6.4f) sse: %10.4f  r2: %6.4f t0: %3.1f\n',i,dcdt_exp_fit(i),true_slope_const,gg.sse,gg.rsquare,co2fit_t0)
 
 if 1==1
    subplot(Msubplot,Nsubplot,1)
    plot(t_sec,co2)
    ax=axis;axis([1 length(co2) ax(3:4)])
    line(t_sec(ind),co2_line,'linewidth',2,'color','r','linewidth',2)
    co2_line_firstorder_plot = polyval([p_firstorder(1) y_one(1)],x_one);
    line(t_sec(ind),co2_line_firstorder_plot,'linewidth',2,'color','k','linewidth',2)
    title(['\sigma_{noise}' sprintf(' = %3.2f ppm, Test case  #%d, option #%d',extra_noise_sigma,testCaseNum,optionX)]);
    xlabel('Time [seconds]')
    ylabel('co_2 [ppm]')
    grid on
 
    subplot(Msubplot,Nsubplot,2)
    plot(1:length(dcdt),[ dcdt_firstorder dcdt dcdt_exp_fit true_slope(1:length(dcdt))],'linewidth',2) 
    ax=axis;axis([1 length(rmse) ax(3:4)])
    legend('line',sprintf('poly (%d)',N_poly),'exp','true','Location','SouthEast')
    title('dC/dt')
    xlabel('Start point [seconds]')
    ylabel('dC/dt [ppm/sec]')
    grid on
    
    
    subplot(Msubplot,Nsubplot,3)
    plot( 1:length(rmse_firstorder), rmse_firstorder,...
          1:length(rmse),rmse,...
          1:length(rmse_exp),rmse_exp,...
          'linewidth',2) 
    ax=axis;axis([1 length(rmse) ax(3:4)])
    x0 = x_one(1);
    p1=(1:N_poly)';
    for j=1:N_poly
        p1(j) = p(j) * (N_poly-j+1) * x0 ^ (N_poly-j);
    end
    dcdt(i) = polyval(p1,x0);
    dcdt1(i) = p(1);
    if ishandle(h)
        delete(h)
    end
    grid on
    legend('line',sprintf('poly (%d)',N_poly),'exp','Location','NorthEast')
    title('RMSE')
    xlabel('Start point [seconds]')
    ylabel('RMSE [ppm]')    
    
    
    subplot(Msubplot,Nsubplot,1)
    h = line(t_sec(ind),polyval([dcdt(i) co2_line(1)],x_one),'color','g','linewidth',2);
    grid on
    %linkaxes(axH(2:3),'x');
    drawnow
    %pause
 end

end
 toc
return
%%
t=t_sec(50:end); %#ok<*UNRCH>
y = co2(50:end);
%myfittype = fittype('a+b*exp(n*t)','independent',{'t'},'coefficients',{'a','b','n'}) % ,'problem','n')
myfittype = fittype('a+b*log(n*t)','independent',{'t'},'coefficients',{'a','b','n'})
% myfittype = fittype('a*u+b*exp(n*u)',...
%             'problem','n',...
%             'independent','u')
myfit = fit(t,y,myfittype) %,'problem',0)
plot(myfit,t,y)

%%
t1 = 1:0.1:20; 
y1 = 400-30*exp(-0.2*t1); 
%plot(t1,y1)
myfittype = fittype('a+b*exp(n*t)','independent',{'t'},'coefficients',{'a','b','n'})
myfit = fit(t1',y1',myfittype) %,'problem',0)
plot(myfit,t1,y1)



