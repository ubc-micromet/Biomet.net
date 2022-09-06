function climateStation_TF_radiation_time_correction
%
% This function shifts data forward (PST to GMT) by 8 hours (16 samples)
% It will be used only once to convert TF_Radiation logger data from
%

% this program is disabled to avoid multiple database modifications
error('DO NOT USE THIS PROGRAM!')
return
%===========================================
%

%% First load all data from 2017 - 2020
yearsIn = 2017:2020;
pathIn = biomet_path('yyyy','UBC_Totem','Radiation\30min');

tv_GMT = read_bor(fullfile(pathIn,'clean_tv'),8,[],yearsIn);

% load data first
MET_Ap_Quan_Avg = read_bor(fullfile(pathIn,'MET_Ap_Quan_Avg'),[],[],yearsIn);
MET_NRlite_Nrad_Avg = read_bor(fullfile(pathIn,'MET_NRlite_Nrad_Avg'),[],[],yearsIn);
MET_PIR_LWi_Avg = read_bor(fullfile(pathIn,'MET_PIR_LWi_Avg'),[],[],yearsIn);
MET_PIR_LWo_Avg = read_bor(fullfile(pathIn,'MET_PIR_LWo_Avg'),[],[],yearsIn);
MET_PSP_albedo_Avg = read_bor(fullfile(pathIn,'MET_PSP_albedo_Avg'),[],[],yearsIn);
MET_PSP_SWi_Avg = read_bor(fullfile(pathIn,'MET_PSP_SWi_Avg'),[],[],yearsIn);
MET_PSP_SWo_Avg = read_bor(fullfile(pathIn,'MET_PSP_SWo_Avg'),[],[],yearsIn);
MET_PSPPIR_Nrad_Avg = read_bor(fullfile(pathIn,'MET_PSPPIR_Nrad_Avg'),[],[],yearsIn);
RECORD = read_bor(fullfile(pathIn,'RECORD'),[],[],yearsIn);

% % test pushing forward the bad change of data
% % Bad clock Oct 24, 2017 00:00 GMT - Apr 13, 2020 00:30 GMT
% % Had to push it forward by 14 points (7 hours). I am not sure why
% % 7 hours and not 8 (PST+8 = GMT) but this is what works.
% ind_PST = find(tv_GMT>=datenum(2017,10,24,0,0,0) & tv_GMT<datenum(2020,4,13,0,30,0));
% tmp = MET_PSP_SWi_Avg;
% timeShift = 14;
% tmp(ind_PST(1):ind_PST(end)+timeShift) = [NaN(timeShift,1) ; MET_PSP_SWi_Avg(ind_PST)];
% pathSolar = biomet_path('yyyy','UBC_Totem','Climate\Clean');
% Solar_AVG = read_bor(fullfile(pathSolar,'Solar_AVG'),[],[],yearsIn);
% figure(4)
% plot(datetime(tv_GMT,'convertfrom','datenum'),[Solar_AVG tmp])
% legend('Solar','New')
% grid


%%

% push data forward
% Bad clock Oct 24, 2017 00:00 GMT - Apr 13, 2020 00:30 GMT
% Had to push it forward by 14 points (7 hours). I am not sure why
% 7 hours and not 8 (PST+8 = GMT) but this is what works.
timeShift = 14;
ind_PST = find(tv_GMT>=datenum(2017,10,24,0,0,0) & tv_GMT<datenum(2020,4,13,0,30,0));

MET_Ap_Quan_Avg_1year(ind_PST(1):ind_PST(end)+timeShift) = [NaN(timeShift,1) ; MET_Ap_Quan_Avg(ind_PST)];
MET_NRlite_Nrad_Avg(ind_PST(1):ind_PST(end)+timeShift) = [NaN(timeShift,1) ; MET_NRlite_Nrad_Avg(ind_PST)];
MET_PIR_LWi_Avg(ind_PST(1):ind_PST(end)+timeShift) = [NaN(timeShift,1) ; MET_PIR_LWi_Avg(ind_PST)];
MET_PIR_LWo_Avg(ind_PST(1):ind_PST(end)+timeShift) = [NaN(timeShift,1) ; MET_PIR_LWo_Avg(ind_PST)];
MET_PSP_albedo_Avg(ind_PST(1):ind_PST(end)+timeShift) = [NaN(timeShift,1) ; MET_PSP_albedo_Avg(ind_PST)];
MET_PSP_SWi_Avg(ind_PST(1):ind_PST(end)+timeShift) = [NaN(timeShift,1) ; MET_PSP_SWi_Avg(ind_PST)];
MET_PSP_SWo_Avg(ind_PST(1):ind_PST(end)+timeShift) = [NaN(timeShift,1) ; MET_PSP_SWo_Avg(ind_PST)];
MET_PSPPIR_Nrad_Avg(ind_PST(1):ind_PST(end)+timeShift) = [NaN(timeShift,1) ; MET_PSPPIR_Nrad_Avg(ind_PST)];
RECORD(ind_PST(1):ind_PST(end)+timeShift) = [NaN(timeShift,1) ; RECORD(ind_PST)];
%%
for nYear = 2017
    tv = fr_round_time(datenum(nYear,1,1,0,30,0):1/48:datenum(nYear+1,1,1,0,0,0))';
    pathOut = biomet_path(nYear,'UBC_Totem','Radiation\30min');
    [~,indOut] = intersect(tv_GMT,tv);
    length(indOut)
    pause
    save_bor(fullfile(pathOut,'MET_Ap_Quan_Avg'),1,MET_Ap_Quan_Avg(indOut));
    save_bor(fullfile(pathOut,'MET_NRlite_Nrad_Avg'),1,MET_NRlite_Nrad_Avg(indOut));
    save_bor(fullfile(pathOut,'MET_PIR_LWi_Avg'),1,MET_PIR_LWi_Avg(indOut));
    save_bor(fullfile(pathOut,'MET_PIR_LWo_Avg'),1,MET_PIR_LWo_Avg(indOut));
    save_bor(fullfile(pathOut,'MET_PSP_albedo_Avg'),1,MET_PSP_albedo_Avg(indOut));
    save_bor(fullfile(pathOut,'MET_PSP_SWi_Avg'),1,MET_PSP_SWi_Avg(indOut));
    save_bor(fullfile(pathOut,'MET_PSP_SWo_Avg'),1,MET_PSP_SWo_Avg(indOut));
    save_bor(fullfile(pathOut,'MET_PSPPIR_Nrad_Avg'),1,MET_PSPPIR_Nrad_Avg(indOut));
    save_bor(fullfile(pathOut,'RECORD'),1,RECORD(indOut));
end

        
    
    



