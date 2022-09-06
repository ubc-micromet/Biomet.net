%F2 = 1;
F2 = 20.8/2;
F1 = 0.001;
Find = logspace(log10(F1),log10(F2),50);
%Find = [0.001 .01 .1 1 10];
ratioT = zeros(size(F1));
ratioC = zeros(size(F1));
ratioH = zeros(size(F1));
ratioR = zeros(size(F1));
for i = 1:length(Find)
    disp(i);
    ratioT(i) = spc_loss(Pt,Fx,covWT,Find(i));
    ratioC(i) = spc_loss(Pc,Fx,covWC,Find(i));
    ratioH(i) = spc_loss(Ph,Fx,covWH,Find(i));
    ratioR(i) = spc_loss(Pr,Fx,covWR,Find(i));    
end

ratioT = 100*( ratioT - spc_loss(Pt,Fx,covWT,F2)) / spc_loss(Pt,Fx,covWT,0);
ratioC = 100*( ratioC - spc_loss(Pc,Fx,covWC,F2)) /spc_loss(Pc,Fx,covWC,0);
ratioH = 100*( ratioH - spc_loss(Ph,Fx,covWH,F2)) /spc_loss(Ph,Fx,covWH,0);
ratioR = 100*( ratioR - spc_loss(Pr,Fx,covWR,F2)) /spc_loss(Pr,Fx,covWR,0);
%    disp(sprintf('WT =  %6.2f percent between %6.2f and %6.2f (Hz)',[ratioT*100 F1 F2])); 
%    disp(sprintf('WC =  %6.2f percent between %6.2f and %6.2f (Hz)',[ratioC*100 F1 F2])); 
%    disp(sprintf('WH =  %6.2f percent between %6.2f and %6.2f (Hz)',[ratioH*100 F1 F2]));
%    disp(sprintf('WR =  %6.2f percent between %6.2f and %6.2f (Hz)',[ratioR*100 F1 F2])); 

figure(1)
clg
semilogx(Find,ratioT,Find,ratioH,'-.',Find,ratioR,'--')
grid
axis([.001 10 0 100])
title('Transfer functions')
xlabel('Frequency (Hz)')
ylabel('Percent of covariance for the bandwidth: f to 10.4Hz')
h=legend('wT','wH','wR');
axes(h)
refresh

figure(2)
clg
semilogx(Find,ratioT-ratioH,'-',Find,ratioT-ratioR,'--')
grid
axis([.001 10 -3 5])
title('Differences')
xlabel('Frequency (Hz)')
ylabel('(wT-wC)(%) of covariance for the bandwidth: f to 10.4Hz')
h=legend('wT-wH','wT-wR');
axes(h)
refresh
