% Used this script to explore delay times between ECCC data base (hourly,
% converted to GMT from PST, using mid-period time stamp instead of
% end-period as we do)
%
% Tested delay times between ECCC and BB for Pbar (k=1) and Tair (k=2).
% The result is that we should add 30min to ECCC data (as one would expect 
% when using mid-period time mark instead of end-period). 
%
% Zoran (July 14, 2022)

testPair = {'Pbar','MET_Barom_Press_kPa_Avg'; ...
            'Tair','MET_HMP_T_2m_Avg'};
testPairGain = [100 1];
k = 2;
delay_ECCC = 1/48; % +1/48 = +30min
tv_ECCC = read_bor('P:\Database\2022\BB\Met\ECCC\Clean_tv',8)+delay_ECCC;
x_ECCC = read_bor(fullfile('P:\Database\2022\BB\Met\ECCC\',char(testPair{k,1})))/testPairGain(k);
tv_BB  = read_bor('P:\Database\2022\BB\Met\Clean_tv',8);
x_BB   = read_bor(fullfile('P:\Database\2022\BB\Met\',char(testPair{k,2})));

x_ECCC_30min = interp1(tv_ECCC,x_ECCC,tv_BB,'linear','extrap');
figure(1);
plot(datetime(tv_ECCC,'convertfrom','datenum'),detrend(x_ECCC,0,'omitnan'),'o',...
    datetime(tv_BB,'convertfrom','datenum'),detrend(x_ECCC_30min,0,'omitnan'),'-',...
    datetime(tv_BB,'convertfrom','datenum'),detrend(x_BB,0,'omitnan'),'x-')
grid
zoom on
ind = ~isnan(x_BB) & ~isnan(x_ECCC_30min);
delayECCC_nsamples=fr_delay(x_BB(ind),x_ECCC_30min(ind),10)

%%
% now test the final data base 
tv=read_bor('P:\Database\2022\BB\Met\ECCC\30min\Clean_tv',8);
Tair = read_bor('P:\Database\2022\BB\Met\ECCC\30min\Tair');
Tair_1 = read_bor('P:\Database\2022\BB\Met\MET_HMP_T_2m_Avg');
figure(2);
subplot(2,1,1)
plot(datetime(tv,'convertfrom','datenum'),Tair,'-o',datetime(tv,'convertfrom','datenum'),Tair_1,'-x');
grid on
zoom on
legend('Tair_{ECCC}','Tair_{BB}')

Pbar_1 = read_bor('P:\Database\2022\BB\Met\MET_Barom_Press_kPa_Avg');
Pbar = read_bor('P:\Database\2022\BB\Met\ECCC\30min\Pbar');

subplot(2,1,2)
plot(datetime(tv,'convertfrom','datenum'),Pbar/1000,'-o',datetime(tv,'convertfrom','datenum'),Pbar_1,'-x');
zoom on
grid on
legend('Pbar_{ECCC}','Pbar_{BB}')

