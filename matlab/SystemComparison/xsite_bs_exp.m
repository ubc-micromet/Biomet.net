function xsite_bs_exp(currentDate)

%currentDate = datenum(2004,5,16)+80/96;
%currentDate = datenum(2004,5,18)+84/96;

oldPath = pwd;

tv = linspace(0,1800,36000);

cd C:\UBC_PC_Setup\Site_specific\BS_new_eddy
[Stats_bs,HF_bs] = yf_calc_module_main(currentDate,'BS',1);
    
tv_bs = [1:length(HF_bs.System(1).EngUnits(:,4))]./20.83;
EngUnits_bs = interp1(linspace(0,1800,length(tv_bs)),HF_bs.System(1).EngUnits,tv);

wTa_bs  = (detrend(EngUnits_bs(:,4),0) .* detrend(EngUnits_bs(:,3),0));
wTc1_bs = (detrend(EngUnits_bs(:,7),0) .* detrend(EngUnits_bs(:,3),0));
wTc2_bs = (detrend(EngUnits_bs(:,8),0) .* detrend(EngUnits_bs(:,3),0));
w_bs    = detrend(EngUnits_bs(:,3),0);
T_bs    = detrend(EngUnits_bs(:,4),0);
cup_bs  = sqrt(sum(EngUnits_bs(:,1:2).^2,2));

dir_bs_mean = FR_Sonic_wind_direction(mean(EngUnits_bs)','Gillr3')';

dir_bs  = FR_Sonic_wind_direction(EngUnits_bs','Gillr3')';

cd C:\UBC_PC_Setup\Site_specific\XSITE
% HF_xs = fr_read_raw(datenum(2004,5,16)+80/96,'xsite');
[Stats_xs,HF_xs] = yf_calc_module_main(currentDate,'xsite',1);
tv_xs = [1:length(HF_xs.System(1).EngUnits(:,4))]./20;

EngUnits_xs = interp1(linspace(0,1800,length(tv_xs)),HF_xs.System(1).EngUnits,tv);

wTa_xs  = (detrend(EngUnits_xs(:,4),0) .* detrend(EngUnits_xs(:,3),0));
w_xs    = detrend(EngUnits_xs(:,3),0);
T_xs    = detrend(EngUnits_xs(:,4),0);
cup_xs  = sqrt(sum(EngUnits_xs(:,1:2).^2));

dir_xs_mean  = FR_Sonic_wind_direction(mean(EngUnits_xs)','Gillr3')';

dir_xs  = FR_Sonic_wind_direction(EngUnits_xs','Gillr3')' - dir_xs_mean+dir_bs_mean;

dwT_eq = cumsum(sum(wTa_bs-wTa_xs)./length(wTa_xs).*ones(length(wTa_xs),1));

[dir,ind_bs] = sort(dir_bs);
[dir,ind_xs] = sort(dir_xs);
[dir,ind_w_bs] = sort(w_bs);
[dir,ind_w_xs] = sort(w_xs);
[dir,ind_T_bs] = sort(T_bs);
[dir,ind_T_xs] = sort(T_xs);

figure
nn1 = hist_weighted(dir_bs,cup_bs,0:360);
nn2 = hist(dir_bs,0:360)';
plot(0:360,[nn1 nn2])
legend('weighted','original')
xlabel('Direction')
ylabel('No of obs.')
%hist([dir_bs,dir_xs],0:360)

figure
plot(dir_bs(ind_bs),cumsum(wTa_bs(ind_bs)),dir_xs(ind_xs),cumsum(wTa_xs(ind_xs)))
legend('BS','XSITE')
xlabel('Direction')
ylabel('Cumulative cov')

figure
plot(dir_bs(ind_bs),cumsum(wTa_bs(ind_bs)-wTa_xs(ind_xs)))
hold on;
plot(dir_bs(ind_bs),dwT_eq,'r','linewidth',2)
legend('measured','equal contribution')
xlabel('Direction')
ylabel('Cumulative diff. in cov')

figure
[Nb,ind_bsz]=histc(dir_bs,0:360);
[Nx,ind_xsz]=histc(dir_xs,0:360);
x=NaN*ones(size(Nb));
for i=1:length(Nb);
    ind1= find(ind_bsz==i);
    ind2= find(ind_xsz==i);
    x(i)=sum(wTa_bs(ind1))-sum(wTa_xs(ind2));
end
plot(0:360,x)
xlabel('Direction')
ylabel('Diff. in cov')

figure
plot(cumsum(x))
xlabel('Direction')
ylabel('Diff. in cov cumsum')

figure
plot(cumsum(x)./cumsum(Nb))
xlabel('Direction')
ylabel('Diff. in cov cumsum normalized')

figure
Nb1 = Nb;
ind = find(Nb1<100);
Nb1(ind) = NaN;        % remove these points
plot(0:360,x./Nb1)
xlabel('Direction')
ylabel('Diff. in cov histogram normalized')


return

figure
plot(w_bs(ind_w_bs),cumsum(wTa_bs(ind_w_bs)-wTa_xs(ind_w_xs)))
hold on;
plot(w_bs(ind_w_bs),dwT_eq,'r','linewidth',2)

figure
plot(T_bs(ind_T_bs),cumsum(wTa_bs(ind_T_bs)-wTa_xs(ind_T_xs)))
hold on;
plot(T_bs(ind_T_bs),dwT_eq,'r','linewidth',2)

cd(oldPath)

return
