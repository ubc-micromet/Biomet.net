function dataOut = load_data(varStruct,pth,Years)

dataOut = [];
for i=1:length(varStruct)
    try
        varTemp = read_bor(fullfile(pth,varStruct(i).type,varStruct(i).name),[],[],Years);
    catch
        % if there is missing data go one year at the time and replace
        % the missing data with vectors of NaN-s
        varTemp = [];
        indY = strfind(lower(pth),'yyyy');
        for j=1:length(Years)
            pthTemp = pth;
            pthTemp(indY:indY+3) = num2str(Years(j));
            pthFile = fullfile(pthTemp,varStruct(i).type,varStruct(i).name);
            if exist(pthFile,'file')
                temp = read_bor(fullfile(pth,varStruct(i).type,varStruct(i).name),[],[],Years(j));
            else
                daysInYear= (365+leapyear(Years(j)));
                temp = NaN(daysInYear*48,1);
            end
            varTemp = [varTemp ; temp];
        end
    end
    dataOut = [dataOut varTemp]; %#ok<*AGROW>
end
end