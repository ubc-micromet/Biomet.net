figure(1)
clf
typeVar = 'flux';
[~,indDTnew,indDT] = intersect(tv_dtN,tv_dt);
subplot(1,2,1);
plot(chamberOut.chamber(chNum).flux.(typeGas).('lin_B').(typeVar)(indDT),...
     chamberOutNew.chamber(chNum).flux.(typeGas).('lin_B').(typeVar)(indDTnew),'o');
grid on;
zoom on
title(sprintf('%s %s ',typeGas,typeVar))
xlabel('lin_B OLD')
ylabel('lin_B NEW')
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
     chamberOutNew.chamber(chNum).flux.(typeGas).('lin_B').(typeVar)(indDTnew),'o');grid on;zoom on
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
ylabel('lin_B NEW')