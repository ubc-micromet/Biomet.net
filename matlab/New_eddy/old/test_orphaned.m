x = randn(500,1);
data_in(1).EngUnits = x;
data_in(2).EngUnits = x(10:end);
data_in(3).EngUnits = [[0 0.2 0 0.4 -0.2]' ; x(1:end)];

data_in(3).EngUnits(1:300:end) = [];
data_in(3).EngUnits(1:200:end) = [];
data_in(1).EngUnits(1:50:end) = [];




m = [ones(1,100) zeros(1,130)];
z = m(ones(1,10),:)';
b = z(:);
a = b;a(1:400:end)=[];
m = b;m(1:700:end)=[];
a = a(1:2200);b=b(1:2200);m=m(1:2200);

data_in(1).EngUnits = m;
data_in(2).EngUnits = b;
data_in(3).EngUnits = a;

return


x = a;y=m;chan = [1 1];N=length(x);del_span=[-30 30];n=300;del_1=0;
del_2a = delay(x(N-n+1:N,chan(1)),y(N-n+1:N,chan(2)),del_span)

x = b;y=m;chan = [1 1];N=length(x);del_span=[-30 30];n=300;del_1=0;
del_2b = delay(x(N-n+1:N,chan(1)),y(N-n+1:N,chan(2)),del_span)

diff_b2a = abs(del_2a)+abs(del_2b);
nn = floor(linspace(1,length(b),diff_b2a+2));
b1=b;
b1(nn(2:diff_b2a+1),:) = [];

diff_a2m = abs(del_2a);
nn = floor(linspace(1,length(m),diff_a2m+2));
m1=m;
m1(nn(2:diff_a2m+1),:) = [];

a1 = a(1:2100);b1=b1(1:2100);m1=m1(1:2100);
