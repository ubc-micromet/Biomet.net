function [d] = fr_show_flux(dateIn,fluxSelect,d)

%dateIn = datenum(2000,8,28,19,1,0);
%fluxSelect = 1;

if exist('dateIn')~=1 | isempty(dateIn)
    dateIn = now;
end
if exist('fluxSelect')~=1 | isempty(fluxSelect)
    fluxSelect = 1;
end

switch fluxSelect
    case 1, % CO2 flux
        i = 12;
        ylabelTxt0 = 'w (m/s)';
        j =  6;
        ylabelTxt1 = 'CO_2 (ppm)';
    case 2, % Sensible heat
        i = 12;
        ylabelTxt0 = 'w (m/s)';
        j = 13;
        ylabelTxt1 = 'T_{air} \circC';
    case 3, % Latent heat
        i = 12;
        ylabelTxt0 = 'w (m/s)';
        j =  7;
        ylabelTxt1 = 'H_2O (mmol/mol)';
    otherwise,
end
        
if exist('d')~=1 | isempty(d)
    [g,d,gr,dr]=fr_plt_now(i,[],2,dateIn);
end

t = [1:length(d)]/20.833;

close all
set(0,'defaulttextfontsize',10)
set(0,'defaultaxesfontsize',10)

figure(1)
ss = get(0,'screensize');
set(1,'pos',[5 40 ss(3)-10 ss(4)-90])

x = d(i,:);
y = d(j,:);

%h = subplot(4,1,1);
h = axes;
plot(t,x)
ylabel(ylabelTxt0)
grid on
set(h,'xticklabel',[],'pos',[.13 .75 .77 .22])

%h = subplot(4,1,2);
h = axes;
plot(t,y)
ylabel(ylabelTxt1)
grid on
set(h,'xticklabel',[],'pos',[.13 .53 .77 .22],'yaxislocation','right')


%h = subplot(4,1,3);
h = axes;
c = detrend(x).*detrend(y);
plot(t,c)
ylabel('Cov')
grid on
set(h,'xticklabel',[],'pos',[.13 .31 .77 .22])

%h = subplot(4,1,4);
h = axes;
plot(t,cumsum(c)/length(c))
ylabel('Cumulativ flux')
grid on
set(h,'pos',[.13 .09 .77 .22],'yaxislocation','right')

xlabel('Time (sec)')

if nargout == 0
    clear d;
end