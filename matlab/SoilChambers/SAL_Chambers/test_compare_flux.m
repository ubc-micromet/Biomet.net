chNum = 1;
fluxType = 'co2';
varType = 'flux';
fitType = 'exp_B';

%%
fluxNew = NaN(24,1);
flux1 = NaN(24,1);
flux2 = NaN(24,1);
rmseNew = NaN(24,1);
rmse1 = NaN(24,1);
rmse2 = NaN(24,1);
for cntSample=1:24
    try
        fluxNew(cntSample) = dataStructNewPoints.chamber(chNum).sample(cntSample).flux.(fluxType).(fitType).(varType);
        rmseNew(cntSample) = dataStructNewPoints.chamber(chNum).sample(cntSample).flux.(fluxType).(fitType).('rmse');
    catch    
    end
    try
        flux1(cntSample) = dataStruct1.chamber(chNum).sample(cntSample).flux.(fluxType).(fitType).(varType);
        rmse1(cntSample) = dataStruct1.chamber(chNum).sample(cntSample).flux.(fluxType).(fitType).('rmse');
    catch
    end    
    try
        flux2(cntSample) = dataStruct2.chamber(chNum).sample(cntSample).flux.(fluxType).(fitType).(varType);
        rmse2(cntSample) = dataStruct2.chamber(chNum).sample(cntSample).flux.(fluxType).(fitType).('rmse');
    catch
    end        
end
figure(21)
set(21,'name',sprintf('%s   #%d',datestr(dateIn),chNum),'numbertitle','off');
clf
ax(1)= subplot(2,1,1);
plot([fluxNew flux1 flux2])
title(fluxType)
ylabel(varType)
grid on
zoom on
legend('new','old','original')

ax(2)=subplot(2,1,2);
plot([rmseNew rmse1 rmse2])
title(fluxType)
ylabel('rmse')
grid on
zoom on
legend('new','old','original')
linkaxes(ax,'x');

%%
fluxType = 'ch4';
fluxNew = NaN(24,1);
flux1 = NaN(24,1);
flux2 = NaN(24,1);
rmseNew = NaN(24,1);
rmse1 = NaN(24,1);
rmse2 = NaN(24,1);
for cntSample=1:24
    try
        fluxNew(cntSample) = dataStructNewPoints.chamber(chNum).sample(cntSample).flux.(fluxType).(fitType).(varType);
        rmseNew(cntSample) = dataStructNewPoints.chamber(chNum).sample(cntSample).flux.(fluxType).(fitType).('rmse');
    catch    
    end
    try
        flux1(cntSample) = dataStruct1.chamber(chNum).sample(cntSample).flux.(fluxType).(fitType).(varType);
        rmse1(cntSample) = dataStruct1.chamber(chNum).sample(cntSample).flux.(fluxType).(fitType).('rmse');
    catch
    end    
    try
        flux2(cntSample) = dataStruct2.chamber(chNum).sample(cntSample).flux.(fluxType).(fitType).(varType);
        rmse2(cntSample) = dataStruct2.chamber(chNum).sample(cntSample).flux.(fluxType).(fitType).('rmse');
    catch
    end        
end
figure(22)
set(22,'name',sprintf('%s   #%d',datestr(dateIn),chNum),'numbertitle','off');
clf
ax(1)= subplot(2,1,1);
plot([fluxNew flux1 flux2])
title(fluxType)
ylabel(varType)
grid on
zoom on
legend('new','old','original')

ax(2)=subplot(2,1,2);
plot([rmseNew rmse1 rmse2])
title(fluxType)
ylabel('rmse')
grid on
zoom on
legend('new','old','original')
linkaxes(ax,'x');

return
%%

load D:\NZ\MATLAB\CurrentProjects\UdeM\data\all_chambers_2019.mat;
chamberOutNew=chamberOut;
tv_dtN = datetime(chamberOutNew.chamber(1).tv,'convertfrom','datenum');
load D:\NZ\MATLAB\CurrentProjects\UdeM\data\all_chambers.mat;
tv_dt = datetime(chamberOut.chamber(1).tv,'convertfrom','datenum');

%%
typeGas = 'ch4';
typeFit = 'exp_B';
typeVar = 'flux';
chNum = 1;

figure(31);
clf
subplot(2,1,1);
plot(tv_dtN,chamberOutNew.chamber(chNum).flux.(typeGas).(typeFit).(typeVar),'o-',...
     tv_dt,chamberOut.chamber(chNum).flux.(typeGas).(typeFit).(typeVar),'x-');grid on;zoom on
title(sprintf('%s  (Fit: %s)',typeGas,typeFit))
ylabel(typeVar)
if strcmp(typeGas,'ch4')
    ylim([-.01 0.01])
