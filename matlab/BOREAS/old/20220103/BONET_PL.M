function [t,x] = bonet_pl(ind, year, fig_num_inc)
%
% [t,x] = bonet_pl(ind, year, fig_num_inc)
%
%   This function plots all data from the BONET data-logger files. It reads from
%   the UBC data-base formated files.
%
%
% (c) Nesic Zoran           File created:       May 24, 1997
%                           Last modification:  May 24, 1997
%
% Revisions:
%

if nargin < 3
    fig_num_inc = 1;
end
if nargin < 2
    year = 1997;
elseif year == []
    year = 1997;
end
if nargin < 1 
    error 'Too few imput parameters!'
end

GMTshift = 0.25;                                    % offset to convert GMT to CST
if year >= 1996
%    pth = 'h:\zoran\bor96\';
%    pth = 'r:\paoa\newdata\';
    pth = '\\class\c\paoa\newdata\';
    if exist('h:\zoran\paoa\paoa_dt') 
        EddyPth = 'h:\zoran\paoa\';
    else
        EddyPth = '\\boreas_003\paoa\';
    end
    axis1 = [340 400];
    axis2 = [-10 5];
    axis3 = [-50 250];
    axis4 = [-50 250];
else
    error 'Data for the requested year is not available!'
end

st = min(ind);                                      % first day of measurements
ed = max(ind);                                      % last day of measurements (approx.)

t=read_bor([ pth 'bonet\bnt_dt']);                  % get decimal time from the data base
if year == 1996
    offset_doy = 0;
elseif year == 1997
    offset_doy = 366;
else
    error 'Implementation of this software works until Dec 31, 1996')
end  
t = t - offset_doy + 1 - GMTshift;                  % convert decimal time to
                                                    % decimal DOY local time
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;

if 1==1

