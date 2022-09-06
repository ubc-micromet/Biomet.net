% Sonics involved:
% Original Site R3 (S/N 10) or
% XSITE R3 (S/N ???)        xs
% New Site R3-50 (S/N ???)  nw

Stats_1 = xsite_load_comparison_data(datenum(2004,5,26),'bs_new_eddy');
Stats_2 = xsite_load_comparison_data(datenum(2004,5,28),'bs_new_eddy');
Stats_3 = xsite_load_comparison_data(datenum(2004,5,29:30),'bs_new_eddy');

h1 = fcrn_plot_sonic(Stats_1,[13],{'XSITE_CP','MainEddy'},{'Original-Xsite (1)','Original-Xsite (2)'});
% find_selected(h1,Stats_1)'
h2 = fcrn_plot_sonic(Stats_2,[13 44 46],{'XSITE_CP','MainEddy'},{'Original-New(1)','Original-New(2)'});
% find_selected(h2,Stats_2)'
h3 = fcrn_plot_sonic(Stats_3,[1 5 7 8 42:51],{'XSITE_CP','MainEddy'},{'New-Xsite (1)','New-Xsite (2)'});
% find_selected(h3,Stats_3)'

% Findings:
%
% Setup Date(GMT)   MainEddyBoom    XSITEBoom   u     u_var v_var w_var Hs   T_var
% 1     14-27(26)   or              xs          1.03  1.12  0.95  0.92  1.05 1.24
% 2     28          or              nw          0.995 1.08  0.98  0.90  0.99 1.10
% 3     29,30       nw              xs                1.04  0.99  0.88  0.87 0.90
%
% Notes:
% 1) The behaviour of temperature avg might differ due to temperature
%    spans
% 1) On 26 (OR-NW) Hs seven point out of 47 seem off the tight line
% 
% Overall:
% On May 29 11:02PM Zoran and Kai concluded that from the Table above, set
% ups 1 and 2, plus the first note that the Xsite and New sonic agree and
% the original is different