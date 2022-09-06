function [DailyAvgTime,CO2mean,wcmean,Hmean,LE_mean] = bor_pl(ind,days,year)
%
% [DailyAvgTime,CO2mean,wcmean,Hmean,LE_mean] = bor_pl(ind,days,year)
% 
%
%   This function plots anual cycles for some variables coming from
%   the EDDY correlation system
%
%
% (c) Nesic Zoran           File created:       Nov 29, 1996
%                           Last modification:  May  8, 1997
%
% Revisions:
%       May 2, 1997
%               Nice big fonts
%       May 8, 1997
%               Put Krypton plotting back (LE KH2O)
%
if nargin < 1 
    error 'Too few imput parameters!'
end
if nargin < 2
    days = 1;
end
if nargin < 3
    year = 1997;
end
DEFAULTTEXTFONTSIZE = get(0,'defaulttextfontsize');
DEFAULTAXESFONTSIZE = get(0,'defaultaxesfontsize');
set(0,'defaulttextfontsize',20);
set(0,'defaultaxesfontsize',20);
if year >= 1996
    if exist('h:\zoran\paoa\paoa_dt')
        pth = 'h:\zoran\paoa\';
    else
        pth = '\\boreas_003\paoa\';
    end
    axis1 = [340 400];
    axis2 = [-10 5];
    axis3 = [-50 250];
    axis4 = [-50 250];
elseif year == 1994
    if exist('e:\data\meaes\meaes_dt')
        pthMEaes = 'e:\data\meaes\';
        pth      = 'e:\data\ffaes\';
    else
        pthMEaes = '\\boreas_005\e\data\meaes\';
        pth      = '\\boreas_005\e\data\ffaes\';
    end
    axis1 = [340 400];
    axis2 = [-10 5];
    axis3 = [-50 250];
    axis4 = [-50 250];
end

st = min(ind);
ed = max(ind);
%st = 110;                                           % first day of measurements (approx.)
%ed = 320;                                           % last day of measurements (approx.)
td = st:ed;                                         % valid days, first to last
DailyAvgTime = min(td):days:max(td);

if year >= 1996 
    t=read_bor([ pth 'paoa_dt']);               % get decimal time from the data base
    ww = read_bor([pth 'paoa_44.2_2']);
    if year == 1996
        ind_cal = find( t > 0 & t <366 &  abs(floor(t - 0.25) - (t - 0.25)) > .02 & ww < 5);
    elseif year == 1997
        ind_cal = find( t >= 366 & t <671 &  abs(floor(t - 0.25) - (t - 0.25)) > .02 & ww < 5);
        t = t - 366;
    end
    Tair=read_bor([ pth 'paoa_8.2_2'])+273.16;  % get air Temp
else
    t=read_bor([ pth 'ffaes_dt'])-153;           % get decimal time from the data base
    ind_cal = 1:length(t);
    Tair=read_bor([ pthMEaes 'meaes.10'])+273.16;  % get air Temp    
end
t = t(ind_cal)+0.75;                              % remove calibration times and convert to DOY
                                                  % and convert to local time (CST)

fignum = 0;
if year >= 1996
    %
    % plot ww
    %
    fignum = fignum+1;
    figure(fignum)
    clg
    plot(t,ww(ind_cal));
    ax = axis;
    axis([st-1 ed 0 6])
    grid
    title(['ww ' num2str(year)]);
    ylabel('m^2/s^2');
    xlabel('DOY')
end
%
% plot Tair
%
fignum = fignum+1;
figure(fignum)
clg
plot(t,Tair(ind_cal)-273.16);
ax = axis;
axis([st-1 ed -40 30])
grid
title(['Tair ' num2str(year)]);
ylabel('degC');
xlabel('DOY')

%
% ------------------------------------------------------------------------------
%
if year >= 1996
    c=read_bor([ pth 'paoa_9.2_2']);            % get CO2 concetration, second table
    Pb = read_bor([ pth 'paoa_12.2_2']);       % get Pbarometric
    c = c ./ ( 1000/189 .* Pb ./ Tair );         % convert to ppm
    c = c(ind_cal);                              % remove calibration times
%    ind=find(c < 800 & c > 500);                        % remove "unreasonable" values
else
    c=read_bor([ pth 'ffaes.4']);               % get CO2 concetration
    c = c(ind_cal);                              % remove calibration times
end
ind=find(c < 500 & c > 320);                        % remove "unreasonable" values

fignum = fignum + 1;
figure(fignum)
plot(t(ind),c(ind))                                 % plot "good" values
ax = axis;
axis([st-1 ed ax(3:4)])
grid
title(['CO2 concentration ' num2str(year)]);
ylabel('ppm');
xlabel('DOY')

[xsum,xmean,TimeX] = integz(t(ind),c(ind),td,days);       % find daily sums and averages

fignum = fignum + 1;
figure(fignum)
%plot(DailyAvgTime,xmean)                            % plot daily averages for CO2 conc.
plot(TimeX,xmean,'linewidth',1.5)                            % plot daily averages for CO2 conc.
CO2mean = xmean;
grid
ax = axis;
ax1 = ax(1:2);
axis([ax1 axis1])
title(['Daily mean CO2 concentration for ' num2str(year)],'fontsize',24);
ylabel('ppm','fontsize',20);
xlabel('DOY','fontsize',20)
%
% ------------------------------------------------------------------------------
%
if year >= 1996
    wc=read_bor([ pth 'paoa_46.2_2'])*1000/44;      % get CO2 fluxes
    wc = wc(ind_cal);                               % remove calibration times
    ind=find(abs(wc) > 30 | wc ==0);                % remove "unreasonable" values
    wc(ind) = NaN * ones(size(ind));
