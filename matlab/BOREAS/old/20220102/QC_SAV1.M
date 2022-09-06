pth = 'd:\cd-rom\rawdata\';
YearX = 1997;
MonthX = 4;
DayX = 2;
HourX = 18;
HHour = 1;
ext = 'n2';
OutputFileNameSt = 'data';
file_ext = '.dat';
for i = 1:4
    OutputFileName = [pth OutputFileNameSt frmtnum(i,3) file_ext];
    qc_exprt(OutputFileName,pth,YearX,MonthX,DayX,HourX,HHour,ext);
%    [YearX,MonthX,DayX,HourX,HHour]
    if HHour == 1
        HHour = 2;
    else
        HHour = 1;
        HourX = HourX +1;
        if HourX > 23
            HourX = 0;
            DayX = DayX + 1;
            % this routine does not work over the end of month
        end
    end
end
    