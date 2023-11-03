fid = fopen('D:\NZ\Flux_Projects\FeeForService\Wilfrid.Laurier\data\sapflow\OBS_sap_exmpl.csv');
if fid > 0
    c_OBS = textscan(fid,'%s%s%f%f%f%f%f','headerlines',1,'delimiter',',');
end
fclose all;
 
%%
tv_OBS = datenum(c_OBS{2});
minutesIn_OBS = (tv_OBS - datenum(2018,1,0));
SF_OBS = c_OBS{[3]};
SF_OBS(:,2) = c_OBS{[4]};
SF_OBS(:,3) = c_OBS{[5]};
SF_OBS(:,4) = c_OBS{[6]};
SF_OBS(:,5) = c_OBS{[7]};

%% 
% This is good data from OBS. Plot as an example
figure(1)
clf

plot(minutesIn_OBS,SF_OBS);
title('OBS site:  SF')
ylabel('mV')
grid on


%% Now load bad data 
%
fid = fopen('D:\NZ\Flux_Projects\FeeForService\Wilfrid.Laurier\data\sapflow\SMC_sap_exmpl.csv');
if fid > 0
    c_SMC = textscan(fid,'%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','headerlines',1,'delimiter',',','TreatAsEmpty','NA');
end
fclose all;
fid = fopen('D:\NZ\Flux_Projects\FeeForService\Wilfrid.Laurier\data\sapflow\SMC_batt_volt_exmpl.csv');
if fid > 0
    cv_SMC = textscan(fid,'%s%f','headerlines',1,'delimiter',',','TreatAsEmpty','NA');
end
fclose all;
%%
tv_SMC = datenum(c_SMC{1});
minutesIn_SMC = (tv_SMC - datenum(2018,1,0));
SF_SMC = c_SMC{[2]};
for cnt = 2:15
    SF_SMC(:,cnt) = c_SMC{[1+cnt]};
end
v_SMC = cv_SMC{2};

%% save data for future use:
save('D:\NZ\Flux_Projects\FeeForService\Wilfrid.Laurier\data\sapflow\OBS_sap_exmpl_data_set.mat');

%%

figure(2)
hAX(1) = subplot(2,1,1);
plot(minutesIn_SMC,SF_SMC); grid on;
title('SF')
ylabel('mV')
legend
hAX(2) = subplot(2,1,2);
plot(minutesIn_SMC,v_SMC,'o-'); grid on;
linkaxes(hAX,'x')
title('Voltage')
ylabel('V')
%%
figure(3)
k=1;
hAX(1) = subplot(2,2,1);
plot(minutesIn_SMC,SF_SMC(:,k)); grid on;
title(sprintf('SF - trace #%d',k))
ylabel('mV')
hAX(2) = subplot(2,2,2);
plot(minutesIn_SMC,v_SMC,'o-'); grid on;
linkaxes(hAX,'x')
title('Voltage')
ylabel('V')

subplot(2,2,3);
plot(v_SMC,SF_SMC(:,k),'.'); grid on;
linkaxes(hAX,'x')
xlabel('Voltage')
ylabel('SF (mV)')
%%
figure(100)
for shift1=0:10
    indCheck = [1:1440]+180+1440*shift1;
    figure(13)
    clf
    plot(minutesIn_SMC(indCheck),SF_SMC(indCheck,k),minutesIn_SMC(indCheck),SF_SMC(indCheck,k)-(0.687 - 0.66)/(13.58-13.3)*(13.58-v_SMC(indCheck))); grid on;   
    legend('Original','Corrected')
    figure(14)
    clf
    plot(v_SMC(indCheck),SF_SMC(indCheck,k),'-o'); grid on;
    xlabel('Voltage')
    ylabel('SF (mV)')
    title(sprintf('From %s to %s',datestr(tv_SMC(indCheck(1))),datestr(tv_SMC(indCheck(end)))))
    pause
end

%% Fitting voltage induced temperature signals
%  - First remove delay times (if any)
%  - Fit the polynomials for the short periods of time where there is large
%    voltage variation (assume small changes in sapflux during that time)
%  - fit linear and quadratic functions
periodToFit = [datenum(2018,1,178.8) datenum(2018,1,178.9)];
indToFit = find(tv_SMC >= periodToFit(1) & tv_SMC <= periodToFit(2));
figure(4)
subplot(1,2,1)
plot(tv_SMC(indToFit),detrend(SF_SMC(indToFit,1)),tv_SMC(indToFit),detrend(v_SMC(indToFit))/5)
grid
legend('SF_1','V')
subplot(1,2,2)
plot((v_SMC(indToFit))-13,detrend(SF_SMC(indToFit,1)),'.')
grid
%%
p = polyfit(detrend(v_SMC(indToFit),0),detrend(SF_SMC(indToFit,1),0),1);

figure(5)
k=1;
plot(tv_SMC,SF_SMC(:,k),tv_SMC,SF_SMC(:,k)-polyval(p,v_SMC-mean(v_SMC(indToFit))))
legend('Original','Corrected')
return