else
    ylim([-5 5])
end
legend('New','original')  

typeVar = 'rmse';
subplot(2,1,2);
plot(tv_dtN,chamberOutNew.chamber(chNum).flux.(typeGas).(typeFit).(typeVar),'o-',...
     tv_dt,chamberOut.chamber(chNum).flux.(typeGas).(typeFit).(typeVar),'x-');grid on;zoom on
title(sprintf('%s  (Fit: %s)',typeGas,typeFit))
ylabel(typeVar)
if strcmp(typeGas,'ch4')
    ylim([0 0.002])
else
    ylim([0 1])
end
legend('New','original') 


figure(32);
clf
typeVar = 'flux';
[~,indDTnew,indDT] = intersect(tv_dtN,tv_dt);
subplot(1,2,1);
plot(chamberOut.chamber(chNum).flux.(typeGas).(typeFit).(typeVar)(indDT),...
     chamberOutNew.chamber(chNum).flux.(typeGas).(typeFit).(typeVar)(indDTnew),'o');
grid on;
zoom on
title(sprintf('%s %s (Fit: %s)',typeGas,typeVar,typeFit))
xlabel('old')
ylabel('new')
if strcmp(typeGas,'ch4')
    maxLim = 0.004
else
    maxLim = 4
end
ylim([-maxLim maxLim ])
xlim([-maxLim maxLim ])


typeVar = 'rmse';
subplot(1,2,2);
plot(chamberOut.chamber(chNum).flux.(typeGas).(typeFit).(typeVar)(indDT),...
     chamberOutNew.chamber(chNum).flux.(typeGas).(typeFit).(typeVar)(indDTnew),'o');grid on;zoom on
title(sprintf('%s %s (Fit: %s)',typeGas,typeVar,typeFit))
ylabel(typeVar)
if strcmp(typeGas,'ch4')
    maxLim = 0.002;
else
    maxLim = 0.8;
end
ylim([0 maxLim ])
xlim([0 maxLim ])
xlabel('old')
ylabel('new')

figure(33);
clf
typeVar = 'flux';
[~,indDTnew,indDT] = intersect(tv_dtN,tv_dt);
subplot(1,2,1);
plot(chamberOut.chamber(chNum).flux.(typeGas).('lin_B').(typeVar)(indDT),...
     chamberOutNew.chamber(chNum).flux.(typeGas).(typeFit).(typeVar)(indDTnew),'o');
grid on;
zoom on
title(sprintf('%s %s ',typeGas,typeVar))
xlabel('lin_B OLD')
ylabel('exp_b NEW')
if strcmp(typeGas,'ch4')
    maxLim = 0.004;
else
    maxLim = 4;
end
ylim([-maxLim maxLim ])
xlim([-maxLim maxLim ])


typeVar = 'rmse';
subplot(1,2,2);
plot(chamberOut.chamber(chNum).flux.(typeGas).('lin_B').(typeVar)(indDT),...
     chamberOutNew.chamber(chNum).flux.(typeGas).(typeFit).(typeVar)(indDTnew),'o');grid on;zoom on
title(sprintf('%s %s',typeGas,typeVar))
ylabel(typeVar)
if strcmp(typeGas,'ch4')
    maxLim = 0.002;
else
    maxLim = 0.8;
end
ylim([0 maxLim ])
xlim([0 maxLim ])
xlabel('lin_B OLD')
ylabel('exp_b NEW')

%figure(31);plot(chamberOutNew.chamber(1).flux.ch4.exp_B.flux,chamberOut.chamber(1).flux.ch4.exp_B.flux,'o');grid on;zoom on
%%
dataPath = 'E:\Site_DATA\WL\met-data\hhour'; %#ok<UNRCH>
archiveDate1 = '20230416';
archiveDate2 = '20230415';
dateIn = datenum("Aug 4, 2019");
fileNameNew = fullfile(dataPath,sprintf('%s_recalcs_UdeM.mat',datestr(dateIn,'yyyymmdd')));
%load E:\Site_DATA\WL\met-data\hhour\20190801_recalcs_UdeM.mat
load(fileNameNew)
dataStructNewPoints=dataStruct;
fileNameOld = fullfile(dataPath,'old',archiveDate1,sprintf('%s_recalcs_UdeM.mat',datestr(dateIn,'yyyymmdd')));
load(fileNameOld)
dataStruct1 = dataStruct;
fileNameOld = fullfile(dataPath,'old',archiveDate2,sprintf('%s_recalcs_UdeM.mat',datestr(dateIn,'yyyymmdd')));
load(fileNameOld)
dataStruct2 = dataStruct;
%load E:\Site_DATA\WL\met-data\hhour\old\20230415\20190801_recalcs_UdeM.mat

