% Load data example

siteID = 'DSM';
Year = 2022;

pth = '/Users/sara/Library/CloudStorage/OneDrive-UBC/UBC/database';
Stage = 'Flux/clean';

var = 'clean_tv';
if strcmp(siteID,'DSM')||strcmp(siteID,'RBM')
    tv=read_bor(fullfile(pth,num2str(Year),siteID,'Flux/clean',var),8,[],Year);
else
    tv=read_bor(fullfile(pth,num2str(Year),siteID,'Met/clean',var),8,[],Year);
end

pth = '/Volumes/Projects/Database/';
Stage = 'Flux';

var = 'sonic_temperature';
T_SONIC=read_bor(fullfile(pth,num2str(Year),siteID,Stage,var),[],[],Year);
plot(tv, T_SONIC)

pth = '/Users/sara/Library/CloudStorage/OneDrive-UBC/UBC/database';
Stage = 'Flux/clean';

var = 'T_SONIC';
T_SONIC=read_bor(fullfile(pth,num2str(Year),siteID,Stage,var),[],[],Year);
plot(tv, T_SONIC)

var = 'H';
H=read_bor(fullfile(pth,num2str(Year),siteID,Stage,var),[],[],Year);
plot(tv, H)

var = 'CH4_MIXING_RATIO';
CH4_MIXING_RATIO=read_bor(fullfile(pth,num2str(Year),siteID,Stage,var),[],[],Year);
plot(tv, CH4_MIXING_RATIO)







var = 'LE';
spikes_hf_5=read_bor(fullfile(pth,num2str(Year),siteID,SecondStage,var),[],[],Year);

plot(tv, spikes_hf_5)

var = 'FCH4';

FCH4=read_bor(fullfile(pth,num2str(Year),siteID,'clean/ThirdStage',var),[],[],Year);

ind = find(spikes_hf_2 == 1);
var = 'FCH4_PI_F_RF';

FCH4=read_bor(fullfile(pth,num2str(Year),siteID,SecondStage,var),[],[],Year);

var = 'NEE';

NEE=read_bor(fullfile(pth,num2str(Year),siteID,'clean/SecondStage',var),[],[],Year);

%NEE = sum([FC,SC],2,'omitnan');
%NEE(all(isnan(FC)&isnan(SC),2)) = NaN;

plot(tv, [FC, SC, NEE])

siteID = 'DSM';
pth = '/Users/sara/Library/CloudStorage/OneDrive-UBC/UBC/database';
SecondStage = 'clean/ThirdStage';
Year = 2022;

var = 'clean_tv';
if strcmp(siteID,'DSM')||strcmp(siteID,'RBM')
    tv=read_bor(fullfile(pth,num2str(Year),siteID,'clean/ThirdStage',var),8,[],Year);
else
    tv=read_bor(fullfile(pth,num2str(Year),siteID,'clean/ThirdStage',var),8,[],Year);
end

var = 'test';

test=read_bor(fullfile(pth,num2str(Year),siteID,SecondStage,var),[],[],Year);


var = 'TA_1_1_1';

TA_1_1_1=read_bor(fullfile(pth,num2str(Year),siteID,SecondStage,var),[],[],Year);

var = 'T_SONIC';

T_SONIC=read_bor(fullfile(pth,num2str(Year),siteID,'Flux/clean',var),[],[],Year);

plot(tv, [TA_1_1_1, T_SONIC])

[data_out_neg1, flag] = calc_avg_trace(tv, [T_SONIC,TA_1_1_1], TA_1_1_1,-1);
[data_out14, flag] = calc_avg_trace(tv, [T_SONIC,TA_1_1_1], TA_1_1_1, 14);
[data_out0, flag] = calc_avg_trace(tv, [T_SONIC,TA_1_1_1]);

figure
 plot(tv, [TA_1_1_1, data_out_neg1,data_out14,data_out0,T_SONIC],'.-')
 hold on
 plot(tv, TA_1_1_1, 'k','LineWidth',2)
 plot(tv, data_out0, 'r','LineWidth',2)
legend('TA', 'data out neg1 ','data out14','data out0','T_SONIC')

[data_out_neg1, flag] = calc_avg_trace(tv, T_SONIC, TA_1_1_1,-1);
[data_out14, flag] = calc_avg_trace(tv, T_SONIC, TA_1_1_1, 14);
[data_out0, flag] = calc_avg_trace(tv, T_SONIC, TA_1_1_1, 0);

figure
 plot(tv, [TA_1_1_1, data_out_neg1,data_out14,data_out0,T_SONIC],'.-')
 hold on
 plot(tv, TA_1_1_1, 'k','LineWidth',2)
 plot(tv, data_out0, 'r','LineWidth',2)
legend('TA', 'data out neg1 ','data out14','data out0','T_SONIC')