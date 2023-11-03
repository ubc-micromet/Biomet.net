%% testing the confidence intervals
%dcdt = -A(cs-c0)
load 20190719_recalcs_UdeM
ch_num = 9;
hour_num = 24;
for ch_num=1:18
    dcdt_cint = [];
    rmse_exp = [];
    for hour_num = 1:24
        N_optimum = fitOut{hour_num,ch_num}.N_optimum;
        xx=fCO2{hour_num,ch_num}{N_optimum};
        cint_xx = confint(xx,0.95);
        dcdt_cint(hour_num,1) = -cint_xx(2,1)*(cint_xx(1,2)-xx.c0);
        dcdt_cint(hour_num,2) = -xx.A*(xx.cs-xx.c0);
        dcdt_cint(hour_num,3) = -cint_xx(1,1)*(cint_xx(2,2)-xx.c0);
        rmse_exp(hour_num) = fitOut{hour_num,ch_num}.rmse;
    end
    figure(11)
    subplot(2,1,1)
    plot(dcdt_cint,'linewidth',2)
    axis([0 25 -2 2])
    grid
    title(sprintf('%d',ch_num))
    ylabel('dcdt')
    legend('min','avg','max')
    subplot(2,1,2)
    plot(rmse_exp,'linewidth',2)
    grid
    ylabel('rmse')
    pause
end

 