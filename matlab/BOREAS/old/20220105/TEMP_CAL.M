%
%   temp_cal.m
%
%   Gill R2 vs Thermocouple calibration based on 1996-97 data.
%
%
%
%
% (c) Zoran Nesic           File created:       Mar 12, 1997
%                           Last modification:  Mar 14, 1997



Tg =read_bor('h:\zoran\paoa\paoa_8.2_2');
Tc =read_bor('r:\paoa\newdata\eddy\eddy.12');
Tc = Tc - 273.16;
st = [-30  -11 2 22];
ed = [st(2:4) 30];
%st = 22;ed =  30;
%st = 2;ed =  22;
%st = -11;ed =  2;
%st = -30;ed = -11;

pn1 = 1;
pn10 = 1;
pn2 = 1;

Tc0 = Tc;
Tg0 = Tg;

figure(1)
clg
%plot(Tg,Tc,'.y')
    ax=[-40 35];
    plot(ax(1:2),ax(1:2),'linewidth',1)
    axis([ax ax]);
    grid;
    title('Thermocouple vs Gill temperature')
    xlabel('Gill')
    ylabel('Tc')
    hold on
aa=3;
for i = 1:length(st)
    Tc = Tc0;
    Tg = Tg0;
    %    disp(sprintf('%f %f\n',[st(i) ed(i)]));
    ind = find(Tc > st(i)-aa & Tc < ed(i)+aa & Tg > st(i) & Tg < ed(i) & Tc ~= 0 & Tg ~=0);
    Tc = Tc(ind);
    Tg = Tg(ind);
    %    [min(Tg) max(Tg)]
    
    p1 = polyfit(Tg,Tc,pn1);
    sigma = std(Tc-polyval(p1,Tg));
    ind = find(abs(Tc-polyval(p1,Tg))<3*sigma);
    
    Tc = Tc(ind);
    Tg = Tg(ind);

    p10 = polyfit(Tg,Tc,pn10);
    sigma = std(Tc-polyval(p10,Tg));
    ind = find(abs(Tc-polyval(p10,Tg))<3*sigma);
    Tc = Tc(ind);
    Tg = Tg(ind);

    p2 = polyfit(Tg,Tc,pn2);
    pol(i,:) = p2;
    Tgs = sort(Tg);
    %plot(Tg,Tc,'.',Tgs,polyval(p2,Tgs),Tg0,Tc0,'.');
    %plot(Tg,Tc,'.',Tgs,polyval(p2,Tgs));
    
    min1 = min(Tgs);
    max1 = max(Tgs);
    mean1 = (min1+max1)/2;
    len1 = max1-min1;
    indx = linspace(mean1-len1,mean1+len1,32);
    plot(Tg,Tc,'.r',indx,polyval(p2,indx),'g','linewidth',2);
    err1(i) = sqrt(mean((Tc-polyval(p2,Tg)).^2));
    disp(sprintf('Mean sqrt err. = %f',err1(i)))
end
hold off

disp(sprintf('\nPolynomials:'));
for i=1:length(st)
    disp(sprintf('%6.3fx + %6.3f  (err = %6.3f, span = %6.3f to %6.3f)', pol(i,:), err1(i),st(i),ed(i)));
end
