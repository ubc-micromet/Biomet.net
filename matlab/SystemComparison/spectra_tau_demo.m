function spectra_tau_demo

tau = 1000;

t = 1:2^16;

R_tau = exp(-t./tau);

[Pxx,F] = PSD(R_tau,2^16,1,boxcar(2^16),0);

f = inline('tau(1).*(1/(2*pi*tau(2)))./(f.^2+(1/((2*pi*tau(2)))).^2)','tau','f');
[param,y_fit] = fr_function_fit(f,[10 10],Pxx,[],F);

loglog(F,F.*Pxx,F,F.*y_fit)


figure
for i = 10:10:100
    loglog(F,F.*f([1,i],F))
    hold on
end

[Stats,HF_data] = yf_calc_module_main(datenum('21-Jul-2004 18:30:00'),'xsite',1);
[param,y_fit] = fr_function_fit(f,[10 10],Stats.XSITE_CP.Spectra.Psd(:,3),[],Stats.XSITE_CP.Spectra.Flog);
[maxy,ind] = max(y_fit);

figure
loglog(Stats.XSITE_CP.Spectra.Flog,Stats.XSITE_CP.Spectra.Flog.*Stats.XSITE_CP.Spectra.Psd(:,3),Stats.XSITE_CP.Spectra.Flog,Stats.XSITE_CP.Spectra.Flog.*y_fit)
hold on
line([F(ind),F(ind),[1e-10 1])