
function save_biomet_HFdata_to_EddyPro(siteId,tv_calc,flag_asc,pth_EP);

% reads in biomet format Digital2 files and exports as a generic 4 byte
% binary file with no header or an ascii csv file. Can be used to prepare
% HF data for import into e.g. Licor EddyPro

% File created:  Sept 30, 2014 (Nick)
% Last modified: Sept 30, 2014

% Revisions:
%
%

for i=1:length(tv_calc),
    [Stats_New,HF_Data] = yf_calc_module_main(tv_calc(i),siteId,1);
    fn_txt=FR_DateToFileName(tv_calc(i));
    yy_txt=fn_txt(1:2);
    mm_txt=fn_txt(3:4);
    dd_txt=fn_txt(5:6);
    yyyy=['20' yy_txt];
    tod=(str2num(fn_txt(7:8))/96)*24;
    HH=floor(tod);
    MM=tod-HH;
    if MM>0
        MM_txt='30';
    else
        MM_txt='00';
    end
    if HH>=0 & HH<10
        HH_txt=['0'  num2str(HH)];
    elseif HH>=10 & HH<=24
        HH_txt = num2str(HH);
    end
    try
        EngUnits_alignment_only = HF_Data.System.EngUnits;
        if ~flag_asc % export as binary 4 byte 'float32'
            fn_new = [yyyy fn_txt(3:6) '_' HH_txt MM_txt '.bin'];
            save_bor(fullfile(pth_EP,fn_new),1,EngUnits_alignment_only);
        else % export as ascii csv
            fn_new = [yyyy fn_txt(3:6) '_' HH_txt MM_txt '.dat'];
            dlmwrite(fullfile(pth_EP,fn_new),EngUnits_alignment_only,'delimiter',',','precision',8);
        end
    catch
        disp(['No data found for ' fn_new ]);
        continue
    end
end