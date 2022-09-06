% ==============================================
% Converting Andreas' Radiation data from 
% 2010-2017
% 
%
% Zoran Nesic               File created:       July 10, 2022
%                           Last modification:  July 27, 2022
%

%
% Revisions
%
% July 27, 2022 (Zoran)
%   - changed Clean_tv to clean_tv
%


pthIn = '\\paoa001\sites\ubc\CSI_NET\Totem_Radiometer_Data\Andreas_RadiometerData_20170814';

fid = fopen(fullfile(pthIn,'TFRAD.csv'));
tfrad = textscan(fid,'%{yyyy-MM-dd HH:mm}D %f %f %f %f','delimiter',',','headerlines',1);
fclose(fid);
%tv_in(isnan(tv_in)
tv_tfrad = fr_round_time(datenum(tfrad{1})+8/24);  % load time and convert from PST to GMT
MET_PSP_SWi_Avg = tfrad{2};
MET_PSP_SWo_Avg = tfrad{3};
MET_PIR_LWi_Avg = tfrad{4};
MET_PIR_LWo_Avg = tfrad{5};
MET_PSP_albedo_Avg = MET_PSP_SWo_Avg./MET_PSP_SWi_Avg;
MET_PSP_albedo_Avg(MET_PSP_SWi_Avg<0 | MET_PSP_SWo_Avg<0 | MET_PSP_SWo_Avg>MET_PSP_SWi_Avg) = NaN;


fid = fopen(fullfile(pthIn,'TFNRA.csv'));
tfnra = textscan(fid,'%{yyyy-MM-dd HH:mm}D %f %f','delimiter',',','headerlines',1);
fclose(fid);
tv_tfnra = fr_round_time(datenum(tfnra{1})+8/24);  % load time and convert from PST to GMT
MET_PSPPIR_Nrad_Avg = tfnra{2};
MET_NRlite_Nrad_Avg = tfnra{3};

%%
for nYear = [2009:2017]
    tv = fr_round_time(datenum(nYear,1,1,0,30,0):1/48:datenum(nYear+1,1,1,0,0,0))';
    [~,ind_tv,ind_tvfrad] = intersect(tv,tv_tfrad); 
    pthOut = biomet_path(nYear,'UBC_Totem','Radiation\30min');
    mkdir (pthOut)
    save_bor(fullfile(pthOut,'clean_tv'), 8, tv, []);
    save_bor(fullfile(pthOut,'TimeVector'), 8, tv, []);
    
    % create an empty trace
    dataNaN = tv*NaN;
    
    % export data
    MET_PSP_SWo_Avg_1Year = dataNaN;
    MET_PSP_SWo_Avg_1Year(ind_tv) = MET_PSP_SWo_Avg(ind_tvfrad);
    save_bor(fullfile(pthOut,'MET_PSP_SWo_Avg'), [],MET_PSP_SWo_Avg_1Year);

    MET_PSP_SWi_Avg_1Year = dataNaN;
    MET_PSP_SWi_Avg_1Year(ind_tv) = MET_PSP_SWi_Avg(ind_tvfrad);
    save_bor(fullfile(pthOut,'MET_PSP_SWi_Avg'), [],MET_PSP_SWi_Avg_1Year);    
    
    MET_PIR_LWi_Avg_1Year = dataNaN;
    MET_PIR_LWi_Avg_1Year(ind_tv) = MET_PIR_LWi_Avg(ind_tvfrad);
    save_bor(fullfile(pthOut,'MET_PIR_LWi_Avg'), [],MET_PIR_LWi_Avg_1Year);    
   
    MET_PIR_LWo_Avg_1Year = dataNaN;
    MET_PIR_LWo_Avg_1Year(ind_tv) = MET_PIR_LWo_Avg(ind_tvfrad);
    save_bor(fullfile(pthOut,'MET_PIR_LWo_Avg'), [],MET_PIR_LWo_Avg_1Year);      
    
    MET_PSP_albedo_Avg_1Year = dataNaN;
    MET_PSP_albedo_Avg_1Year(ind_tv) = MET_PSP_albedo_Avg(ind_tvfrad);
    save_bor(fullfile(pthOut,'MET_PSP_albedo_Avg'), [],MET_PSP_albedo_Avg_1Year);    
    
    [~,ind_tv,ind_tvnra] = intersect(tv,tv_tfnra); 
    
    MET_PSPPIR_Nrad_Avg_1Year = dataNaN;
    MET_PSPPIR_Nrad_Avg_1Year(ind_tv) = MET_PSPPIR_Nrad_Avg(ind_tvnra);
    save_bor(fullfile(pthOut,'MET_PSPPIR_Nrad_Avg'), [],MET_PSPPIR_Nrad_Avg_1Year);
    
    MET_NRlite_Nrad_Avg_1Year = dataNaN;
    MET_NRlite_Nrad_Avg_1Year(ind_tv) = MET_NRlite_Nrad_Avg(ind_tvnra);
    save_bor(fullfile(pthOut,'MET_NRlite_Nrad_Avg'), [],MET_NRlite_Nrad_Avg_1Year);    
    
    if nYear==2017
        % create a false RECORD trace. This is needed later on so that the
        % first stage cleaning does not wipe the begining of the year
        save_bor(fullfile(pthOut,'RECORD'), [],ones(size(tv)));
    end
end

%%
% Check database
clear;
for nYear = [2009:2017]
    pthOut = biomet_path(nYear,'UBC_Totem','Radiation\30min');
    tv = read_bor(fullfile(pthOut,'TimeVector'),8);
    MET_PSP_SWi_Avg = read_bor(fullfile(pthOut,'MET_PSP_SWi_Avg'));
    MET_PSP_SWo_Avg = read_bor(fullfile(pthOut,'MET_PSP_SWo_Avg'));
    MET_PIR_LWi_Avg = read_bor(fullfile(pthOut,'MET_PIR_LWi_Avg'));
    MET_PIR_LWo_Avg = read_bor(fullfile(pthOut,'MET_PIR_LWo_Avg'));
    MET_PSPPIR_Nrad_Avg = read_bor(fullfile(pthOut,'MET_PSPPIR_Nrad_Avg'));
    MET_NRlite_Nrad_Avg = read_bor(fullfile(pthOut,'MET_NRlite_Nrad_Avg'));

    figure(1)
    plot(datetime(tv,'convertfrom','datenum'),[MET_PSP_SWi_Avg ...
                                               MET_PSP_SWo_Avg ...
                                               MET_PIR_LWi_Avg ...
                                               MET_PIR_LWo_Avg ...
                                               MET_PSP_SWi_Avg-MET_PSP_SWo_Avg+MET_PIR_LWi_Avg-MET_PIR_LWo_Avg ...                                      
                                               MET_PSPPIR_Nrad_Avg ...
                                               MET_NRlite_Nrad_Avg ...
                                               ])
    legend('SWi','SWo','LWi','LWo','NetCalc','NetLoggerCalc','NRlite');
    pause
end
