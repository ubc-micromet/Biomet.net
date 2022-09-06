function [Tbench_correction] = get_eddy_Tbench_corr(siteID,years);

% Program to determine correction for licor outputs when
% microcontroller is off and causes Tbench to be wrong
%
%
% E.Humphreys  -Modified slightly from Eva's program:
% Dec 3, 2001

if upper(siteID) ~= 'CR'
    return
end

if ~exist('years') | isempty(years);
    years = 1998;
end

ptha  = biomet_path('yyyy',siteID,'cl');
pth   = biomet_path('yyyy',siteID,'fl');

GMT_shift = 8/24;       %shift grenich mean time to 24hr day
tv = read_bor([ ptha 'fr_a\fr_a_tv'],8,[],years); 
indOut = [];

Tbox   = read_bor([ptha 'fr_c\fr_c.9'],[],[],years,indOut);
Tbench = read_bor([pth 'avgar.49'],[],[],years,indOut);

try,
    irga_flag = read_bor([pth 'misc.irga_flag1'],[],[],years,indOut);
    
    microcontroller_flag = bitget(irga_flag,2);
    indbad_m   = find(microcontroller_flag == 1); %microcontroller off
    indok_m    = find(microcontroller_flag ~= 1); %microcontroller ok
catch
    inbad_m = find(Tbench > 10 & Tbench < 12);
    indok_m = [];
end

c = fr_get_init(siteID,datenum(1998,9,1));
[cp,hp,Tc,Th,pp] = licor(c.licor);

% Select times when thermostat doesn't work, but temperature output of licor is OK
indbad = find(tv >= datenum(1998,9,12) & tv <= datenum(1998,12,18));

% Get regression between box temperature and optical bench temperature
% and eliminate incorrect data
ss = find(Tbox(indbad) >5 & Tbench(indbad) >5);
[p, R2, sigma, s, Y_hat] = polyfit1(Tbox(indbad(ss)), Tbench(indbad(ss)), 1);

%Calculate correction factor for wrong concentrations/fluxes
T1  = Tbench; %incorrect bench temperature
T2  = p(1).* Tbox + p(2);  %'correct' bench temperature, extrapolated from box temperature

% Replace incorrect concentrations/fluxes with corrected concentrations/fluxes
Tbench_correction = ones(size(Tbox));
Tbench_correction_tmp = (Tc + 273.15)./(T1 + 273.15) .* (T2 + 273.15)./(Tc + 273.15);
Tbench_correction(indbad_m) = Tbench_correction_tmp(indbad_m);
ind = find(abs(Tbench_correction) > 2);
Tbench_correction(ind) = 1;

ind_1999 = find(tv >= datenum(1999,1,1)  & tv < datenum(2000,1,1));
Tbench_correction = Tbench_correction(ind_1999);

return
t = tv-datenum(1998,1,1)+1;
fig = 0;
fig = fig+1;figure(fig);clf;
plot(t,Tbench,t,Tbox,...
    t(indbad_m),Tbench(indbad_m),'o',...
    t(indbad),Tbench(indbad),'x');
zoom on;

fig = fig+1;figure(fig);clf;
plot(Tbox(indbad(ss)), Tbench(indbad(ss)),'.',...
    Tbox(indbad(ss)),polyval(p,Tbox(indbad(ss))),'.');
zoom on;

fig = fig+1;figure(fig);clf;
plot(t,Tcorr);
zoom on;