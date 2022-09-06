function footprint_kormann_and_meixner_verification
% footprint_kormann_and_meixner_verification
%
% This function calculates the test cases given in Kormann and Meixner
% (2001), section 5. An Example (p.220). Is uses the function 
% footprint_kormann_and_meixner and demonstrates that it accurately
% reproduces the results of that paper

% All three test cases in Kormann & Meixner use
% z_0/z_m = 0.01, sig_v/z_m = 0.1 Hz and u/z_m = 0.5 Hz
% which we implement using
z_0 = 0.1; z_m = 10; sig_v = 1; u = 5;
% stable case z_m/L = 1
L = 10;
[phi_s,f_s,D_y_s,x,y,p_s] = footprint_kormann_and_meixner(z_0,z_m,u,sig_v,L);
% Neutral case z_m/L = 0
L = 1e6;
[phi_n,f_n,D_y_n,x,y,p_n] = footprint_kormann_and_meixner(z_0,z_m,u,sig_v,L);
% stable case z_m/L = -1
L = -10;
[phi_u,f_u,D_y_u,x,y,p_u] = footprint_kormann_and_meixner(z_0,z_m,u,sig_v,L);

disp('Basic parameters for test cases:');
disp( '      stable    neutral     unstable');
disp(['m     ' num2str(p_s.m,'%3.2f') '      ' num2str(p_n.m,'%3.2f') '        ' num2str(p_u.m,'%3.2f') ]); 
disp(['xsi   ' num2str(p_s.xsi,'%3.1f') '     ' num2str(p_n.xsi,'%3.1f') '       ' num2str(p_u.xsi,'%3.1f') ]); 
[dum,ind_s] = max(f_s(:,1)); [dum,ind_n] = max(f_n(:,1)); [dum,ind_u] = max(f_u(:,1));
disp(['x_max ' num2str(x(ind_s),'%3.0f') '       ' num2str(x(ind_n),'%3.0f') '           ' num2str(x(ind_u),'%3.0f') ]); 

x_x = x' * ones(1,length(y));
y_y = ones(length(x),1) * y;

[dum,ind_s] = max(phi_s(:)); [dum,ind_n] = max(phi_n(:)); [dum,ind_u] = max(phi_u(:));

kais_fig_ini('Korman and Meixner Fig 4 b',100/80);
axes('Units','centimeter','Position',[2 2 [10 8]*1.2])
contour(x_x./z_m,y_y./z_m,phi_s./max(phi_s(:)),[0.1 0.01 0.001],'k--');
hold on;
contour(x_x./z_m,y_y./z_m,phi_n./max(phi_n(:)),[0.1 0.01 0.001],'k-');
contour(x_x./z_m,y_y./z_m,phi_u./max(phi_u(:)),[0.1 0.01 0.001],'k:');

line([x_x(ind_s),x_x(ind_n),x_x(ind_u)]./z_m,[0 0 0],...
    'Color','k','LineStyle','none','Marker','o','MarkerFaceColor','k');
xlabel('x/z_m'); ylabel('y/z_m');

print -deps 'd:\kai\current\Kormann_and_Meixner_Fig4b'

[dum,ind_s_n] = sort(phi_n(:));
cphi_n = cumsum(phi_n(ind_s_n));

level_n = zeros(size(phi_n));
level_n(ind_s_n) = cphi_n;

kais_fig_ini('Comparion phi/phi_max and Pi',100/80);
axes('Units','centimeter','Position',[2 2 [10 8]*1.2])

contour(x_x./z_m,y_y./z_m,phi_n./max(phi_n(:)),[0.1 0.1],'k-');
hold on
contour(x_x./z_m,y_y./z_m,level_n,[0.1 0.1],'k:');
line([x_x(ind_n),]./z_m,[0],...
    'Color','k','LineStyle','none','Marker','o','MarkerFaceColor','k');
xlabel('x/z_m'); ylabel('y/z_m');

print -deps 'd:\kai\current\Comparion_phi_phi_max_and_Pi'

return