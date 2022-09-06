SiteID = 'BS';
ext = '.rb.mat';

%x1 = load (['D:\david_data\2002\' SiteID '\chambers\slope_min\hhour\020427' ext]);
%x2 = load (['D:\david_data\2002\' SiteID '\chambers\slope_min\hhour\old\020427' ext]);
%x3 = load (['D:\david_data\2002\' SiteID '\chambers\slope_all\hhour\020910' ext]);
%x4 = load (['D:\david_data\2002\' SiteID '\chambers\slope_all\hhour\old\020910' ext]);

x3 = load (['D:\met-data\hhour\040704' ext]);
x4 = load (['\\paoa001\SITES\Paob\HHour\040704s.hb.mat']);

%dcdt1 = x1.chOut.Fluxes_Stats.dcdt(:,1);
%dcdt2 = x2.chOut.Fluxes_Stats.dcdt(:,1);
flux3 = x3.stats.Chambers.Fluxes_Stats.fluxOutShort.flux(:,8);
flux4 = x4.stats.Chambers.Fluxes_Stats.fluxOut.flux(:,8);
%dcdt2 = x2.stats.Chambers.Fluxes_Stats.dcdt(:,1);

if 1==0
%flux1 = x1.chOut.Fluxes_Stats.fluxes(:,1);
%flux2 = x2.chOut.Fluxes_Stats.fluxes(:,1);
flux3 = x3.chOut.Fluxes_Stats.fluxes(:,1);
flux4 = x4.chOut.Fluxes_Stats.fluxes(:,1);
%flux2 = x2.stats.Chambers.Fluxes_Stats.fluxes(:,1);

%ev1 = x1.chOut.Fluxes_Stats.ev(:,1);
%ev2 = x2.chOut.Fluxes_Stats.ev(:,1);
ev3 = x3.chOut.Fluxes_Stats.ev(:,1);
ev4 = x4.chOut.Fluxes_Stats.ev(:,1);
%ev2 = x2.stats.Chambers.Fluxes_Stats.ev(:,1);

%r1 = x1.chOut.Fluxes_Stats.rsquare(:,1);
%r2 = x2.chOut.Fluxes_Stats.rsquare(:,1);
r3 = x3.chOut.Fluxes_Stats.rsquare(:,1);
r4 = x4.chOut.Fluxes_Stats.rsquare(:,1);
%r2 = x2.stats.Chambers.Fluxes_Stats.rsquare(:,1);

figure(1);
plot(dcdt3);
title('dcdt new');

figure(2);
plot(dcdt4);
title('dcdt old');

figure(3);
plot([dcdt3 dcdt4]);
legend('new','old');
title('dcdt');
zoom on;
end

figure(4);
plot([flux3 flux4]);
legend('new','old');
title('flux');
zoom on;

if 1==0
figure(5);
plot([ev3 ev4]);
legend('new','old');
title('ev');
zoom on;

figure(6);
plot([r3 r4]);
legend('new','old');
title('r2');
zoom on;

if 1==0
figure(7);
plot([dcdt1 dcdt3]);
legend('new 1 min','new 3 min');
title('dcdt');
zoom on;

figure(8);
plot([flux1 flux3]);
legend('new 1 min','new 3 min');
title('flux');
zoom on;

figure(9);
plot([ev1 ev3]);
legend('new 1 min','new 3 min');
title('ev');
zoom on;

figure(10);
plot([r1 r3]);
legend('new 1 min','new 3 min');
title('r2');
zoom on;

end
end
