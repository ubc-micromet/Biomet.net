% script that compares different methods of WPL correction 
% applied to ALO data (Brian Amiro)
%cd 'C:\Documents and Settings\zoran\Desktop\KaiWPL'
%clear;[H_hh,Fc_hh,LE_hh,tv_hh,H_hf,Fc_hf,LE_hf,Ta] = test_alberto_func; save d:\kai_test_new
%clear
%cd D:\PAOA001\NZ\MATLAB\CurrentProjects\NEW_EDDY
%[Stats_Mix,HF_Data] = yf_calc_module_main(datenum(2003,9,3,1,0:30:1200,0),'ALO');save d:\elyn_test_new;
%clear
load d:\kai_test_new;
load d:\elyn_test_new
%Stats_Mix = Stats_test;


%tv_hh = tv;
clear tv_Mix H_Mix LE_Mix Fc_Mix
k=10:length(Stats_Mix);
for i=k;
    ind = i-k(1)+1;
    tv_Mix(ind)=Stats_Mix(i).TimeVector;
    H_Mix(ind) = Stats_Mix(i).MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs;
    LE_Mix(ind) = Stats_Mix(i).MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L;
    Fc_Mix(ind) = Stats_Mix(i).MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc;
end;

clear tv_WPLe H_WPLe LE_WPLe Fc_WPLe;
for i=k;
    ind = i-k(1)+1;
    tv_WPLe(ind)=Stats_Mix(i).TimeVector;
    H_WPLe(ind) = Stats_Mix(i).MainEddy.WPLFluxes.Hs;
    LE_WPLe(ind) = Stats_Mix(i).MainEddy.WPLFluxes.LE_L;
    Fc_WPLe(ind) = Stats_Mix(i).MainEddy.WPLFluxes.Fc;
end;

figure(1)
plot(tv_Mix-datenum(2003,9,1),Fc_Mix,...
     tv_Mix-datenum(2003,9,1),Fc_WPLe,...
     tv_hh-datenum(2003,9,1),Fc_hh,...
     tv_hh-datenum(2003,9,1),Fc_hf,'linewi',2);
legend('HF_z','HH_e','HH_k','HF_k')
zoom on

figure(2)
plot(tv_Mix-datenum(2003,9,1),H_Mix,...
     tv_Mix-datenum(2003,9,1),H_WPLe,...
     tv_hh-datenum(2003,9,1),H_hh,...
     tv_hh-datenum(2003,9,1),H_hf,'linewi',2);
legend('HF_z','HH_e','HH_k','HF_k')
zoom on

figure(3)
plot(tv_Mix-datenum(2003,9,1),LE_Mix,...
     tv_Mix-datenum(2003,9,1),LE_WPLe,...
     tv_hh-datenum(2003,9,1),LE_hh,...
     tv_hh-datenum(2003,9,1),LE_hf,'linewi',2);
legend('HF_z','HH_e','HH_k','HF_k')
zoom on

%[Stats_ManualWPL,HF_Data] = yf_calc_module_main(datenum(2003,9,3,1,0:30:1200,0),'ALO_1');



