[Stats,HF_data] = yf_calc_module_main(datenum('21-Jul-2004 18:30:00'),'xsite',1);
[cor,lags] = ubc_xcorr(detrend(HF_data.System(1).EngUnits(:,3),0),...
    detrend(HF_data.System(1).EngUnits(:,4),0),500,'coeff');
f = inline('a(1).*exp(-a(2).*x)','a','x');
x = [1:500]';
fit_len = 50;
[param,y_fit] = fr_function_fit(f,[1 20],cor(501:500+fit_len),[],[1:fit_len]');
cor_fit = f(param,x);

plot(lags,cor,x,cor_fit)
disp(['tau = ' num2str(1/param(2))])

for i = 1:50
    fit_len = i*10;
    [param,y_fit] = fr_function_fit(f,[1 20],cor(501:500+fit_len),[],[1:fit_len]');
    tau(i) = 1/param(2);
end

tic;
cor_len = 250;
[cor,lags] = ubc_xcorr(detrend(HF_data.System(1).EngUnits(:,3),0),...
    detrend(HF_data.System(1).EngUnits(:,5),0),cor_len,'coeff');
[cor_max,cor_delay] = max(abs(cor));
for i = 1:cor_len-20-(cor_delay-cor_len)
    fit_len = i+20;
    param(i,:) = linregression([1:fit_len]',log(sign(cor(cor_delay+1:cor_delay+fit_len)).*cor(cor_delay+1:cor_delay+fit_len)));
end

[min_r2,ind_min_r2] = min(param(:,7));
tau = ceil(-1/param(ind_min_r2,1));

N = length(HF_data.System(1).EngUnits(:,3));
wT = detrend(HF_data.System(1).EngUnits(:,3),0).*detrend(HF_data.System(1).EngUnits(:,5),0);
wT_cov = mean(wT);
wT_std = std(wT);
wT_se  = wT_std./sqrt((N/tau));
a = wT_se/wT_cov
toc

subplot(2,1,1)
plot(param(:,8))
subplot(2,1,2)
plot(-1./param(:,1))

zoom_together(gcf,'x','on')

[cor_new,lags] = xcorr(detrend(HF_data.System(1).EngUnits(:,3:6),0),cor_len,'coeff');
cor_new = cor_new(end:-1:cor_len/2);

figure
plot(lags,cor,lags,cor_new,3))

figure
plot(lags,cor_new(end:-1:1,1:5:end))
