t = read_bor('h:\zoran\paoa\paoa_dt')+1;
minDOY = 367;
maxDOY = 367+86;
ind = find(t >=minDOY & t <= maxDOY);
clear t

pth = 'r:\paoa\newdata\bonet\bnt';
disp(['Processing: ' pth]);
chans = [5:50];
exp_pa(pth,chans,ind,'d:\bonet');

pth = 'r:\paoa\newdata\aesmet\met';
disp(['Processing: ' pth]);
chans = [6:54];
exp_pa(pth,chans,ind,'d:\aesmet');