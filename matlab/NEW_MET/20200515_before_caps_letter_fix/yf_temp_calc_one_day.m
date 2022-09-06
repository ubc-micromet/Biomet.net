function Stats = yf_temp_calc_one_day(dateIn)
% E. Humphreys  Sept 18, 2001

[yearX,monthX,dayX ] = datevec(dateIn);

hhours = 48;
currentDate = datenum(yearX,monthX,dayX,0,30,0);

for i = 1:hhours;
    tic
    [Stats(i),IRGA,IRGA_h,GillR3]= yf_temp_calc_hhour(currentDate);
    disp(sprintf('%s,  (%d/%d), time = %4.2f (s)',datestr(currentDate),i,hhours,toc));    
    currentDate     = FR_nextHHour(currentDate);    
end

