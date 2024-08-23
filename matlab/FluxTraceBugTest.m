clear
close all
i = 1;
siteID = 'BB';
startY = 2023;
endY = 2024;

figure;
hold on;
title(siteID)

subRow = ceil((endY-startY)/2)+1;
subCol = 2;

for y = startY:endY
    [H,clean_tv] = read_db([y], siteID,'Flux','H');
    [LE,clean_tv] = read_db([y], siteID,'Flux','LE');
    [H_reproc,clean_tv2] = read_db([y], siteID,'epAutoRun_TestRun','H');
    [PARin,clean_tv] = read_db([y], siteID,'Met','MET_PARin_Avg');
    H(H <= -1000)=NaN;
    H_reproc(H_reproc <= -1000)=NaN;
    PARin(PARin <= -9999)=NaN;
    DT = datetime(clean_tv,"ConvertFrom","datenum");
    DT2 = datetime(clean_tv2,"ConvertFrom","datenum");
    subplot(subRow,subCol,i)
    plot(DT,PARin,DT,H,DT2,H_reproc);
    legend('PAR','H (Original)','H (Reprocessed)');
    grid on;
    xlim([datetime(y,7,4) datetime(y,7,8)]);
    title(sprintf('Import Year %i',y))
    i = i + 1;
end

[H,clean_tv] = read_db([startY:endY], siteID,'Flux','H');
[LE,clean_tv] = read_db([startY:endY], siteID,'Flux','LE');
[H_reproc,clean_tv2] = read_db([startY:endY], siteID,'epAutoRun_TestRun','H');
[PARin,clean_tv] = read_db([startY:endY], siteID,'Met','MET_PARin_Avg');
H(H <= -9999)=NaN;
H_reproc(H_reproc <= -1000)=NaN;
PARin(PARin <= -9999)=NaN;
DT = datetime(clean_tv,"ConvertFrom","datenum");
DT2 = datetime(clean_tv2,"ConvertFrom","datenum");
subplot(subRow,subCol,i)
plot(DT,PARin,DT,H,DT2,H_reproc);
legend('PAR','H (Original)','H (Reprocessed)');
grid on;
xlim([datetime(startY,7,4) datetime(startY,7,8)]);
title(sprintf('Importing Years %i-%i, zoomed to Jul %i',startY,endY,startY))

i = i + 1;

subplot(subRow,subCol,i)
plot(DT,PARin,DT,H,DT2,H_reproc);
legend('PAR','H (Original)','H (Reprocessed)');
grid on;
xlim([datetime(endY,7,4) datetime(endY,7,8)]);
title(sprintf('Importing Years %i-%i, zoomed to Jul %i',startY,endY,endY))


% Digging a bit further
% The issue could be related to duplicate values in Flux/clean_tv
f = fopen("\\vinimet.geog.ubc.ca\Database\2024\\BB\\Flux\\clean_tv");
tv24 = fread(f,'float64');
[u i j] = unique(tv24,'first');
indexToDupes = find(not(ismember(1:numel(tv24),i)));
ndups = length(indexToDupes)
for dupat = indexToDupes
    dupat
    replicates = tv24(tv24 == tv24(dupat))
end

% Plotting the difference between timestamps is shows a number of issues
% problems in the trace

figure
plot(diff(tv24))

% The duplicates aren't present in the time vector output from clean_tv?
% So it looks like the function is doing something wonky in relation to the
% duplicates
[H,clean_tv] = read_db([y], siteID,'Flux','H');
[u i j] = unique(clean_tv,'first');
indexToDupes = find(not(ismember(1:numel(clean_tv),i)));
ndups = length(indexToDupes)



% Plotting just H, shows that the raw traces line up and there isn't an
% issue with the actual data
f = fopen("\\vinimet.geog.ubc.ca\Database\2024\\BB\\Flux\\H");
H24 = fread(f,'float32');
f = fopen("\\vinimet.geog.ubc.ca\Database\2024\\BB\\epAutoRun_TestRun\\H");
H24_reproc = fread(f,'float32');
figure;
hold on;

plot(tv24,H24)
plot(tv24_reproc,H24_reproc)
legend('H (Original)','H (Reprocessed)')


