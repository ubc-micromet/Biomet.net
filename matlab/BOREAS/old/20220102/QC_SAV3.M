pth = 'd:\cd-rom\rawdata\';
YearX = 1996;
MonthX = 7;
DayX = 24;
HourX = 3;
HHour = 1;
ext = 'n2';
OutputFileNameSt = 'datax';
file_ext = '.dat';
for i = 1:6
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
    