%-----------------------------------
%  BONET 5
%-----------------------------------
trace_name  = 'BONET #5, HMP1 Temperature ';
trace_path  = 'bonet\bnt.5';
trace_units = '(degC)';
y_axis      = [-40 30];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 6
%-----------------------------------
trace_name  = 'BONET #6, HMP1 RH ';
trace_path  = 'bonet\bnt.6';
trace_units = '(%)';
y_axis      = [-5 105];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 7
%-----------------------------------
trace_name  = 'BONET #7, Rn_Middleton';
trace_path  = 'bonet\bnt.7';
trace_units = '(W m-2)';
y_axis      = [-200 800];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 8
%-----------------------------------
trace_name  = 'BONET #8, PAR down at 36m';
trace_path  = 'bonet\bnt.8';
trace_units = '(W m-2)';
y_axis      = [-50 1800];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 9
%-----------------------------------
trace_name  = 'BONET #9, PAR up at 30m';
trace_path  = 'bonet\bnt.9';
trace_units = '(W m-2)';
y_axis      = [-50 400];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 10
%-----------------------------------
trace_name  = 'BONET #10, HMP 4 Temperature';
trace_path  = 'bonet\bnt.10';
trace_units = '(degC)';
y_axis      = [-40 30];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 11
%-----------------------------------
trace_name  = 'BONET #11, HMP 4 RH';
trace_path  = 'bonet\bnt.11';
trace_units = '(%)';
y_axis      = [-5 105];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause
end
%-----------------------------------
%  BONET 12
%-----------------------------------
trace_name  = 'BONET #12, PAR down 4m';
trace_path  = 'bonet\bnt.12';
trace_units = '(W m-2)';
y_axis      = [-50 1400];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 13
%-----------------------------------
trace_name  = 'BONET #13, VWC5 old';
trace_path  = 'bonet\bnt.13';
trace_units = '(????)';
y_axis      = [-10 120];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 14
%-----------------------------------
trace_name  = 'BONET #14, HMP 2 Temperature';
trace_path  = 'bonet\bnt.14';
trace_units = '(degC)';
y_axis      = [-40 30];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 15
%-----------------------------------
trace_name  = 'BONET #15, HMP 2 RH';
trace_path  = 'bonet\bnt.15';
trace_units = '(%)';
y_axis      = [-5 105];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 16
%-----------------------------------
trace_name  = 'BONET #16, HMP 3 Temperature';
trace_path  = 'bonet\bnt.16';
trace_units = '(degC)';
y_axis      = [-40 30];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 17
%-----------------------------------
trace_name  = 'BONET #17, HMP 3 RH';
trace_path  = 'bonet\bnt.17';
trace_units = '(%)';
y_axis      = [-5 105];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 18
%-----------------------------------
trace_name  = 'BONET #18, HMP 5 Temperature';
trace_path  = 'bonet\bnt.18';
trace_units = '(degC)';
y_axis      = [-40 30];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 19
%-----------------------------------
trace_name  = 'BONET #19, HMP 5 RH';
trace_path  = 'bonet\bnt.19';
trace_units = '(%)';
y_axis      = [-5 105];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
%  BONET 20
%-----------------------------------
trace_name  = 'BONET #20, SRC Rl down';
trace_path  = 'bonet\bnt.20';
trace_units = '(W m-2)';
y_axis      = [-50 500];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% Ref. gas tank pressure
%-----------------------------------
trace_name  = 'Ref. gas tank pressure';
trace_path  = 'bonet\bnt.51';
trace_units = '(kPa)';
y_axis      = [-2200 0];
fig_num = fig_num + fig_num_inc;
[x,tx] = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
ref_lim = -400;                             % lower limit for the ref. gas tank-pressure
px = polyfit(x,tx,1);                       % fit first order polynomial
px = polyval(px,ref_lim);                   % return DOY when tank is going to hit lower limit
ax = axis;
text(ax(1)+0.01*(ax(2)-ax(1)),-100,sprintf('Low limit(%5.1f) will be reached on DOY = %4.0f',ref_lim,px));
pause
%-----------------------------------
% Cal. zero gas tank pressure
%-----------------------------------
trace_name  = 'Cal. zero gas tank pressure';
trace_path  = 'bonet\bnt.52';
trace_units = '(kPa)';
y_axis      = [-1400 -1000];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause
%-----------------------------------
% Cal. 335ppm gas tank pressure
%-----------------------------------
trace_name  = 'Cal. 335ppm gas tank pressure';
trace_path  = 'bonet\bnt.53';
trace_units = '(kPa)';
y_axis      = [-1200 -800];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% Net radiation
%-----------------------------------
trace_name  = 'Net-radiation (Middleton)';
trace_path  = 'bonet\bnt.7';
trace_units = '(W/m^2)';
y_axis      = [-100 800];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% PAR down at 36m
%-----------------------------------
trace_name  = 'PAR down at 36m';
trace_path  = 'bonet\bnt.8';
trace_units = '(W/m^2)';
y_axis      = [ -50 1800];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% Rs down at 36m
%-----------------------------------
trace_name  = 'Rs down at 36m';
trace_path  = 'bonet\bnt.22';
trace_units = '(W/m^2)';
y_axis      = [-50 1000];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% Rs up at 30m
%-----------------------------------
trace_name  = 'Rs up at 30m';
trace_path  = 'bonet\bnt.23';
trace_units = '(W/m^2)';
y_axis      = [-50 600];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% Rl down at 36m
%-----------------------------------
trace_name  = 'Rl down at 36m';
trace_path  = 'bonet\bnt.24';
trace_units = '(W/m^2)';
y_axis      = [-50 600];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% Bolic2: CO2
%-----------------------------------
trace_name  = 'Bolic2: CO2';
trace_path  = 'bolic2\bol2.5';
trace_units = '(umol/mol)';
y_axis      = [350 380];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% Bolic2: H2O
%-----------------------------------
trace_name  = 'Bolic2: H2O';
trace_path  = 'bolic2\bol2.6';
trace_units = '(mmol/mol)';
y_axis      = [-5 25];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% Bolic2: Sample cell air temp.
%-----------------------------------
trace_name  = 'Bolic2: Sample cell air temp.';
trace_path  = 'bolic2\bol2.8';
trace_units = '(degC)';
y_axis      = [30 40];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% Bolic2: Metal box air temp.
%-----------------------------------
trace_name  = 'Bolic2: Metal box air temp.';
trace_path  = 'bolic2\bol2.9';
trace_units = '(degC)';
y_axis      = [30 40];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% Bolic2: Optical bench temp.
%-----------------------------------
trace_name  = 'Bolic2: Optical bench temp.';
trace_path  = 'bolic2\bol2.10';
trace_units = '(degC)';
y_axis      = [39 45];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% Bolic2: Sample cell gauge pressure
%-----------------------------------
trace_name  = 'Bolic2: Sample cell gauge pressure';
trace_path  = 'bolic2\bol2.11';
trace_units = '(kPa)';
y_axis      = [15 20];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%-----------------------------------
% Bolic2: Reference cell gauge pressure
%-----------------------------------
trace_name  = 'Bolic2: Reference cell gauge pressure';
trace_path  = 'bolic2\bol2.12';
trace_units = '(kPa)';
y_axis      = [.3 .34];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
pause

