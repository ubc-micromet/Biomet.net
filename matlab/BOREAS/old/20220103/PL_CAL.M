function x  = pl_cal(ext,pth)
if nargin < 2
    pth = 'd:\met-data\hhour\';
end
if nargin < 1
	ext = 'bin';
end
fn = [pth 'callog.' deblank(num2str(ext)) ] ;
tm = callog(fn,2,[]);
d  = callog(fn,1,[]);
dt = decdoy(d,tm)-6/24;
u_zero =  callog(fn,7,[],2,1,2);
v_zero =  callog(fn,7,[],2,2,2);
Pg_zero =  callog(fn,7,[],2,9,2);
Pg_span =  callog(fn,8,[],2,9,2);
Pb_zero =  callog(fn,7,[],2,8,2);
Pb_span =  callog(fn,8,[],2,8,2);
c_gain   = callog(fn,8,[],2,5,2);
c_zero_V = callog(fn,7,[],2,5,1);
h_zero_V = callog(fn,7,[],2,6,1);
if nargout > 0
    x = [c_zero_V c_gain h_zero_V Pg_zero Pg_span Pb_zero Pb_span u_zero v_zero];
    return
end
figure(1)
clg
%plot(dt,c_gain,'y',dt,c_gain,'oy')
plot(dt,c_gain,'oy')
grid
ax=axis;
axis([ax(1:2) .90 .96])
zoom on
title('CO2 span, Sol = 2')
xlabel('DOY')
ylabel('Gain')
pause

figure(1)
clg
plot(dt,c_zero_V,'oy')
%plot(dt,c_zero_V,'y',dt,c_zero_V,'oy')
grid
ax=axis;
axis([ax(1:2) -20 30])
title('Zero CO2, Sol = 2')
xlabel('DOY')
ylabel('(mV)')
pause

figure(1)
clg
plot(dt,h_zero_V,'oy')
%plot(dt,c_zero_V,'y',dt,c_zero_V,'oy')
grid
ax=axis;
axis([ax(1:2) -10 50])
title('Zero H2O, Sol = 2')
xlabel('DOY')
ylabel('(mV)')