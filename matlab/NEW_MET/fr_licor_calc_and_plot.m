function [co2,h2o,Tbench,Plicor] = fr_licor_calc_and_plot(LicNum,k,dateIn,num_of_samples,CO2_cal,H2O_cal)


if exist('CalDate')~=1 | isempty(CalDate)
   CalDate = 'new';
end
if exist('dateIn')~=1 | isempty(dateIn)
   dateIn = now;
end
if exist('num_of_samples')~=1 | isempty(num_of_samples)
   num_of_samples = 50000;
end
if exist('CO2_cal')~=1 | isempty(CO2_cal)
   CO2_cal = [1 0];
end
if exist('H2O_cal')~=1 | isempty(H2O_cal)
   H2O_cal = [1 0];
end

[g,d,gr,dr]=fr_plt_now(8,num_of_samples,2,dateIn);
x=(dr(k,:)*5000/2^15)';
[co2,h2o,Tbench,Plicor]= fr_licor_calc(LicNum,[],x(:,1),x(:,2),x(:,3),x(:,4));

t = [1:length(co2)]/20.83;
figure(1)
set(1,'defaultaxesfontsize',8)
clf
h=subplot(4,1,1);
plot(t,co2)
ylabel('CO_2 [ppm]')
set(h,'xticklabels','')
h=subplot(4,1,2);
plot(t,h2o)
ylabel('H_2O [mmol mol^{-1}]')
set(h,'xticklabels','')
h=subplot(4,1,3);
plot(t,Tbench)
ylabel('Tbench [degC]')
set(h,'xticklabels','')
h=subplot(4,1,4);
plot(t,Plicor)
ylabel('Plicor [kPa]')
xlabel('Time (s)')