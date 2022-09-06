function save_EddyPro_to_biometDB(siteId,year,pth_db,trace_str,ind_year);

dateStr = FR_DateToFileName(now);
arg_default('pth_db',biomet_path(year,siteId,['EddyPro',dateStr(1:6)]));

tr_name={trace_str.variableName}';

for k=5:length(tr_name)
    if exist(fullfile(pth_db,char(tr_name{k})),'file')
	   trace_db=read_bor(fullfile(pth_db,char(tr_name{k})));
       tmp=trace_str(k).data;
       indNaN=find(tmp==-9999);
       tmp(indNaN)=NaN;
	   trace_db(ind_year)=tmp(ind_year);
       save_bor(fullfile(pth_db,char(tr_name{k})),1,trace_db);
	else
	  tmp=trace_str(k).data;
      indNaN=find(tmp==-9999);
      tmp(indNaN)=NaN;
      save_bor(fullfile(pth_db,char(tr_name{k})),1,tmp);
    end
end

save_bor(fullfile(pth_db,'TimeVector'),8,trace_str(1).TimeVector);