function Stats_time_scale = fcrn_turbulent_timescale_w(EngUnits)

cor_len = 500;

[cor34,lags] = xcov(EngUnits(:,[3 4]),cor_len,'coeff');
[cor35,lags] = xcov(EngUnits(:,[3 5]),cor_len,'coeff');
[cor36,lags] = xcov(EngUnits(:,[3 6]),cor_len,'coeff');
cor = [cor34(:,[1:3]),cor35(:,[2 3]),cor36(:,[2 3])];

% From xcov help:
% The cross-covariance is the cross-correlation function of
% two sequences with their means removed:
%     C(m) = E[(A(n+m)-MA)*conj(B(n)-MB)] 
% where MA and MB are the means of A and B respectively.
% 
% Here we only look at negative delays, i.e. the first variable (w) is
% always assumed to be 'leading'.
cor = cor(cor_len+1:-1:1,:);
lags = lags(cor_len+1:end);

[cor_max,cor_delay]   = max(abs(cor));
[cor_min,cor_min_pos] = min(abs(cor));

min_reg = 20;
for k = 1:7
    for i = 1:cor_len-min_reg-cor_delay(k)
        fit_len = i+min_reg;
        ind_fit = cor_delay(k):cor_delay(k)+fit_len-1;
        param(i,:) = linregression([1:fit_len]',log(sign(cor(ind_fit,k)).*cor(ind_fit,k)));
    end
    [r2_max(k),ind_r2_max(k)] = max(abs(param(:,8)));
    tau(k) = ceil(-1/param(ind_r2_max(k),1));
    std_mat(k) = std(detrend(EngUnits(:,ceil(k/4)),0).*detrend(EngUnits(:,rem(k-1,4)+1),0));
end

Stats_time_scale.tau         = tau;
Stats_time_scale.r2_max      = r2_max;
Stats_time_scale.ind_r2_max  = ind_r2_max+min_reg;
Stats_time_scale.cor_min     = cor_min;
Stats_time_scale.cor_min_pos = cor_min_pos;
Stats_time_scale.std_mat     = std_mat;
