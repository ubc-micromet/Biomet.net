%
% lab314.m
%
%   Data export for the SOIL314.
%
% (c) Zoran Nesic               File created:       Mar 31, 1997
%                               Last modification:  Mar 31, 1997
%


OutputFileName = 'c:\nz\lab314.txt';                % ouput file name
st = 158;                                           % first day
ed = 161;                                           % last day
GMTshift = 0.25;                                    % offset to convert GMT to CST
pth = '\\class\c\paoa\newdata\';
EddyPth = 'h:\zoran\paoa\';
t=read_bor([ pth 'bonet\bnt_dt']);                  % get decimal time from the data base
t = t + 1 - GMTshift;                  % convert decimal time to
                                                    % decimal DOY local time
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);

%
% Net radiation
%
trace_path  = 'bonet\bnt.7';
x = read_bor([pth trace_path]);
Rn = x(ind);

%
% Soil heat flux plates
%
s = 0;
kk = [16 19 21 22 23 24 25];
for i = kk
    c = sprintf('x = read_bor(%s%s%d%s);',39,[pth 'aessoil\soil.'],i,39);
    eval(c);
    s = s + x(ind);
end
G = s / length(kk);

%
% Latent heat
%
x = read_bor([EddyPth 'paoa_82.2_2']);
LE = x(ind);

%
% Sensible heat
%
x = read_bor([EddyPth 'paoa_81.2_2']);
H = x(ind);

figure(1)
clg
plot(t,Rn,'y-',t,G,'m--',t,LE,'b-.',t,H,'r:')
title('Energy closure(1)')
xlabel('DOY (1996)')
ylabel('W/m^2')
legend('Rn','G','LE','H',-1)
grid

figure(2)
clg
plot(t,Rn,t,G+LE+H)
title('Energy closure(2)')
xlabel('DOY (1996)')
ylabel('W/m^2')
legend('Rn','G+LE+H',-1)
grid

OutData = [t Rn G LE H];
fid = fopen(OutputFileName,'w');
fprintf(fid,'    %s           %s           %s           %s           %s\x0d\x0a\x0d\x0a','Time', 'Rn','G','LE','H');
for i=1:length(OutData)
    fprintf(fid,'%12.6e %12.4e %12.4e %12.4e %12.4e\x0d\x0a',OutData(i,:));
end
fclose(fid);
