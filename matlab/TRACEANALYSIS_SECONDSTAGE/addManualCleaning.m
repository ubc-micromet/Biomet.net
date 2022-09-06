function trace_str_out = addManualCleaning(trace_str_dat,trace_str_manual)

disp('Adding manual cleaning ...');

[dunny_name,ind_manual,ind_data] = intersect({trace_str_manual(:).variableName},{trace_str_dat(:).variableName});

for i = 1:length(ind_manual)
   
   if isfield(trace_str_manual(ind_manual(i)),'pts_restored') & ~isempty(trace_str_manual(ind_manual(i)).pts_restored)
      trace_str_dat(ind_data(i)).pts_restored = trace_str_manual(ind_manual(i)).pts_restored;
      trace_str_dat(ind_data(i)).data(trace_str_dat(ind_data(i)).pts_restored) = trace_str_dat(ind_data(i)).data_old(trace_str_dat(ind_data(i)).pts_restored);
   end
   
   if isfield(trace_str_manual(ind_manual(i)),'pts_removed') & ~isempty(trace_str_manual(ind_manual(i)).pts_removed)
      trace_str_dat(ind_data(i)).pts_removed = trace_str_manual(ind_manual(i)).pts_removed;
      %Reset all interpolated values:
      trace_str_dat(ind_data(i)).data(trace_str_dat(ind_data(i)).pts_removed) = NaN;
      if isfield(trace_str_manual(ind_manual(i)),'interpolated') & ~isempty(trace_str_manual(ind_manual(i)).interpolated)
         trace_str_dat(ind_data(i)).interpolated = trace_str_manual(ind_manual(i)).interpolated;   
         trace_str_dat(ind_data(i)).data(trace_str_dat(ind_data(i)).pts_removed) = trace_str_dat(ind_data(i)).interpolated(trace_str_dat(ind_data(i)).pts_removed);   
      end
   end
   
end

trace_str_out = trace_str_dat;