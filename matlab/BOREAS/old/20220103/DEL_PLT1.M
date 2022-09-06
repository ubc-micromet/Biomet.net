%
%  del_plt1.m
%
% Time series plots of CO2, H2O rho and temperature measured by Solent
% in P.A. 94. This file is used for checking of delay times for each signal
%
%
% (c) Zoran Nesic               File created:       Jan 4, 1995
%                               Last modification:  Jan 5, 1995
%



h =loadzip('sumh_z1');
r =loadzip('sumr_z1');
c =loadzip('sumc_z1');
t =loadzip('sumt_z1');

N =1024;                % number of points to analyze
Fs = 20.83;             % sampling freq.
st=40000;               % starting point
n=(1:N)+st;             % create index
T = (1:N)/Fs;           % Time array (in sec.)

fig1=figure;
plot(T,h(n),'y-',T,r(n),'g-',T,-(c(n)-367),'r-',T,(t(n)-mean(t(n)))*8+12,'b-');
axis([0 50 10 20])
grid
title('Delay times')
xlabel('Time (s)')
ylabel('y - H (), g - r(), r - c(ppm), b - (T-Tmean)*8(deg.^8)')
hh=get(get(fig1,'children'),'children');
set(hh(1),'linewidth',1,...
          'linestyle','-'    );
set(hh(2),'linewidth',1,...
          'linestyle','-'    );
set(hh(3),'linewidth',1,...
          'linestyle','-'    );
set(hh(4),'linewidth',2,...
          'linestyle','-'    );
hhy=text(11.5,12.2,'Temperature','fontsize',10);          
hhy=text(21,15.5,'co2','fontsize',10);
hhy=text(9.2,18.2,'h2o','fontsize',10); 
hhy=text(11,14.2,'rho','fontsize',10);

fig2=figure;
plot(T,h(n),'y-',T,r(n),'g-',T,-(c(n)-369),'r-',T,(t(n)-mean(t(n)))*8+12,'b-');
axis([0 10 10 20])
grid
title('Delay times')
xlabel('Time (s)')
ylabel('y - H (), g - r(), r - c(ppm), b - (T-Tmean)*8(deg.^8)')
hh=get(get(fig2,'children'),'children');
set(hh(1),'linewidth',.5,...
          'linestyle','-'    );
set(hh(2),'linewidth',1,...
          'linestyle','-'    );
set(hh(3),'linewidth',1.5,...
          'linestyle','-'    );
set(hh(4),'linewidth',2,...
          'linestyle','-'    );
%hhy=text(4.2,11,'Temperature','fontsize',10);          
%hhy=text(4.2,5,'co2','fontsize',10);
%hhy=text(4.2,8.5,'h2o','fontsize',10); 
%hhy=text(4.2,6.8,'rho','fontsize',10);

fig3=figure;
plot(T,h(n),'y-',T,r(n),'g-',T,-(c(n)-369),'r-',T,(t(n)-mean(t(n)))*8+12,'b-');
axis([30 50 10 20])
grid
title('Delay times')
xlabel('Time (s)')
ylabel('y - H (), g - r(), r - c(ppm), b - (T-Tmean)*8(deg.^8)')
hh=get(get(fig3,'children'),'children');
set(hh(1),'linewidth',.5,...
          'linestyle','-'    );
set(hh(2),'linewidth',1,...
          'linestyle','-'    );
set(hh(3),'linewidth',1.5,...
          'linestyle','-'    );
set(hh(4),'linewidth',2,...
          'linestyle','-'    );
%hhy=text(19.2,7,'Temperature','fontsize',10);          
%hhy=text(16.5,7,'co2','fontsize',10);
%hhy=text(15.5,11,'h2o','fontsize',10); 
%hhy=text(14.2,11,'rho','fontsize',10);
tile
