%===============================================================
function FileName_p = fr_DateToFileName(currentDate)
%===============================================================

% Revisions
%
% Nov 29, 2017 (Zoran)
%   - changed the date formatting to avoid using Biomet frmtnum.m
%     function in hope of increasing the speed
%   - vectorized the function
%

    [yearX,monthX,dayX, ...
     hourX,minuteX]             = datevec(currentDate);
 
    ind = (hourX == 0 & minuteX < 30);
    %if ~isempty(ind)
        hourX(ind) = 24;
        [yearX(ind),monthX(ind),dayX(ind), ...
         junk1,junk2]           = datevec(currentDate(ind)-1);
%    end
    hhour = hourX * 2 + floor( minuteX / 30 );
    
    if yearX < 2000
        yearShort = yearX - 1900;
    else
        yearShort = yearX - 2000;
    end

    %FileName_p = [frmtnum(yearShort,2), frmtnum(monthX,2) ...
    %              frmtnum(dayX,2) frmtnum(hhour*2,2)];
 
    FileName_p = sprintf('%02d%02d%02d%02d',[yearShort monthX dayX hhour*2]');
    FileName_p = reshape(FileName_p, 8,[])';