else
    wc=read_bor([ pth 'ffaes.9'])*1000/44;          % get CO2 fluxes
    ind=find(abs(wc) > 30 | wc ==0);                % remove "unreasonable" values
    wc(ind) = NaN * ones(size(ind));
end

fignum = fignum + 1;
figure(fignum)
plot(t,wc)
ax = axis;
axis([st-1 ed ax(3:4)])
grid
title(['CO2 flux for ' num2str(year)]);
ylabel('umol/m^2/s');
xlabel('DOY')

[xsum,xmean,TimeX] = integz(t(~isnan(wc)),wc(~isnan(wc)),td,days);    % find daily sums and averages
iii = find(xmean < 5 & xmean > -10);
wcmean = xmean;

fignum = fignum + 1;
figure(fignum)
%plot(DailyAvgTime,xmean)                                      % plot daily averages for CO2 fluxes
plot(TimeX,xmean,'linewidth',1.5)                                      % plot daily averages for CO2 fluxes
grid
axis([ax1 axis2])
title(['Daily mean CO2 flux for ' num2str(year)]);
ylabel('umol/m^2/s');
xlabel('DOY')
%
% ------------------------------------------------------------------------------
%
if year >= 1996
    H=read_bor([ pth 'paoa_81.2_2']);           % get sensible heat
else
    H=read_bor([ pth 'ffaes.7']);           % get sensible heat
end
H = H(ind_cal);                              % remove calibration times
ind=find(H < -200 | H > 800  | H ==0);                   % remove "unreasonable" values
H(ind) =  NaN * ones(size(ind));

fignum = fignum + 1;
figure(fignum)
plot(t,H)
ax = axis;
axis([st-1 ed ax(3:4)])
grid
title(['Sensible heat for ' num2str(year)]);
ylabel('W/m^2');
xlabel('DOY')

[xsum,xmean,TimeX] = integz(t(~isnan(H)),H(~isnan(H)),td,days);           % find daily sums and averages
Hmean = xmean;
fignum = fignum + 1;
figure(fignum)
%plot(DailyAvgTime,xmean)                                      % plot daily averages for sensible heat
plot(TimeX,xmean,'linewidth',1.5)                                      % plot daily averages for sensible heat

grid
axis([ax1 axis3])
title(['Daily mean sensible heat for ' num2str(year)]);
ylabel('W/m^2');
xlabel('DOY')
%
% ------------------------------------------------------------------------------
%
if year >= 1996
    LE=read_bor([ pth 'paoa_82.2_2']);                  % get LE LICOR
    LEK=read_bor([ pth 'paoa_83.2_2']);                 % get LE KRYPTON
    LEK = LEK(ind_cal);                                 % remove calibration times
    indk=find( LEK < 800 & LEK > -100 & LEK ~=0);       % remove "unreasonable" values
else
    LE=read_bor([ pth 'ffaes.8']);                      % get LE LICOR
end
LE = LE(ind_cal);                                       % remove calibration times
ind=find( LE < 800 & LE > -100 & LE ~=0);               % remove "unreasonable" values

fignum = fignum + 1;
figure(fignum)
plot(t(ind),LE(ind))                                    % plot LE LICOR
ax = axis;
axis([st-1 ed ax(3:4)])
grid
title(['LICOR latent heat for ' num2str(year)]);
ylabel('W/m^2');
xlabel('DOY')

[xsum,xmean,TimeX] = integz(t(ind),LE(ind),td,days);           % find daily sums and averages for LE LICOR
if year >= 1996
    [xksum,xkmean,TimeXk] = integz(t(indk),LEK(indk),td,days);      % find daily sums and averages for LE LICOR
    LE_mean = [xmean(:) xkmean(:)];
else
    LE_mean = xmean(:);
end

fignum = fignum + 1;
figure(fignum)
if year >= 1996
%    plot(DailyAvgTime,xmean,DailyAvgTime,xkmean,'--')                          % plot daily averages for LE LICOR and KRYPTON
    plot(TimeX,xmean,'linewidth',1.5)
    hold on
    plot(TimeXk,xkmean,'--m','linewidth',1.5)                                         % plot daily averages for LE LICOR and KRYPTON
    hold off
    title([ 'Daily mean LE (LICOR & KRYPTON) for ' num2str(year)]);
%    plot(TimeX,xmean)                       % plot daily averages for LE LICOR and KRYPTON    
%    title([ 'Daily mean LE (LICOR) for ' num2str(year)]);
else
%    plot(DailyAvgTime,xmean)                                                   % plot daily averages for LE LICOR
    plot(TimeX,xmean)                                                           % plot daily averages for LE LICOR    
    title([ 'Daily mean LE LICOR for ' num2str(year)]);    
end
grid
axis([ax1 axis4])
ylabel('W/m^2');
xlabel('DOY')
%
% ------------------------------------------------------------------------------
%
if nargout == 0
    clear DailyAvgTime CO2mean wcmean Hmean     
end
set(0,'defaulttextfontsize',DEFAULTTEXTFONTSIZE);
set(0,'defaultaxesfontsize',DEFAULTAXESFONTSIZE);
%tile