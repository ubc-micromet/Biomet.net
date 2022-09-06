function yf_calc_and_save(dateRange)

pth = 'd:\met-data\hhour\';
for i = floor(dateRange)
    try
        t0 = now;
        Stats = yf_temp_calc_one_day(i);
%Stats = [];
        FileName_p      = FR_DateToFileName(i+.2);
        FileName        = [pth FileName_p(1:6) '.hy.mat'];    % File name for the full set of stats
        save(FileName,'Stats');
        [Stats(:).BeforeRot] = deal([]);
        FileName        = [pth FileName_p(1:6) 's.hy.mat'];    % File name for the short set of stats
        save(FileName,'Stats');
        disp(sprintf('Day: %s. Calc time = %d seconds',datestr(i),(now-t0)*24*60*60));
    end
end
