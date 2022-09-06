xx = '_z2';
w = loadzip(['sumw' xx]);
T = loadzip(['sumt' xx]);
c = loadzip(['sumc' xx]);
h = loadzip(['sumh' xx]);
r = loadzip(['sumr' xx]);
n = 2^14;
l = 2^17;
delayT = 19;
w = w(1:l-delayT);
r = r(1:l-delayT);
T = T(1:l-delayT);
c = c(1+delayT:l);
h = h(1+delayT:l);
tmp = cov(w,c);
covWC = tmp(1,2);
tmp = cov(w,T);
covWT = tmp(1,2);
tmp = cov(w,h);
covWH = tmp(1,2);
tmp = cov(w,r);
covWR = tmp(1,2);

eval(['load wt' xx]);
Pt = Px;
Ptd = Pxd;
eval(['load wc' xx]);
Pc = Px;
Pcd = Pxd;

eval(['load wh' xx]);
Ph = Px;
Phd = Pxd;

eval(['load wr' xx]);
Pr = Px;
Prd = Pxd;

ind = ~isnan(Prd);
hpl = figure(1);     
semilogx(Flog(ind),real(Ptd(ind)).*Flog(ind)/covWT,Flog(ind),real(Pcd(ind)).*Flog(ind)/covWC,Flog(ind),real(Phd(ind)).*Flog(ind)/covWH,Flog(ind),real(Prd(ind)).*Flog(ind)/covWR);
ax = axis;
axis([0.001 10 ax(3:4)]);
ax=axis;line(ax(1:2),[0 0])
title('Cospectra, 7 Jun 1994, 18:30 - 20:30 GMT')
xlabel('Frequency (Hz)')
ylabel('Normalized wT, wC, wH, wR')

h=get(get(hpl,'children'),'children');
set(h(5),'linewidth',2);
set(h(4),'linewidth',1.5);
set(h(3),'linewidth',.5);
set(h(3),'linestyle','-.');
set(h(2),'linewidth',.5);
legend('wT','wC','wH','wR')
