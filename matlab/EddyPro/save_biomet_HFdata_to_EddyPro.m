function save_biomet_HFdata_to_EddyPro(siteId,tv_calc,flag_asc,pth_EP,systemNum)

% reads in biomet format Digital2 files and exports as a generic 4 byte
% binary file with no header or an ascii csv file. Can be used to prepare
% HF data for import into e.g. Licor EddyPro

% File created:  Sept 30, 2014 (Nick)
% Last modified: Oct   6, 2022 

% Revisions:
%
% Oct 6, 2022 (Zoran)
%   - added arg_default('systemNum',1); Some sites (YF) have multiple Systems
%     so that argument is required.
%   - changed output file names from YYYYMMDD_HHMM.dat to YYYY-MM-DDThhmmdd.csv

arg_default('systemNum',1);

for i=1:length(tv_calc)
    [~,HF_Data] = yf_calc_module_main(tv_calc(i),siteId,1);
%     fn_txt=fr_DateToFileName(tv_calc(i));
%     yy_txt=fn_txt(1:2);
%     mm_txt=fn_txt(3:4);
%     dd_txt=fn_txt(5:6);
%     yyyy=['20' yy_txt];
%     tod=(str2num(fn_txt(7:8))/96)*24;
%     HH=floor(tod);
%     MM=tod-HH;
%     if MM>0
%         MM_txt='30';
%     else
%         MM_txt='00';
%     end
%     if HH>=0 & HH<10
%         HH_txt=['0'  num2str(HH)];
%     elseif HH>=10 & HH<=24
%         HH_txt = num2str(HH);
%     end
    try
        dt      = ones(size(HF_Data.System(systemNum).EngUnits(:,1)))* 1/24/3600/20;
        dt      = cumsum(dt);
        t       = datetime(tv_calc(i)-1/48+dt,'convertfrom','datenum');
        %s       = round(second(t),3);
        strT    = datestr(t,'yyyy-mm-dd hh:MM:ss.FFF');
        u       = round(HF_Data.System(systemNum).EngUnits(:,1),3);
        v       = round(HF_Data.System(systemNum).EngUnits(:,2),3);
        w       = round(HF_Data.System(systemNum).EngUnits(:,3),3);
        Tair    = round(HF_Data.System(systemNum).EngUnits(:,4),3);
        co2     = round(HF_Data.System(systemNum).EngUnits(:,5),3);
        h2o     = round(HF_Data.System(systemNum).EngUnits(:,6),3);
        T = table(strT,u,v,w,Tair,co2,h2o,'variableNames',{'Date Time','u (m/s)','v (m/s)','w (m/s)','Tair (degC)','co2 (umol/mol dry)','h2o (mmol/mol dry)'});
        if ~flag_asc % export as binary 4 byte 'float32'
            %fn_new = [yyyy fn_txt(3:6) '_' HH_txt MM_txt '.bin'];
            fn_new = sprintf('%s.bin',datestr(tv_calc(i),'yyyy-mm-ddTHHMMss'));
            save_bor(fullfile(pth_EP,fn_new),1,EngUnits_alignment_only);
        else % export as ascii csv
            %fn_new = [yyyy fn_txt(3:6) '_' HH_txt MM_txt '.dat'];
            fn_new = sprintf('%s.dat',datestr(tv_calc(i),'yyyy-mm-ddTHHMMss'));
            writetable(T,fullfile(pth_EP,fn_new))
            %dlmwrite(fullfile(pth_EP,fn_new),EngUnits_alignment_only,'delimiter',',','precision',8);
        end
    catch
        disp(['No data found for ' fn_new ]);
        continue
    end
end