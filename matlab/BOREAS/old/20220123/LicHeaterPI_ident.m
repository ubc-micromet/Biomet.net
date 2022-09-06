function LicHeaterPI_ident


jump1=20570;                % time in sec. when step change started
x=load('\\aes_d\d\met-data\log\mc_log990125_theater_const_duty.prn');

t = x(:,1)*3600+x(:,2);             % time in seconds
L = 90;                             % delay time in seconds
Temp1 = 43.7;
Temp2 = 45;
T1 = L;
T2 = 1500;

figure(1)
plot([x(:,1)*3600+x(:,2)]-jump1,x(:,3:5))
line([T1 T2],[Temp1 Temp2])
line([L L],[Temp1-.3 Temp1+.3])
axis([-10 2300 43.5 45])
title('Heater step response (2% up)')
xlabel('Seconds (MC clock)')
ylabel('Deg C, Heater Temp')
R = (Temp2-Temp1)/(T2-T1);
a = R*L;
K = 0.9/a;
Ti = 3*L;
text(1500,44,sprintf('L = %d s',L))
text(1500,43.9,sprintf('R = %4.6f deg/s',R))
text(1500,43.8,sprintf('a = %4.6f deg',a))
text(1000,43.7,sprintf('K = %4.6f , Ti = %4.6f s',K,Ti))

figure(2)
plot([x(:,1)*3600+x(:,2)]-jump1,x(:,3:5))
axis([-10 2300 41.4 41.7])
title('Licor step response (Heat = 2% up)')
xlabel('Seconds (MC clock)')
ylabel('Deg C, Licor Temp')