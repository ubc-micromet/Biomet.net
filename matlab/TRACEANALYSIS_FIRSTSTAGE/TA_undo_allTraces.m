function top_out = ta_undo_allTraces(top)
%This function 

%Update the current working trace:
top_out = [];

top.trace_var = ta_load_traceData(top.trace_var,top.file_opts,top.DOY);

%Update all the dependent traces that are currently plotted:
indtrcs = [top.file_opts.trcInd top.trace_var.ind_depend];
%Also include all currently plotted traces:
indtrcs = union(indtrcs,...
   union(top.trc_plot_params(1).index,...
   union(top.trc_plot_params(2).index,...
   union(top.trc_plot_params(3).index,...
   top.trc_plot_params(4).index))));
for ind = indtrcs
   trace_new = ta_load_traceData(top.list_of_traces(ind),top.file_opts,top.DOY);   
   if isempty(trace_new)
      return
   end
   
   %update the four plots which contain traces effected by the undo/redo command:
   for i=1:4
      [ai bi ci] = intersect(ind,top.trc_plot_params(i).index);
      if ~isempty(ci)    
         switch i
         case 1
            top.trace_same_ax(:,ci) = trace_new.data;
         case 2
            top.trace_same_ax_right.data(:,ci) = trace_new.data;	
         case 3
            top.trace_other_ax.data(:,ci) = trace_new.data;
         case 4           
            top.trace_other_ax_right.data(:,ci) = trace_new.data;
         end         
      end 
   end   
end
top_out = top;