%---------------------------------------------------------------
% Temperature comparison: HMP, PRT, thermocouple and Gill at 36m
%---------------------------------------------------------------
trace_name  = 'Temperature comparison';
trace_path  = str2mat([pth 'bonet\bnt.5'],[pth 'eddy\eddy.12'], [EddyPth 'paoa_8.2_2'],[pth 'aesmet\met.10']);
trace_legend= str2mat('HMP','TC','Gill','Tair');
trace_units = '(degC)';
y_axis      = [-10 35];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1], [0 273.16 0 0] );
pause

%---------------------------------------------------------------
% w^T comparison: Thermocouple and Gill at 36m
%---------------------------------------------------------------
trace_name  = 'w^T comparison';
trace_path  = str2mat([pth 'eddy\eddy.42'],[pth 'eddy\eddy.31'], [EddyPth 'paoa_45.2_2']);
trace_legend= str2mat('TC','Gill','GillPC');
trace_units = '(degC m/s)';
y_axis      = [-0.1 0.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
pause
end
%---------------------------------------------------------------
% Soil heat-flux plates
%---------------------------------------------------------------
trace_name  = 'Soil heat-flux plates';
trace_path  = str2mat([pth 'aessoil\soil.16'],[pth 'aessoil\soil.19'],[pth 'aessoil\soil.21'],[pth 'aessoil\soil.22'],[pth 'aessoil\soil.23'],[pth 'aessoil\soil.24'],[pth 'aessoil\soil.25']);
trace_legend= str2mat('S1','S4','S6','S7','S8','S9','S10');
trace_units = '(W/m^2)';
y_axis      = [-10 60];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1 1 1], [0 0 0 0 0 0 0]);
pause
%---------------------------------------------------------------
% Closure 1 (plot H, LE, Rn)
%---------------------------------------------------------------
trace_name  = 'Closure';
trace_path  = str2mat([EddyPth 'paoa_81.2_2'],[EddyPth 'paoa_82.2_2'], [pth 'bonet\bnt.7'],[pth 'eddy\eddy.42']);
trace_legend= str2mat('H','LE','Rn','Htc');
trace_units = '(W/m^2)';
y_axis      = [-200 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1150], [0 0 0 0]);
pause
%---------------------------------------------------------------
% Closure 2 (plot H+LE, Rn)
%---------------------------------------------------------------
% trace_name  = 'Closure';
% H  = read_bor([EddyPth 'paoa_81.2_2']);
% LE = read_bor([EddyPth 'paoa_82.2_2']);
% trace_path  = str2mat(H+LE, [pth 'bonet\bnt.7']);
% trace_legend= str2mat('H+LE','Rn');
% trace_units = '(W/m^2)';
% y_axis      = [-200 1000];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
% pause

%---------------------------------------------------------------
% LE LICOR vs Krypton 
%---------------------------------------------------------------
trace_name  = 'LE LICOR vs Krypton';
trace_path  = str2mat([EddyPth 'paoa_82.2_2'],[EddyPth 'paoa_83.2_2']);
trace_legend= str2mat('LE 6262','LE KH2O');
trace_units = '(W/m^2)';
y_axis      = [-100 300];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1], [0 0 0 0]);
pause

%----------------------------------------------------------
% Temperature profile using HMP data
%----------------------------------------------------------
trace_name  = 'Temperature profile using HMP data';
trace_path  = str2mat([pth 'bonet\bnt.5'],[pth 'bonet\bnt.16'],[pth 'bonet\bnt.18']);
trace_legend= str2mat('36m','18m','5m');
trace_units = '(degC)';
y_axis      = [-10 35];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
pause

%----------------------------------------------------------
% Barometric pressure
%----------------------------------------------------------
trace_name  = 'Barometric pressure';
trace_path  = str2mat([pth 'aesmet\met.12'],[pth 'bolic1\bol1.7'],[EddyPth 'paoa_12.2_2']);
trace_legend= str2mat('AES','UBC_CSI','UBC_Gill');
trace_units = '(kPa)';
y_axis      = [90 98];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num, [0.1 1 1] );

end