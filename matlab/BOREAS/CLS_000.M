t = read_bor('h:\zoran\paoa\paoa_dt')+0.75;
Hgill = read_bor('h:\zoran\paoa\paoa_81.2_2');
Htc = read_bor('r:\paoa\newdata\eddy\eddy.42')*1150;

LE = read_bor('h:\zoran\paoa\paoa_82.2_2');
Rn = read_bor('r:\paoa\newdata\bonet\bnt.7');
dRn = diff(Rn);
st = 228;
ed = 238;
TimeInd = find(t>=st & t <=ed);
EnergyAxis = [-300 1000];
TimeAxis = [st ed EnergyAxis];

LE = LE(TimeInd);
Hgill = Hgill(TimeInd);
Htc = Htc(TimeInd);
H = Hgill;
Rn = Rn(TimeInd);
dRn = dRn(TimeInd-1);
t = t(TimeInd);
H_LE = H+LE;

figure(1)
clg
plot(t,Rn,t,LE,t,H)
axis(TimeAxis)
xlabel('DOY, 1996')
ylabel('W/m^2')
title('Closure Rn, H, LE')

figure(2)
clg
plot(t,Rn,t,H_LE,'--m')
axis(TimeAxis)
xlabel('DOY, 1996')
ylabel('W/m^2')
title('Closure Rn & LE+H')


MinGood = -200;
MaxGood = 1000;
GoodInd = find(Rn > MinGood & Rn < MaxGood & H_LE > MinGood & H_LE < MaxGood);
Rg = Rn(GoodInd);
Rs = (0.1*dRn(GoodInd)-7.4)*0;
H_LEg = H(GoodInd)+LE(GoodInd)+Rs;
p = polyfit(Rg,H_LEg,1)

figure(3)
clg
plot(Rg,H_LEg,'o',EnergyAxis,EnergyAxis,EnergyAxis,polyval(p,EnergyAxis))
grid
axis([EnergyAxis EnergyAxis])
xlabel('Rn')
ylabel('LE+H')
title('Closure Rn & LE+H')

figure(4)
clg
plot(Hgill,Htc,'o',EnergyAxis*.5,EnergyAxis*.5)
grid
axis([EnergyAxis EnergyAxis]*.5)
xlabel('Hgill')
ylabel('Htc')
title('Htc vs Hgill')

