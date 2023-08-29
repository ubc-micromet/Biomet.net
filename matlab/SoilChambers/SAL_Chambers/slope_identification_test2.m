% slope_identification test #2

% First choose/create test data set
create_test_data

% Parameters for exponential fit
optionsIn.skipPoints = skipPoints;                  %
optionsIn.deadBand = deadBand;                      %
optionsIn.timePeriodToFit = timePeriodToFit;        % (s) length of exp fit starting from t0
optionsIn.pointsToTest      = pointsToTest;         % (samples) number of samples over which to test t0

t_fit =ch3(:,1)/24/60/60;        % input to the fit function is Matlab tv. Convert seconds
c_fit = co2;

tic;
[fitOut,fCO2,gof] = co2_exponential_fit_licor(t_fit,c_fit,optionsIn);
toc

fprintf('N_optimum = %d\n',fitOut.N_optimum);
fprintf('t0 = %4.2f sec,    c0 = %6.2f ppm\n',fitOut.t0,fitOut.c0);
fprintf('dcdt = %6.4f (true = %6.4f),   rmse = %8.4f \n',fitOut.dcdt,true_slope_const,fitOut.rmse);
fCO2{fitOut.N_optimum};
gof{fitOut.N_optimum};
%fitOut
figure(1);
clf
x=t_fit;%t_fit(optionsIn.skipPoints:end,1);
x=(x-x(optionsIn.skipPoints))*24*60*60;
plot(fCO2{fitOut.N_optimum},x,c_fit) %(optionsIn.skipPoints:end,1))

ax=axis;
v = [0 ax(3);0 ax(4);deadBand ax(4);deadBand ax(3)];
f=[1 2 3 4];
h=patch('Vertices',v,'faces',f,'facecolor','g','edgecolor','none','facealpha',0.2);

v2 = [ax(1) ax(3);ax(1) ax(4);0 ax(4);0 ax(3)];
f2=[1 2 3 4];
h2=patch('Vertices',v2,'faces',f2,'facecolor','y','edgecolor','none','facealpha',0.3);

v3 = [0 max(ax(3),fitOut.c0-10);
      0 min(ax(4),fitOut.c0+10);
      pointsToTest min(ax(4),fitOut.c0+10);
      pointsToTest max(ax(3),fitOut.c0-10)];
f3=[1 2 3 4];
h3=patch('Vertices',v3,'faces',f3,'facecolor','none','edgecolor','#0072BD','facealpha',0.7);


legend('Data','fit','deadband','skipped','t0 search','location','southeast')

%hh=line(x(fitOut.N_optimum+optionsIn.skipPoints),c_fit(fitOut.N_optimum),'marker','o','markersize',10,'color','#D95319','markerfacecolor','#D95319')
hh=line(fitOut.t0,fitOut.c0,'marker','+','markersize',10,'color','#D95319','markerfacecolor','#D95319','linewidth',2);
legend('Data','fit','deadband','skipped','t0 search','t0')




