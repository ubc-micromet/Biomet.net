function x = bor94pl(ind)
%
% bor94pl.m
%
%   This function plots anual cycles for some variables coming from
%   the EDDY correlation system (BOREAS 1994)
%
%
% (c) Nesic Zoran           File created:       Nov 14, 1996
%                           Last modification:  Nov 12, 1996
%
if nargin < 1 
    error 'Too few imput parameters!'
end
st = min(ind);
ed = max(ind);
%st = 110;                                           % first day of measurements (approx.)
%ed = 320;                                           % last day of measurements (approx.)
td = st:ed;                                         % valid days, first to last
%pth = 'h:\zoran\data\';
%pth = 'c:\nz\biomet\splitedy\';
pth = 'v:\data\ffaes\';
t=read_bor([ pth 'ffaes_dt'])-153;               % get decimal time from the data base
ind_cal = find( abs(floor(t - 0.25) - (t - 0.25)) > .02 );
t = t(ind_cal);                              % remove calibration times
%
% ------------------------------------------------------------------------------
%
c=read_bor([ pth 'ffaes.4']);            % get CO2 concetration, second table
c = c(ind_cal);                              % remove calibration times
ind=find(c < 500 & c > 250);                        % remove "unreasonable" values
figure(1)
plot(t(ind),c(ind))                                 % plot "good" values
grid
title('CO2 concentration 1996');
ylabel('mg m^-3');
xlabel('DOY')

[xsum,xmean] = integz(t(ind),c(ind),td);            % find daily sums and averages
figure(2)
plot(td,xmean)                                      % plot daily averages for CO2 conc.
grid
title('Daily mean CO2 concentration for 1996');
ylabel('mg m^-3');
xlabel('DOY')
%
% ------------------------------------------------------------------------------
%
wc=read_bor([ pth 'ffaes.9'])*1000/44;         % get CO2 fluxes
wc = wc(ind_cal);                              % remove calibration times
ind=find(abs(wc) > 30 | wc ==0);                   % remove "unreasonable" values
wc(ind) = NaN * ones(size(ind));
figure(3)
plot(t,wc)
grid
title('CO2 flux for 1996');
ylabel('umol/m^2/s');
xlabel('DOY')

%[xsum,xmean] = integz(t,wc,td);           % find daily sums and averages
[xsum,xmean] = integz(t(~isnan(wc)),wc(~isnan(wc)),td);           % find daily sums and averages
figure(4)
plot(td,xmean)                                      % plot daily averages for CO2 fluxes
grid
title('Daily mean CO2 flux for 1996');
ylabel('umol/m^2/s');
xlabel('DOY')
%
% ------------------------------------------------------------------------------
%
H=read_bor([ pth 'ffaes.7']);           % get sensible heat
H = H(ind_cal);                              % remove calibration times
ind=find(H < -200 | H > 800  | H ==0);                   % remove "unreasonable" values
H(ind) =  NaN * ones(size(ind));
figure(5)
plot(t,H)
grid
title('Sensible heat for 1996');
ylabel('W/m^2');
xlabel('DOY')

[xsum,xmean] = integz(t(~isnan(H)),H(~isnan(H)),td);           % find daily sums and averages
figure(6)
plot(td,xmean)                                      % plot daily averages for sensible heat
grid
title('Daily mean sensible heat for 1996');
ylabel('W/m^2');
xlabel('DOY')
%
% ------------------------------------------------------------------------------
%
LE=read_bor([ pth 'ffaes.8']);                 % get LE LICOR
LE = LE(ind_cal);                              % remove calibration times
LEK = LE;
%LEK=read_bor([ pth 'ffaes_83.2_2']);                % get LE KRYPTON
%LEK = LEK(ind_cal);                              % remove calibration times
ind=find( LE < 800 & LE > -100 & LE ~=0);           % remove "unreasonable" values
indk=find( LEK < 800 & LEK > -100 & LEK ~=0);           % remove "unreasonable" values
figure(7)
plot(t(ind),LE(ind))                                % plot LE LICOR
grid
title('LICOR latent heat for 1996');
ylabel('W/m^2');
xlabel('DOY')

[xsum,xmean] = integz(t(ind),LE(ind),td);           % find daily sums and averages for LE LICOR
[xksum,xkmean] = integz(t(indk),LEK(indk),td);      % find daily sums and averages for LE LICOR
figure(8)
plot(td,xmean,td,xkmean,'--')                       % plot daily averages for LE LICOR and KRYPTON
grid
title('Daily mean LE (LICOR & KRYPTON) for 1996');
ylabel('W/m^2');
xlabel('DOY')
%
% ------------------------------------------------------------------------------
%

%tile
