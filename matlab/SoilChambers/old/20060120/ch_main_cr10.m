% main program for cr10 data retrieval and analysis
[data_cr10,timeSer_cr10,fileNames_cr10] = ch_read('c:\temp\chambers\data\cr10','*.prn');
% ch_pl_cr10(timeSer_CR10,data_CR10,8)
ch_pl_cr10(timeSer_cr10,data_cr10,8,1)
% note if the fourth input argument in ch_pl_cr10 exists (not equal to zero) then the x axis 
% will be in minutes, not days since the beginning of August
% ax = axis;
% [slope_1, slope_2, slope_avg]= ch_slope_cr10 (ax(1), ax(2), timeSer_CR10,data_CR10)
