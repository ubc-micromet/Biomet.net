%
%   wind_cal.m
%
%   Gill R2 vs RM Yound calibration based on 1996-97 data.
%
%
%
%
% (c) Zoran Nesic           File created:       Mar 26, 1997
%                           Last modification:  Mar 26, 1997
u = read_bor('h:\zoran\paoa\paoa_5.2_2');
t = read_bor('h:\zoran\paoa\paoa_dt')+0.75;
v = read_bor('h:\zoran\paoa\paoa_6.2_2');
cup_rm = read_bor('r:\paoa\newdata\aesmet\met.6');
Tair = read_bor('r:\paoa\newdata\aesmet\met.10');

cup_gill = sqrt(u.^2 + v.^2);
ind = find(cup_gill<10 & cup_gill ~=0 & cup_rm ~=0);
cup_rm = cup_rm(ind);
cup_gill = cup_gill(ind);
Tair = Tair(ind);

p = polyfit(cup_rm,cup_gill,1);
disp(sprintf('\n\np = %e*x + %e\n',p));

sigma1 = std(cup_gill - polyval(p,cup_rm));
disp(sprintf('sigma = %f\n',sigma1));
ind1 = find(abs(cup_gill - polyval(p,cup_rm))<3*sigma1);
% length(ind1)
cup_rm1 = cup_rm(ind1);
cup_gill1 = cup_gill(ind1);
Tair1 = Tair(ind1);

p1 = polyfit(cup_rm1,cup_gill1,2);
disp(sprintf('p = %e*x^2 + %e*x + %e\n',p1));
ax = [0 10];
figure(1)
plot(cup_gill1,cup_rm1,'.',ax,ax,polyval(p1,ax),ax,'linewidth',1.5);
axis([ax ax])
grid
xlabel('Gill wind speed SQRT(u^2 + v^2)')
ylabel('RM Young')
title('Gill vs RM Young')
text(5.1,1.8,sprintf('p = %e*x + %e',p),'fontsize',10)
text(5.1,1.3,sprintf('p = %e*x^2 + %e*x + %e',p1),'fontsize',10)

figure(2)
plot(Tair1,cup_gill1-cup_rm1,'.');
axis([-40 40 -3 3])
grid
xlabel('Temperature')
ylabel('Wind speed diff.')
title('Gill-RM Young vs Temperature')

