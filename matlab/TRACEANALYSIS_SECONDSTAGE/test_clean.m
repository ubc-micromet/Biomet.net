% Check manual cleaning
Year = 2002;
dir_ini = ['\\ANNEX001\DATABASE\Calculation_Procedures\TraceAnalysis_ini\PA\'];
filename_ini = 'pa_firststage.ini';

trace_org = read_data(Year, [], fullfile(dir_ini,filename_ini));
SiteId    = trace_str(1).SiteID;
Site_name = trace_str(1).Site_name;
var_list  = {trace_str(:).variableName}';

pth_proc = biomet_path('Calculation_Procedures\TraceAnalysis_ini',SiteId);  
mat_file = fullfile(pth_proc,[SiteId '_' num2str(Year) '_FirstStage.mat']);
mat = load(mat_file);
trace_str = addManualCleaning(trace_org,mat.trace_str)
trace_str  = autoCleanTraces( trace_str );

lst = dir('C:\temp\flux\clean');

for i = 3:length(lst)
   if ~strcmp(lst(i).name,'clean_tv')
      tst = read_bor(['C:\temp\flux\clean\' lst(i).name]);
      ind = find(strcmp({trace_str(:).variableName},{lst(i).name}));
      
      ind_diff = find(trace_str(ind).data-tst ~=0 & ~isnan(trace_str(ind).data-tst));
      if ~isempty(ind_diff)
         disp(['Differences in ' lst(i).name ' ' num2str(nanmean(trace_str(ind).data(ind_diff)-tst(ind_diff)))]);
      end
   end
end

