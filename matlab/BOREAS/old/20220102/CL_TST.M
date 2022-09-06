pth = '\\class\paoa\newdata\';
EddyPth = 'h:\zoran\paoa\';
%trace_path  = str2mat(,[EddyPth 'paoa_82.2_2'], [pth 'bonet\bnt.7'],[pth 'eddy\eddy.42']);
t = read_bor('r:\paoa\newdata\bonet\bnt_dt')+0.75-366;
H = read_bor([EddyPth 'paoa_81.2_2']);
Rn = read_bor([pth 'bonet\bnt.7']);
LE = read_bor([EddyPth 'paoa_82.2_2']);
Htc = read_bor([pth 'eddy\eddy.42'])*1150;
%plot(t,Rn,t,H+LE,t, Htc+LE)
%figure(1)
%plot(t,Rn-(H+LE),t, Rn-(Htc+LE),t,Rn)
%axis([180 186 -100 700])
%figure(2)
ind = find(abs(Rn)>100);
plot(t(ind),(Rn(ind)-(H(ind)+LE(ind)*0.89*0.94))./Rn(ind),t(ind), (Rn(ind)-(Htc(ind)+LE(ind)*0.89))./Rn(ind))
%plot(t,(Rn-(H+LE*0.89*0.94))./Rn,t, Rn-(Htc+LE*0.89),t,Rn)
%axis([180 186 -100 700])
axis([180 186 -1 1])
