function fig_num = pa_tctrl(ind,year)
%
% fig_num = pa_tctrl(ind,year)
%
%   This function plots the temperature controler performance for the LICOR
%   box. data for PA OS site
%   using UBC data-base formated files. Years 1996-1997 only.
%
%
% (c) Nesic Zoran           File created:       Jun 17, 1997
%                           Last modification:  Jun 17, 1997

%
% Revisions:
%
pa_glob;
global DATA_PATH_1996_PA_1
FileName = [DATA_PATH_1996_PA_1 '\bonet\bnt.55'];
rg = read_bor(FileName);
rg_cumulative = cumsum(rg);
FileName = [DATA_PATH_1996_PA_1 '\bonet\bnt_dt'];
t = read_bor(FileName) +0.75;                           % Decimal DOY
if year == 1997
    t = t - 366;
end
fig_num = figure;
set(fig_num,'position',[15 288 992 420]);
plot(t(ind),rg_cumulative(ind))
ax = axis;
axis([t(ind(1)) t(ind(length(ind))) ax(3:4)])
%plot(t(ind),rg(ind))
title('Cumulative rain')
xlabel('DOY')
ylabel('mm of rain')
grid


