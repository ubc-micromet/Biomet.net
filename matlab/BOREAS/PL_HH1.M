function x = pl_hh1(ind);
%ind = 146:147;
nm = 'avg';
%Fnm = 'c:\nz\biomet\boreas\hhour\ubc_hh.';
Fnm = 'l:\met-data\hhour\ubc_hh.';
Page = 2;
Port = 2;
Chan1 = 4;
Chan2 = 3;
[xx,t] = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2,1);
%  Port = 1;
%  xx1 = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2,0);
t = t - 6/24;   % convert GMT to local time
figure(1)
if ( max(ind)-min(ind) )<= 1
    plot(t,xx,'oy',t,xx,'y') % ,t,xx1,'or',t,xx1,'r')
else
    plot(t,xx,'y')           %,t,xx1,'r')
end
grid
title(sprintf('Temperature y - Sol2, r - Sol1: DOY %d:%d',min(ind),max(ind)))
xlabel('DOY')
ylabel('Degree C')

pause
nm = 'avg';
Page = 2;
Port = 2;
Chan1 = 9;
Chan2 = 3;
xx = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
%  Port = 1;
%  xx1 = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
figure(1)
if ( max(ind)-min(ind) )<= 1
    plot(t,xx,'oy',t,xx,'y')             % ,t,xx1,'or',t,xx1,'r')
else
    plot(t,xx,'y')                       % ,t,xx1,'r')
end

grid
title(sprintf('Gauge pressure y - Sol2, r - Sol1: DOY %d:%d',min(ind),max(ind)))
xlabel('DOY')
ylabel('[kPa]')

pause
nm = 'avg';
Page = 2;
Port = 2;
Chan1 = 8;
Chan2 = 3;
xx = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
figure(1)
if ( max(ind)-min(ind) )<= 1
    plot(t,xx,'oy',t,xx,'y')
else
    plot(t,xx)
end
grid
title(sprintf('Barometric pressure: DOY %d:%d',min(ind),max(ind)))
xlabel('DOY')
ylabel('[kPa]')

pause
nm = 'cov';
Page = 2;
Port = 2;
Chan1 = 3;
Chan2 = 4;
xx = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
%  Port = 1;
%  xx1 = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
%  Port = 2;
figure(1)
if ( max(ind)-min(ind) )<= 1
    plot(t,xx,'oy',t,xx,'y')             % ,t,xx1,'or',t,xx1,'r')
else
    plot(t,xx,'y')                       %,t,xx1,'r')
end
grid
title(sprintf('w^T: y - Sol2, r - Sol1  DOY %d:%d',min(ind),max(ind)))
xlabel('DOY')
ylabel('[DegC m/s]')

pause
nm = 'latentLICOR';
xx = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
nm = 'latentKRYPTON';
xx1 = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
figure(1)
if ( max(ind)-min(ind) )<= 1
    plot(t,xx,'oy',t,xx,'y',t,xx1,'or',t,xx1,'r')
else
    plot(t,xx,t,xx1)
end
grid
title(sprintf('SOL2: Latent: y - LICOR, r - KRYPTON: DOY %d:%d',min(ind),max(ind)))
xlabel('DOY')
ylabel('[W/m^2]')

%  Port = 1;
%  pause
%  nm = 'latentLICOR';
%  xx = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
%  nm = 'latentKRYPTON';
%  xx1 = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
%  figure(1)
%  if ( max(ind)-min(ind) )<= 1
%      plot(t,xx,'oy',t,xx,'y',t,xx1,'or',t,xx1,'r')
%  else
%      plot(t,xx,t,xx1)
%  end
%  grid
%  title(sprintf('SOL1: Latent: y - LICOR, r - KRYPTON: DOY %d:%d',min(ind),max(ind)))
%  xlabel('DOY')
%  ylabel('[W/m^2]')

Port = 2;
pause
nm = 'sensible';
xx = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
%  Port = 1;
%  xx1 = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
%  Port = 2;
figure(1)
if ( max(ind)-min(ind) )<= 1
    plot(t,xx,'oy',t,xx,'y')                  % ,t,xx1,'or',t,xx1,'r')
else
    plot(t,xx,'y')                            % ,t,xx1,'r')
end
grid
title(sprintf('Sensible: y - Sol2, r - Sol1  DOY %d:%d',min(ind),max(ind)))
xlabel('DOY')
ylabel('[W/m^2]')

pause
nm = 'cov';
Chan1 = 3;
Chan2 = 5;
xx = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
%  Port = 1;
%  xx1 = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
figure(1)
if ( max(ind)-min(ind) )<= 1
    plot(t,xx,'oy',t,xx,'y')                  % ,t,xx1,'or',t,xx1,'r')
else
    plot(t,xx)                                % ,t,xx1)
end

grid
title(sprintf('w^C y - Sol2, r - Sol1: DOY %d:%d',min(ind),max(ind)))
xlabel('DOY')
ylabel('[g/m^3 * m/s]')
axis([min(t) max(t) -1.5 1.5])

pause
nm = 'avg';
Page = 2;
Port = 2;
Chan1 = 5;
Chan2 = 3;
xx = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
%  Port = 1;
%  xx1 = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
figure(1)
if ( max(ind)-min(ind) )<= 1
    plot(t,xx,'oy',t,xx,'y')               % ,t,xx1,'or',t,xx1,'r')
else
    plot(t,xx,'y')                         % ,t,xx1,'r')
end

grid
title(sprintf('CO2  y - Sol2, r - SOl1: DOY %d:%d',min(ind),max(ind)))
xlabel('DOY')
ylabel('[g/m^3]')

pause
nm = 'avg';
Page = 2;
Port = 2;
Chan1 = 6;
Chan2 = 3;
xx = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
Chan1 = 7;
xx1 = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
figure(1)
if ( max(ind)-min(ind) )<= 1
    plot(t,xx,'oy',t,xx,'y',t,xx1,'or',t,xx1,'r')
else
    plot(t,xx,t,xx1)
end
grid
title(sprintf('Sol2: y - H2O, r - Rho: DOY %d:%d',min(ind),max(ind)))
xlabel('DOY')
ylabel('[g/m^3]')

%  pause
%  nm = 'avg';
%  Page = 2;
%  Port = 1;
%  Chan1 = 6;
%  Chan2 = 3;
%  xx = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
%  Chan1 = 7;
%  xx1 = join_hh(Fnm, nm, ind, Page, Port, Chan1, Chan2);
%  figure(1)
%  if ( max(ind)-min(ind) )<= 1
%      plot(t,xx,'oy',t,xx,'y',t,xx1,'or',t,xx1,'r')
%  else
%      plot(t,xx,t,xx1)
%  end
%  grid
%  title(sprintf('Sol1: y - H2O, r - Rho: DOY %d:%d',min(ind),max(ind)))
%  xlabel('DOY')
%  ylabel('[g/m^3]')


