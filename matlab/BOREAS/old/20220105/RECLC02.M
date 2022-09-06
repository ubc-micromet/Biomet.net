function [indX, OutDataX] = reclc02(pth, DayIn, FileExt)
% 
% [indX, OutDataX] = reclc02(pth, DayIn, FileExt)
%
%   Inputs:
%       pth         path for the raw data
%       DayIn       [Year Month Day] day that will be recalculated
%                   (from 6:00am GMT to 6:00am GMT the next day). Files that do NOT
%                   exits will be ommited.
%       FileExt     file name extension. Usualy 'n1' or 'n2'.
%
% Testing the recalculation procedure V.2.
%
%
% (c) Zoran Nesic           File created:       Feb  1, 1997
%                           Last modification:  Feb  6, 1997
%
mnth = [31 28 31 30 31 30 31 31 30 31 30 31];
YearX = DayIn(1);
if YearX > 10
    Year4dig = YearX;
    YearX = YearX - 1990;
else
    Year4dig = YearX + 1990;    
end
MonthX = DayIn(2);
DayX = DayIn(3);
DaysInMonth = mnth(MonthX);
if MonthX > 2 | ( MonthX == 2 & DayX == 28)
    DaysInMonth = DaysInMonth + leapyear(Year4dig);
end

MaxHHours = 48;
indX = [];
elpsTime = 0;
OutDataX = zeros(2*MaxHHours,100);
StartTimeAll = clock;
CurrentFile = 0;
FilesProcessed = 0;
NewDay = 0 ;
for HourX = [ 6:23 0:5]
    if HourX < 6 & NewDay == 0
        NewDay = 1;
        DayX = DayX + 1;
        if DayX > DaysInMonth
            MonthX = MonthX + 1;
            if MonthX > 12
                MonthX = 1;
                YearX = YearX + 1;
                Year4dig = Year4dig + 1;
            end
        end
    end         
    for hhour = 1:2
        FileName = [pth num2str(YearX) frmtnum(MonthX,2) frmtnum(DayX,2) frmtnum(HourX,2) num2str(hhour) '.' FileExt];
        CurrentFile = CurrentFile + 1;
        %disp(FileName)        
        if exist(FileName) == 2
            FilesProcessed = FilesProcessed + 1;
            disp(sprintf('File(%d of %d): %s',CurrentFile,48,FileName));
            StartTime = clock;
            %             [meansS, covsS,meansS1, covsS1,meansS2, covsS2,OutData,ind, RawData, header,EngUnits] ...
            [meansS, covsS,meansS1, covsS1,meansS2, covsS2,OutData,ind] ...
                      = recalc(FileName);
            indX = [ indX ind ];
            OutDataX((FilesProcessed-1)*2+1:FilesProcessed*2,:) = OutData;
            disp(sprintf('Elapsed time (file %d) = %f\n',CurrentFile,etime(clock,StartTime) ));
        end
    end
end

% remove missing hhours
OutDataX = OutDataX(1:FilesProcessed*2,:);

disp(sprintf('Total time for %d files: %f\n\n',FilesProcessed,etime(clock,StartTimeAll) ))

