function err = qt_min(x,dt_in,qt_in)
%
%
%
%
%
%
%
tf = x(1);
tau = x(2);
m = x(3);
err = sum( ( qt_in - qt(dt_in,tf,tau,m)) .^ 2 );
if tau < 30
    err = 10000000*err;
end


