t = read_bor('r:\paoa\newdata\bonet\bnt_dt')+1;

minDOY = 153;  % 88
maxDOY = 159;  % 94
year = 1998;

Offset1996 = datenum(1996,1,1,0,0,0);               % data base start
offset = datenum(year,1,1,0,0,0)-Offset1996;        % start of current year

minDOY =  offset+minDOY;
maxDOY =  offset+maxDOY;

ind = find(t >=minDOY & t <= maxDOY+1);
clear t

if 1==0
    pth = 'r:\paoa\newdata\bonet\bnt';
    disp(['Processing: ' pth]);
    chans = [5:80];
    exp_pa(pth,chans,ind,'c:\cd-rom\alan_exp\bonet');

%    pth = 'r:\paoa\newdata\aesmet\met';
%    disp(['Processing: ' pth]);
%    chans = [6:54];
%    exp_pa(pth,chans,ind,'c:\cd-rom\alan_exp\aesmet');
end

% pth = 'r:\paoa\newdata\bolic2\bol2';
pth = 'r:\paoa\newdata\pcctrl2\pcct';
disp(['Processing: ' pth]);
chans = [5];
exp_pa(pth,chans,ind,'c:\cd-rom\alan_exp\pressure');