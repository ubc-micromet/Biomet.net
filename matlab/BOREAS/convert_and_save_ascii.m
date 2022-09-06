function convert_and_save_ascii(pthIn, DayIn, FileExt,pthOut)
% 
% This function gets all the raw data for a particular day, converts it
% into eng. units and saves them in ascii files. 
% The output file names are the same as the input file names but with no extensions.
%
%   Inputs:
%       pthIn       path for the raw data (source)
%       DayIn       [Year Month Day] day that will be recalculated
%                   (from 6:00am GMT to 6:00am GMT the next day). Files that do NOT
%                   exits will be ommited.
%       FileExt     file name extension. Usualy 'n1' or 'n2'.
%       pthOut      path for the output data (ascii format)
%
%
%
% (c) Zoran Nesic           File created:       Dec 8, 1999
%                           Last modification:  Dec 8, 1999
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
        FileName = [pthIn num2str(YearX) frmtnum(MonthX,2) frmtnum(DayX,2) frmtnum(HourX,2) num2str(hhour) '.' FileExt];
        CurrentFile = CurrentFile + 1;
        %disp(FileName)        
        if exist(FileName) == 2
            FilesProcessed = FilesProcessed + 1;
            disp(sprintf('File(%d of %d): %s',CurrentFile,48,FileName));
            StartTime = clock;
            %             [meansS, covsS,meansS1, covsS1,meansS2, covsS2,OutData,ind, RawData, header,EngUnits] ...
            EngUnits = get_eng_units(FileName);
            FileNameOut = [pthOut num2str(YearX) frmtnum(MonthX,2) frmtnum(DayX,2) frmtnum(HourX,2) num2str(hhour)];
            fid = fopen(FileNameOut,'wt');
            [n,m]=size(EngUnits);
            ff = [];
            for i=1:n
                ff = [ff ' %8.4f'];
            end
            ff = [ff '\n'];
            fprintf(fid,ff,EngUnits);
            fclose(fid);          
            disp(sprintf('Elapsed time (file %d) = %f\n',CurrentFile,etime(clock,StartTime) ));
        end
    end
end

disp(sprintf('Total time for %d files: %f\n\n',FilesProcessed,etime(clock,StartTimeAll) ))

