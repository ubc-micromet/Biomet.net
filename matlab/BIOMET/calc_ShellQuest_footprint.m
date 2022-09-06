%***********************************************************************
%The trees are 25 m tall.
%I would suggest for daytime sensible heat flux (H) of 300 W m-2,
%wind speed (u) of 2.5 m s-1 (ustar = 0.4 m s-1), air temperature (Ta) 23 C and relative humidity (RH) of 50%.
%For nighttime, H = -30 W m-2, u = 0.5 m s-1 (ustar = 0.1 m s-1), Ta = 13 C and RH = 60%.
%My quick rough calculation of L is for daytime -20 and for nighttime 3.
%measurement heights (zm) of 2, 4, 6  and 8 m above the tops of the trees?
%putting the tower on the east side of the southern 'operator select' area.
%assumig preveiling wind direction is 315 degree
%This leaves only about 250 m of fetch

%By Baozhang Chen
%
%May 27, 2009
%***********************************************************************

function calc_ShellQuest_footprint(SiteInfo);

SUMPHI_THRESHOLD = 0.00001; % June 23, 2015 (Nick), used to be 0

%  cd 'D:\Andy_FP';
%  path_out = 'D:\Andy_FP\outputs\';

%universal parameters:
% Definition of the grid over which the footprint phi is going to be  calculated
y_max = 100;  %caution: make sure the x_max, y_max is same as that defined in footprint_kormann_and_meixner
x_max = 100;
pix = 0.5;  %pix= d in footprint_kormann_and_meixner


% Definition of the grid over which the footprint phi is going to be
% calculated
x = [-x_max:pix:x_max];
%y = [0:pix:y_max]; y = y(end:-1:1)';
y = [-y_max:pix:y_max]; y = y(end:-1:1)';

M = length(x);  % pixels in x direction
N = length(y);  % pixels in y direction
x_x = x(ones(1,N),:);
y_y = y(:,ones(1,M));

% Rotate input matrix within a 1.5 times larger matrix. To call this
% function this time is for getting the size of retated matrix in order to
[B,TransferF] = footprint_rotate(x_x,y_y,x_x,0);%   this is the reference point for rotation B(6,6)=99

h_c = SiteInfo.h_c; %0.5, %canopy height in meter, not used--calculate z0 since we have a non-homogeneous pad surface
z_m = SiteInfo.z_m; %1, %EC sensor height in meter
p_bar = SiteInfo.p_bar; % 94, barometric pressure
z_0 = .1*h_c; %10% of h_c
d = 0.67*h_c; % not used below


% daytime
u = SiteInfo.u; %3, in m/s_a
wd = SiteInfo.wd; %25, in degrees, **Note this is a bogus wdir to make the plot work with NS oriented horizontally
T_a = SiteInfo.T_a;%20, air temperature at z_m in oC
RH = SiteInfo.RH; % 50, air relative humidity at z_m in %
H = SiteInfo.H; % 200,  % sensible heat flux in w/m^2
LE = SiteInfo.LE; %75; %latent heat flux in w/m^2

sig_v = 0.2*u;

% % nighttime
% u = 1; %in m/s_a
% wd = 15; %in degree
% T_a = 10; %air temperature at z_m in oC
% RH = 80;  %air relative humidity at z_m in %
% H = -5;  % sensible heat flux in w/m^2
% LE = 0; %latent heat flux in w/m^2
% sig_v = 0.2*u; %first assumption

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Site C parameters %%%%%%%%%%%%%%%%%%%%%
% 
% h_c = 3; %canopy height in meter
% z_m = 6; %EC sensor height in meter
% z_0 = .1*h_c; %10% of h_c
% d = 0.67*h_c;
% p_bar = 98;
% %daytime
% u = 3; %in m/s_a
% wd = 270; %in degree
% T_a = 23; %air temperature at z_m in oC
% RH = 50;  %air relative humidity at z_m in %
% H = 100;  % sensible heat flux in w/m^2
% LE = 400; %latent heat flux in w/m^2
% sig_v = 0.2*u;
% % % nighttime
% % u = 1.5; %in m/s_a
% % wd = 70; %in degree
% % T_a = 13; %air temperature at z_m in oC
% % RH = 80;  %air relative humidity at z_m in %
% % H = -3;  % sensible heat flux in w/m^2
% % LE = 0; %latent heat flux in w/m^2
% % sig_v = 0.1*u; %first assumption
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ust_meas=SiteInfo.uSt;

z = 1; % EC array on tripod at 0.5 m
D = 0;
kVK = 0.4;
wspd=u;
z0_calc=(z_m - D)*exp(-wspd*kVK./ust_meas);

[ust,L] = calc_ustar_L(h_c, z_m, u, T_a, RH, p_bar, H, LE);
% ust = 80/500*u
% L = calc_monin_obhukov_L(ust,T_a,RH,p_bar,H,LE)

