%
%  del_plt.m
%
% Time series plots of CO2, H2O rho and temperature measured by Solent
% in P.A. 94. This file is used for checking of delay times for each signal
%
%
% (c) Zoran Nesic               File created:       Jan 4, 1995
%                               Last modification:  Jan 4, 1995
%



h =loadzip('sumh_z2');
r =loadzip('sumr_z2');
c =loadzip('sumc_z2');
t =loadzip('sumt_z2');

N =1024;                % number of points to analyze
Fs = 20.83;             % sampling freq.
st=40000;               % starting point
n=(1:N)+st;             % create index
T = (1:N)/Fs;           % Time array (in sec.)

fig1=figure;
plot(T,h(n),'y-',T,r(n),'g-',T,-(c(n)-367),'r-',T,(t(n))/2,'b-');
axis([0 50 4 12])
grid
title('Delay times')
xlabel('Time (s)')
ylabel('y - H (), g - r(), r - c(ppm), b - T(deg.)')
hh=get(get(fig1,'children'),'children');
set(hh(1),'linewidth',1,...
          'linestyle','-'    );
set(hh(2),'linewidth',1,...
          'linestyle','-'    );
set(hh(3),'linewidth',1,...
          'linestyle','-'    );
set(hh(4),'linewidth',2,...
          'linestyle','-'    );
hhy=text(11,11,'Temperature','fontsize',10);          
hhy=text(11,5,'co2','fontsize',10);
hhy=text(41,8.5,'h2o','fontsize',10); 
hhy=text(41,6.8,'rho','fontsize',10);

fig2=figure;
plot(T,h(n),'y-',T,r(n),'g-',T,-(c(n)-369),'r-',T,(t(n)-12),'b-');
axis([4 13 7 10])
grid
title('Delay times')
xlabel('Time (s)')
ylabel('y - H (), g - r(), r - c(ppm), b - T(deg.)')
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
plot(T,h(n),'y-',T,r(n),'g-',T,-(c(n)-369),'r-',T,(t(n)-12),'b-');
%axis([30 40 7 10])
grid
title('Delay times')
xlabel('Time (s)')
ylabel('y - H (), g - r(), r - c(ppm), b - T(deg.)')
hh=get(get(fig3,'children'),'children');
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

