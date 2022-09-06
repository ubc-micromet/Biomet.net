function [IRGA,IRGA_h,GillR3]= yf_plt_now(dateIn)

if ~exist('dateIn') | isempty(dateIn)
   dateIn = now;
end

fileName = ['d:\met-data\data\' FR_DateToFileName(dateIn) '.dy'];

[IRGA, IRGA_h] = fr_read_RS232data([fileName '4']);
%for i = 1:IRGA_h.numOfChann
GillR3 = FR_read_raw_data([fileName '3'],5,50000)'/100;

[del_1,del_2] = ...
    fr_find_delay(IRGA', GillR3',[3 4],1000,[-60 60]);
[IRGA, GillR3]= ...
    fr_remove_delay(IRGA', GillR3',del_1,del_2);
IRGA = IRGA';
GillR3 = GillR3';