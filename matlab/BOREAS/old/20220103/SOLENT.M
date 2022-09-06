n=1024*4;         % number of points
T = 2;         % time period
f = 21;         % solent output freq. [Hz]
t = linspace(0,T,n);
fc = 10;       % filter cutoff freq. [Hz]
fn = 4;         % signal freq. [Hz]
RC = 1/(2*pi*fc);
num = [ 0 1];
den = [RC 1];
n1 = fix(n / f/T);
l = fix(n/n1);
a = randn(1,l);
u = a(ones(n1,1),:);
a = [];
u = [u(:) ; u(l)*ones(n-l*n1,1)];
%u = ones(1,n);
[y,x] = lsim(num,den,u,t);
figure(1)
plot(t,y,t,u)
grid
figure(2)
psd(u,[],n/T)
title('Power spectrum density of Solent Output')
ax=axis;
%axis([0 100 ax(3:4)])
figure(3)
psd(y,[],n/T)
axis([0 100 ax(3:4)])
title('Power spectrum density of Filter Output')



