function footprint_VI_sites
% footprint_VI_sites 
%
% Application of the footprint model by Kormann & Meixner for the VI sites.

footprint_one_VI_site('CR');
print('-deps', 'd:\kai\current\footprint_CR');

footprint_one_VI_site('OY');
print('-deps', 'd:\kai\current\footprint_OY');

footprint_one_VI_site('YF');
print('-deps', 'd:\kai\current\footprint_YF');


function footprint_one_VI_site(SiteId)

%SiteIds = {'CR','YF','OY'};
arg_default('SiteId','CR')
disp('Footprint estimates according to Kormann & Meixner ');

switch upper(SiteId)
    case 'OY'
        [sig_v,tv] = read_db(2004,SiteId,'flux\clean','wind_speed_v_std_before_rot_sonic_pc');
        z_m = 3;
        z_0 = 0.3;
        d = 0.7*0.7;
    case 'YF'
        [sig_v,tv] = read_db(2004,SiteId,'flux\clean','wind_speed_v_std_before_rot_gill');
        z_m = 12;
        z_0 = 1;
        d = 4.5;
    case 'CR'
        [sig_v,tv] = read_db(2004,SiteId,'flux\clean','wind_speed_v_std_before_rot_gill');
        z_m = 43;
        d = 0.7*35;
        z_0 = 3;
        z_m = 42.74; d = 20.55; % secondstage stage values used in zeta calc
end
z_m = z_m-d;
[ust,tv]    = read_db(2004,SiteId,'clean\secondstage','ustar_main');
[u,tv]      = read_db(2004,SiteId,'clean\secondstage','wind_speed_cup_main');
[wd,tv]     = read_db(2004,SiteId,'clean\secondstage','wind_direction_main');
[zeta,tv]   = read_db(2004,SiteId,'clean\secondstage','zeta');
L = z_m./zeta;

% Input parameters
dv = datevec(tv-8/24);
ind_day = find(dv(:,2) == 7 & dv(:,4)>11 & dv(:,4)<14 & ~isnan(sig_v));
ind_nig = find(dv(:,2) == 7 & (dv(:,4)>23 | dv(:,4)<2) & ~isnan(sig_v));    
ust_median   = [nanmedian(ust(ind_day)) nanmedian(ust(ind_nig))];
L_median     = [nanmedian(L(ind_day)) nanmedian(L(ind_nig))];
sig_v_median = [nanmedian(sig_v(ind_day)) nanmedian(sig_v(ind_nig))];
u_median     = [nanmedian(u(ind_day)) nanmedian(u(ind_nig))];

wd_median    = [nanmedian(wd(ind_day)) nanmedian(wd(ind_nig))];

disp('');
disp(SiteId);
disp(['z_m   ' num2str(z_m,' %5.2f')]);
disp(['z_0   ' num2str(z_0,' %5.2f')]);
disp(['sig_v ' num2str(sig_v_median,' %5.2f')]);
disp(['L     ' num2str(L_median,' %5.2f')]);
disp(['u     ' num2str(u_median,' %5.2f')]);

disp(['sig_v/z_m   ' num2str(sig_v_median./z_m,' %5.2f')]);
disp(['z_0/z_m     ' num2str(z_0./z_m,' %5.2f')]);
disp(['z_m/L       ' num2str(z_m./L_median,' %5.2f')]);
disp(['u/z_m       ' num2str(u_median./z_m,' %5.2f')]);

% Footprint estimate
s = warning; warning off;
[phi_day,f_day,D_y_day,x,y,p_day] = footprint_kormann_and_meixner(z_0,z_m,u_median(1),sig_v_median(1),L_median(1));
[phi_nig,f_nig,D_y_nig,x,y,p_nig] = footprint_kormann_and_meixner(z_0,z_m,u_median(2),sig_v_median(2),L_median(2));
warning(s);

x_x = x' * ones(1,length(y));
y_y = ones(length(x),1) * y;

[dum,ind_m_day] = max(phi_day(:));
[dum,ind_m_nig] = max(phi_nig(:));
disp(['x_max ' num2str(x_x([ind_m_day ind_m_nig]),' %5.2f')]);


% Adjust for wind direction
[thet_day,rho_day,z_day] = cart2pol(x_x(:),y_y(:),phi_day(:));
thet_day = thet_day + (360-wd_median(1))*(2*pi)/360;
[x_x_rot_day,y_y_rot_day,phi_rot_day] = pol2cart(thet_day,rho_day,z_day);

x_x_rot_day = reshape(x_x_rot_day,200,160);
y_y_rot_day = reshape(y_y_rot_day,200,160);
phi_rot_day = reshape(phi_rot_day,200,160);

[dum,ind_s_day] = sort(phi_rot_day(:));
cphi_day = cumsum(phi_rot_day(ind_s_day));

level_day = zeros(size(phi_day));
level_day(ind_s_day) = cphi_day;

[thet_nig,rho_nig,z_nig] = cart2pol(x_x(:),y_y(:),phi_nig(:));
thet_nig = thet_nig + (360-wd_median(2))*(2*pi)/360;
[x_x_rot_nig,y_y_rot_nig,phi_rot_nig] = pol2cart(thet_nig,rho_nig,z_nig);

x_x_rot_nig = reshape(x_x_rot_nig,200,160);
y_y_rot_nig = reshape(y_y_rot_nig,200,160);
phi_rot_nig = reshape(phi_rot_nig,200,160);

[dum,ind_s_nig] = sort(phi_rot_nig(:));
cphi_nig = cumsum(phi_rot_nig(ind_s_nig));

level_nig = zeros(size(phi_nig));
level_nig(ind_s_nig) = cphi_nig;

figure('Name',['Footprint ' SiteId],'Units','centimeter','Position',[3 3 15 15]) % Make plot square no dimension is stretched
axes('Units','centimeter','Position',[1.5 1.5 12 12]) % Make plot square no dimension is stretched

[Cd,hd] = contour(x_x_rot_day,y_y_rot_day,level_day,[0.1 0.1],'k-');
set(hd,'LineWidth',2)
line(x_x_rot_day(ind_m_day),y_y_rot_day(ind_m_day),... % x_max
        'Color','k','LineStyle','none','Marker','o','MarkerFaceColor','k');
hold on
[Cn,hn] = contour(x_x_rot_nig,y_y_rot_nig,level_nig,[0.1 0.1],'k-');
set(hn,'LineWidth',3)
line(x_x_rot_nig(ind_m_nig),y_y_rot_nig(ind_m_nig),... % x_max
        'Color','k','LineStyle','none','Marker','o','MarkerFaceColor','k');

line(0,0,'Color','k','Marker','+','MarkerSize',10); % Tower location
% Polar Grid
line([-1000 1000],[0 0],'Color','k','LineStyle',':'); % Tower location
line([0 0],[-1000 1000],'Color','k','LineStyle',':'); % Tower location
line([-1000 1000],[-1000 1000],'Color','k','LineStyle',':'); % Tower location
line([-1000 1000],[1000 -1000],'Color','k','LineStyle',':'); % Tower location
for i = 200:200:1000
    [x,y] = pol2cart([0:360].*2.*pi/360,i.*ones(1,361));
    line(x,y,'Color','k','LineStyle',':'); % Tower location
end

axis([-1000 1000 -1000 1000])
view(-90,90) % Point x-axis up
text(950,0,'N','VerticalA','middle','HorizontalA','center') % Mark North

hold off;