% *** use CALCULATED z0 and measured ustar...revisions from Bob's code where he
% set z0=0.1*h_c
z_0=z0_calc;
ust=ust_meas;
[phi,f,D_y,xs,ys,param] = footprint_kormann_and_meixner_bob(z_0,z_m,u,ust,sig_v,L,x_max,y_max,pix);

% cal relative footprint function per pixe
sumphi = sum(abs(phi(:)));  %the following loop is for uniform the whole footprint area equals to 1
if sumphi >= SUMPHI_THRESHOLD
    phi = phi/sumphi;   %relative footprint function; %unit:total=1
end
phi = flipud(phi);

% Rotate the matix of phi using new retating fuction
% with wind direction of alpha_rot_dgr = wd_cur:
alpha_rot_dgr = wd;
% Rotate input matrix within a 1.5 times larger matrix
[phi_rot,TransferF] = footprint_rotate(x_x,y_y,phi,alpha_rot_dgr); % call rotating function: this is the reference point for rotation B(6,6)=99

cumu_phi = footcumsort(phi_rot)*100;
%    save (fullfile (path_out,['Zm=',int2str(z_m), '=', int2str(H)]),'cumu_phi', '-v6');

Ax = TransferF.Ax;
Bx = TransferF.Bx;
x_off = TransferF.x_offset;
[n2,m2] = size(cumu_phi);
x_l = linspace(-pix*(TransferF.Bx+TransferF.x_offset),pix*(TransferF.Bx+TransferF.x_offset),m2);
x_l = x_l(ones(1,n2),:);
y_l = linspace(pix*(TransferF.By+TransferF.y_offset),-pix*(TransferF.By+TransferF.y_offset),n2)';
y_l = y_l(:,ones(1,m2));

%bob_fig_ini(['u=',int2str(u), 'H=', int2str(H)],100/70);
fig=0;
fig=fig+1;
% figure(fig)
% %[Cd,hd] = contour(x_l, y_l, cumu_phi, [50,80,90]);
% %[Cd,hd] = contour(x_l,y_l,filtfilt(fir1(20,1e-2,'low'),1,cumu_phi),[10,20,40,60,70,80,90,95,99]);

% concol=[ 1 0 0; ...
         % 0 1 0; ...
         % 0 0 0];
% [Cd,hd] = contour(x_l+3.6,y_l+27.7,filtfilt(fir1(25,1e-2,'low'),1,cumu_phi),[80,90,99],'linewidth',2,'Linecolor','b');
% %colorbar;
% %clabel(Cd,hd,'manual')
% %xlim([-x_max x_max]);ylim([-y_max y_max])
% ylim([-x_max x_max]);xlim([-y_max y_max])
% clabel(cd,hd,'fontsize',10,'color','r','rotation',0,'FontWeight','Bold')
% hold on
% h=line(0,0,...
    % 'marker','+','markeredgecolor','r','markerfacecolor','r');
% set(1,'name','pcolor','numbertitle','off')
% xlabel('Distance from tower S-N (m)','fontsize',12,'color','k' );
% ylabel('Distance from tower W-E (m)','fontsize',12,'color','k');
% %set(gca,'XTickLabel','');
% %set(gca,'YTickLabel','');
% set(gca,'FontSize',10)
% set(gca,'DefaultTextFontName','Arial')
% %reg_line_str = sprintf('H = %3.3g \nLE = %3.3g',H,LE);
% reg_line_str = sprintf('H = %3.3g \nLE = %3.3g \nT_a = %3.3g \nu = %3.3g \nRH = %3.3g \nz_m = %3.3g \nz_0 = %3.3g \nd = %3.3g',H,LE,T_a,u,RH,z_m,z_0,d);
% text(10,80,reg_line_str);
% %view(-90,90);
% %set(gca,'ydir','rev')
% %    pathfig = [path_out ['Zm=',int2str(z_m), 'H=', int2str(H)]];
% %    print('-depsc',parthfig);
% %    save (path_out,['u=',int2str(u), 'H=', int2str(H)]);
% plot(3.6,27.7,'kx','MarkerSize',18,'LineWidth',3)
% hold off;
% set(gca,'XLim',[0 105])
% set(gca,'YLim',[0 100])

figure(fig);
%+++++++++++++
fig_pos = [200   300   825   791];
mag_coeff = 0.8;
%set(1,'units','pixels','position',[200   300   825   791])
set(1,'units','pixels','position',[200   300   fig_pos(3:4)*mag_coeff])
%SQimg=imread('D:\Shell\release_expt\images\SQ_pad_08-19_1200by900.jpg');
SQimg=imread('D:\SITES\SQM\export\images\SQ_pad_08-19_1200by900.jpg');
%SQimg=imread('D:\Nick\matlab\Shell\release_expt_June2015\SQ_pad_08-19_1200by900.jpg');
%SQimg = flipud(SQimg);
h=image(linspace(0,105,size(SQimg,2)),linspace(100,0,size(SQimg,1)),SQimg);
h_plt1 = gca;
%+++++++++++
%set(h_plt1,'uni','pixel','position',[108 66.  570.  481]);
set(h_plt1,'uni','pixel','position',[108 50  570*mag_coeff  481*mag_coeff]);
set(gca,'ydir','normal')
% h=image(linspace(0,105,size(SQimg,2)),linspace(0,100,size(SQimg,1)),SQimg);
%  ylab=get(gca,'YTickLabel');
%  ylab=flipud(ylab);
%  set(gca,'YTickLabel',ylab);
 %set(h,'alphadata',0.8)

