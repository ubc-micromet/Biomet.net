%
%
% Main program for qubic term calculation (testing of qt.m function)
%
%
%
Fs = 20.83;                     % freq. of sampling
N = 500;                        % number of points
dt = [1:N]/Fs;
tf = 0.5;
tau = 50;
m = 1;
qterm = qt(dt,tf,tau,m);

%
% Estimation of tf, tau, m
%
dt_in = dt;
qt_in = qterm + 0.001*randn(size(qterm));               % introduce noise
h_hat = fmins('qt_min',[1 10 1],foptions,[],dt_in,qt_in);
disp(sprintf('tf = %f, tau = %f, m = %f\n\n', h_hat))
plot(dt_in,qt_in,'o',dt,qt(dt,h_hat(1),h_hat(2),h_hat(3)))

%plot(dt,qterm,'-')
