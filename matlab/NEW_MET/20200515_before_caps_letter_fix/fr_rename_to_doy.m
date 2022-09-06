function fileNameOut = fr_rename_to_doy(pth,fileNameIn,dateIn,optionX)
% renaming files by changing the file extension to DOY
%

if exist('dateIn')~=1 | isempty(dateIn)
    dateIn = now;
end
if exist('optionX')~=1 | isempty(optionX)
    optionX = 0;
end

[DOY1,Year1] = fr_get_doy(dateIn,0);
xDOY = int2str(floor(DOY1));
if optionX == 1
    xDOY = [int2str(Year1) xDOY];
end
fileNameOut = fileNameIn;
ind = find(fileNameIn == '.');
if ~isempty(ind)
    fileNameOut = fileNameIn(1:ind(end));
end
fileNameOut = [fileNameOut xDOY];
x = ['ren ' pth fileNameIn ' ' fileNameOut];
dos(x);