hold on;
phi_rot(find(abs(phi_rot)<10^-5.2))=NaN;
pcolor(x_l+3.6,y_l+27.7,log10(abs(phi_rot))); 
hold off
%pcolor(x_l+3.6,y_l+27.7,cumu_phi);
caxis([-6 -1]);
%caxis([ 0 100]);
hold on;
[Cd,hd] = contour(x_l+3.6,y_l+27.7,filtfilt(fir1(25,1e-2,'low'),1,cumu_phi),[80,90,99],'linewidth',2,'Linecolor','r');
clabel(cd,hd,'fontsize',12,'color','r','rotation',0,'FontWeight','Bold')

colormap jet;
shading flat;
h_colorbar=colorbar;
%h=line(3.6,27.7,'marker','X','markeredgecolor','w','markerfacecolor','w');
xlabel('Distance from tower S-N (m)');
ylabel('Distance from tower W-E (m)');
text(125, 40,'log(\phi)','FontSize',16,'Rotation',90);
plot(3.6,27.7,'kx','MarkerSize',18,'LineWidth',3)
hold off;
set(gca,'XLim',[0 105])
set(gca,'YLim',[0 100])

%reg_line_str = sprintf('H = %3.3g \nLE = %3.3g \nT_a = %3.3g \n u_{*} = %3.3g \n RH = %3.3g \n z_m = %3.3g \n z_0 = %3.3g \nd = %3.3g',H,LE,T_a,ust,RH,z_m,z_0,d);
reg_line_str = sprintf('H = %3.3g \nLE = %3.3g \nT_a = %3.3g \n u_{*} = %3.3g \n RH = %3.3g \n z_m = %3.3g \n z_0 = %3.3g',H,LE,T_a,ust,RH,z_m,z_0);
text(70,75,reg_line_str);
%        %hgsave (fullfile (path_out,[SiteId, yrId '_purefp']), '-v6');
%       %figtitle_yrd = [SiteId, yrId '_purefp'];
%       %pathfig_out_yrd = [path_out figtitle_yrd];
%      % hgsave (pathfig_out_yrd);
%      % print('-djpeg', pathfig_out_yrd);
GMToffset = 6/24; %
Fc = read_bor('\\annex001\DataBase\2015\SQM\Flux_Logger\computed_fluxes\fc_blockavg_rotated_50cm_ep_logger');
u_star = read_bor('\\annex001\DataBase\2015\SQM\Flux_Logger\computed_fluxes\ustar_rotated_50cm_logger');
wind_dir = read_bor('\\annex001\DataBase\2015\SQM\Flux_Logger\computed_fluxes\ustar_rotated_50cm_logger');
tv = read_bor('\\annex001\DataBase\2015\SQM\Flux_Logger\computed_fluxes\timevector',8);
CurrentDate = SiteInfo.tv;

datestr(CurrentDate)
% if floor(CurrentDate) == CurrentDate
%     CurrentDate = CurrentDate-1;
% end
CurrentHHour=CurrentDate;
dv=datevec(CurrentDate-GMToffset);
 if (floor(CurrentDate-GMToffset) < floor(CurrentDate)) | (dv(4)==0. & dv(5)==0.)
     CurrentDate = CurrentDate-1;
 end
ind=find(tv-GMToffset>floor(CurrentDate) & tv-GMToffset<=floor(CurrentDate)+1);
h_plt2 = axes;
%++++++++++
%set(h_plt2,'uni','pixel','position',[108 590  570  160]);
set(h_plt2,'uni','pixel','position',[108 590*mag_coeff  570*mag_coeff  160*mag_coeff]);
plot(tv(ind)-GMToffset,Fc(ind),'o','linewidth',2);
title(sprintf('%s MDT',datestr(CurrentHHour-GMToffset)))
ylabel('F_c (umol m^{-2} s^{-1})')
ax=axis;
%i=find(tv==CurrentDate);
i=find(tv==CurrentHHour);
try
    h_l=line(tv(i)-GMToffset,Fc(i),'marker','o','markersize',6,'linewi',2,'color','red');
    h_l1 = line(tv([i i])-GMToffset,ax(3:4),'color','red','linewidth',2);
catch
end
axis(ax)
datetick('x');
set(gca,'XLim',[tv(ind(1))-0.01-GMToffset tv(ind(end))-GMToffset+0.01]);

