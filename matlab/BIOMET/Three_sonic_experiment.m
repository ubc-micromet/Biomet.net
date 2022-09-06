% output path
outPth = 'c:\MatlabR11\work\';
%outPth = '\\cr002\d\met-data\data\';
% load test data from the 3-sonic experiment (Apr 11, 2001)
CSAT1 = load('\\cr002\d\met-data\data\04111206.TXT')';
for i = 1:9
    ind = find(abs(CSAT1(i,:)) > 70);
    ind1 = find(abs(CSAT1(i,:)) <= 70);
    x = CSAT1(i,ind1);
    CSAT1(i,ind) = interp1(ind1,x,ind);
end

%[RawData_R2,TotalSamples,SamplesRead]  =  FR_read_raw_data('\\cr002\d\met-data\data\01041152.dp2',5,50000);
%R2 = fr_GillR2_calc([0.01, 0; 0.02 0],RawData_R2,0,1);  % convert to eng units, resample to 20Hz

%[RawData_R3,TotalSamples,SamplesRead]  =  FR_read_raw_data('\\cr002\d\met-data\data\01041152.dp3',5,50000);
%R3 = fr_GillR3_calc([0.01, 0; 0.01 -273.15],RawData_R3,0);  % convert to eng units

firstPoint = 27922;
CSAT = CSAT1(:,1:firstPoint-1);
save([outPth '01041150'],'CSAT')
CSAT = CSAT1(:,firstPoint:firstPoint+36000-1);
save([outPth '01041152'],'CSAT')
CSAT = CSAT1(:,firstPoint+36000:end);
save([outPth '01041154'],'CSAT')


CSAT2 = load('\\cr002\d\met-data\data\04111330.TXT')';
for i = 1:9
    ind = find(abs(CSAT2(i,:)) > 70);
    ind1 = find(abs(CSAT2(i,:)) <= 70);
    x = CSAT2(i,ind1);
    CSAT2(i,ind) = interp1(ind1,x,ind);
end

%[RawData_R2,TotalSamples,SamplesRead]  =  FR_read_raw_data('\\cr002\d\met-data\data\01041156.dp2',5,50000);
%R2 = fr_GillR2_calc([0.01, 0; 0.02 0],RawData_R2,0,1);  % convert to eng units, resample to 20Hz
%
%[RawData_R3,TotalSamples,SamplesRead]  =  FR_read_raw_data('\\cr002\d\met-data\data\01041156.dp3',5,50000);
%R3 = fr_GillR3_calc([0.01, 0; 0.01 -273.15],RawData_R3,0);  % convert to eng units

lastPoint = 140;
CSAT = CSAT2(:,1:36000-lastPoint);
save([outPth '010411' num2str(56)],'CSAT');
for i = 2:4
    CSAT = CSAT2(:,(i-1)*36000-lastPoint+1:i*36000-lastPoint);
    save([outPth '010411' num2str(56+(i-1)*2)],'CSAT');
end



% Plot the results
for i=1:7
    fileName = [outPth '010411' num2str(50+(i-1)*2)];
    load(fileName)
    [RawData_R2,TotalSamples,SamplesRead]  =  FR_read_raw_data([fileName '.dp2'],5,50000);
    R2 = fr_GillR2_calc([0.01, 0; 0.02 0],RawData_R2,0,1);  % convert to eng units, resample to 20Hz
    [RawData_R3,TotalSamples,SamplesRead]  =  FR_read_raw_data([fileName '.dp3'],5,50000);
    R3 = fr_GillR3_calc([0.01, 0; 0.01 -273.15],RawData_R3,0);  % convert to eng units
    figure(1)
    plot(CSAT(4,:));hold on;
    plot(R3(4,:)+6.3,'r');
    plot(R2(4,:)+5.5,'g');hold off
    title(fileName)
    ylabel('Temperature')
    pause
end