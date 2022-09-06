%===============================================================
function nextDate = FR_prevHHour(currentDate)
%===============================================================

    [yearX,monthX,dayX, ...
     hourX,minuteX]             = datevec(currentDate);
 
    nextDate                    = datenum(yearX,monthX,...
                                          dayX,hourX,...
                                          minuteX-30,0);

