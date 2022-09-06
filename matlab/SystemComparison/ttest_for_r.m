% t-test of significance of correlation according to
% http://www.higp.hawaii.edu/~cecily/courses/gg313/DA_book/node57.html
% and assuming that there are N/tau independent samples

% r for type I error (rejecting the (true) null hypothesis that r=0)
N = 36000;
tau = 100;
t = -tinv(0.05/2,N/tau-2);

sqrt((t^2/(N/tau))/(1+t^2/(N/tau)))