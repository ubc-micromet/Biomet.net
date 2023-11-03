fid = fopen('E:\Site_DATA\WL\met-data\csi_net\bac.subset.csv');
if fid > 0
    c = textscan(fid,'%q%s%f%f%f','headerlines',1,'delimiter',',');
end
fclose all
%%
t=c{2};
tv = datenum(t);
minutesIn = (tv - floor(tv(1)));
v1 = c{5};
SF = c{[3]};
SF(:,2) = c{[4]};
v = filtfilt(fir1(100,0.5),1,v1);
%% 
figure(1)
hAX(1)=subplot(3,1,1);
plot(minutesIn,SF);
title('SF')
ylabel('mV')

hAX(2) = subplot(3,1,2);
plot(minutesIn,SF(:,1)-SF(:,2));
title('SF diff')
ylabel('mV')

hAX(3) = subplot(3,1,3);
plot(minutesIn,v);
linkaxes(hAX,'x')
title('Voltage')
ylabel('V')
%% 
figure(2)
hAX(1)=subplot(2,1,1);
plot(minutesIn,SF); grid on;
title('SF')
ylabel('mV')

hAX(2) = subplot(2,1,2);
plot(minutesIn,v); grid on;
linkaxes(hAX,'x')
title('Voltage')
ylabel('V')

%% 
figure(22)
plot(minutesIn,detrend(SF),minutesIn,detrend(v)/5-0.07,minutesIn,detrend(v1)/5-0.07); zoom on;grid on;
title('SF and V')
ylabel('mv and V')
xlabel('doy')

%%
figure(3)
ind1 = find(minutesIn>1.75 & minutesIn<1.8);
%ind1 = 2400:2600;
subsetV = v(ind1)-11.2;
subsetSF = SF(ind1,:);
p1 = polyfit(subsetV,subsetSF(:,1),1);
p2 = polyfit(subsetV,subsetSF(:,2),1);
fprintf('P1 = %6.3f * x + %6.3f\n',p1);
fprintf('P2 = %6.3f * x + %6.3f\n',p2);

plot(subsetV,subsetSF,'.',subsetV,polyval(p1,subsetV),'-',subsetV,polyval(p2,subsetV),'-')
ylabel('SF (mV)')
xlabel('Voltage-11.2 (V) ')
title(sprintf('Linear fits for SF vs V'))
legend('SF_1','SF_2')


%% 
figure(4)
SF_corrected = [SF(:,1)-polyval([p1(1) 0],v-11.2) SF(:,2)-polyval([p2(1) 0],v-11.2)];  
plot(minutesIn,[SF SF_corrected ])
title('SF vs SFCORR')
legend('SF_1','SF_2','SFCORR_1','SFCORR_2')
ylabel('mV')

%% 
figure(5)
SF_corrected = [SF(:,1)-polyval([p1(1) 0],v-11.2) SF(:,2)-polyval([p2(1) 0],v-11.2)];  
plot(minutesIn,[SF(:,1)-SF(:,2) SF_corrected(:,1)-SF_corrected(:,2) ])
title('TC difference')
legend('SF_{diff}','SFCORR_{diff}')
ylabel('mV')



