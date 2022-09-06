function change_trace_names_to_site(site,trace_names)

for i=1:length(trace_names)
    evalin('caller',[char(trace_names(i)) '_' lower(site) ' = ' char(trace_names(i)) ';']);
    evalin('caller',['clear ' char(trace_names(i)) ';']);
end  		
