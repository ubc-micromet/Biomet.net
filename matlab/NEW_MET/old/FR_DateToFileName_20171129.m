%===============================================================
function FileName_p = FR_DateToFileName(currentDate)
%===============================================================
    [yearX,monthX,dayX, ...
     hourX,minuteX]             = datevec(currentDate);
 
    if hourX == 0 & minuteX < 30
        hourX = 24;
        [yearX,monthX,dayX, ...
         junk1,junk2]           = datevec(currentDate-1);
    end
    hhour = hourX * 2 + floor( minuteX / 30 );
    
    if yearX < 2000
        yearShort = yearX - 1900;
    else
        yearShort = yearX - 2000;
    end

    FileName_p = [frmtnum(yearShort,2), frmtnum(monthX,2) ...
                  frmtnum(dayX,2) frmtnum(hhour*2,2)];


