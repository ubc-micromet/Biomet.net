
tv_exp = datenum(2005,7,21:now);

if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,'ON_TP','Setup_XSITE'));
end
Stats_xsite = fcrn_load_data(tv_exp);

tv_xsite    = get_stats_field(Stats_all,'TimeVector');

pth_opec = 'D:\kai_data\Projects_data\XSITE\Experiments\ON_TP\met-data\OPEC';
[x,Header,tv] = fcrn_read_csi_ascii(fullfile(pth_opec,'flux050629_050717m1.DAT'),1,4);

% for i = 1: length(Header.var_names')
%     disp([num2str(i) ' ' char(Header.var_names(i))]); 
% end
% 
% 2 Fc_wpl
% 3 LE_wpl
% 4 Hs
% 5 H
% 6 tau
% 7 u_star
% 8 cov_Uz_Uz

[tv_dum,ind_xsite,ind] = intersect(tv_xsite-4/24,tv);

Fc_xsite    = Fc_xsite(ind_xsite);
LE_xsite    = LE_xsite(ind_xsite)
Hs_xsite    = Hs_xsite(ind_xsite)
Us_xsite    = Us_xsite(ind_xsite)
std_w_xsite = std_w_xsite(ind_xsite)

Fc = x(ind,2);
LE = x(ind,3); 
Hs = x(ind,4);
Us = x(ind,7);
std_w = sqrt(x(:,8));

figure('Name','Fc');
plot_regression(Fc_xsite,Fc,[],[],'orthogonal');

figure('Name','LE');
plot_regression(LE_xsite,LE,[],[],'orthogonal');

figure('Name','Hs');
plot_regression(Hs_xsite,Hs,[],[],'orthogonal');

figure('Name','ustar');
plot_regression(Us_xsite,Us,[],[],'orthogonal');

figure('Name','std_w');
plot_regression(std_w_xsite,std_w,[],[],'orthogonal');

