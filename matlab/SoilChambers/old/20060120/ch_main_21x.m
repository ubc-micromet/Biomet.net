% main program for 21x data retrieval and analysis
[data_21x,timeSer_21x,filenames_21x] = ch_read('d:\chambers_data','measure*.prn');
% ch_pl_21x(timeSer_21x,data_21x,8)
if length(filenames_21x) == 0
    error 'Wrong file path, Gord!'
else
    ch_pl_21x(timeSer_21x,data_21x,8,2)
end
% note if the fourth input argument in ch_pl_21x exists (not equal to zero) then the x axis 
% will be in minutes, not days since the beginning of August


% ax = axis;
% [slope_1, slope_2, slope_avg]= ch_slope_cr10 (ax(1), ax(2), timeSer_CR10,data_CR10)