function [GillR21,GillR22]=two_R2s_tst(dateIn)

if ~exist('dateIn') | isempty(dateIn)
   dateIn = now;
end

fileName = ['d:\met-data\data\' FR_DateToFileName(FR_nextHHour(dateIn)) '.dc'];
GillR21 = FR_read_raw_data([fileName '1'],5,50000)/100;
GillR22 = FR_read_raw_data([fileName '3'],5,50000)/100;

figure(1)
plot([1:length(GillR21)]/20.83333,GillR21(3,:), ...
     [1:length(GillR22)]/20.83333,GillR22(3,:))
disp(sprintf('Mean w2/w1 = %2.6f',mean(GillR22(3,:))/mean(GillR21(3,:))))
disp(sprintf('Std w2/w1  = %2.6f', std(GillR22(3,:))/ std(GillR21(3,:))))

cup1 = sqrt(sum(GillR21(1:3,:).^2));
cup2 = sqrt(sum(GillR22(1:3,:).^2));
figure(2)
plot([1:length(GillR21)]/20.83333,cup1, ...
     [1:length(GillR22)]/20.83333,cup2)
disp(sprintf('Mean cup2/cup1 = %2.6f',mean(cup2)/mean(cup1)))
disp(sprintf('Std cup2/cup1  = %2.6f',std(cup2)/std(cup1)))

  



%figure(2)
%plot([1:length(GillR22)]/20.83333,GillR22(3,:), ...
%     [1:length(GillR21)]/20.83333,GillR21(3,:))