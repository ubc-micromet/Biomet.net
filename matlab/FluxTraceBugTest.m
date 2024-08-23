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
    fprintf('%.7f\n',length(clean_tv))
    fprintf('%.7f\n',min(clean_tv))
    fprintf('%.7f\n',length(clean_tv2))
    fprintf('%.7f\n',min(clean_tv2))
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


