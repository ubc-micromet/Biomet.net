function top_out = ta_setup_addplots(top)
%This function will plot all the imported traces specified in the initialization file.
%The fields listed in the initialization file, such as 'plotBottomLeft', refer to the
%location to plot the listed traces.
%
% INPUT:		'Top'  -A structure containing all the information for the current trace 
% 						See the function "TraceAnalysis_Tool" for more information.
% OUTPUT:	'Top_Out' -Updated top level structure.

top_out = '';
if ~isfield(top.trace_var,'ini')
   return
end
%for each of the four possible axes, plot any traces listed in the initialization file:
for all_ax=1:4
   plot_ax = 'yes';
   if all_ax==1 & isfield(top.trace_var.ini,'plotBottomLeft')
      trc_names = top.trace_var.ini.plotBottomLeft;
   elseif all_ax==2 & isfield(top.trace_var.ini,'plotBottomRight')
      trc_names = top.trace_var.ini.plotBottomRight;
   elseif all_ax==3 & isfield(top.trace_var.ini,'plotTopLeft')
      trc_names = top.trace_var.ini.plotTopLeft;
   elseif all_ax==4 & isfield(top.trace_var.ini,'plotTopRight')
      trc_names = top.trace_var.ini.plotTopRight;
   else
      plot_ax = 'no';
   end
   if strcmp(plot_ax,'yes')
      
      answer = ta_get_index_traceList(trc_names,top.list_of_traces);
      for i=answer
         trace_old = top.list_of_traces(i);
         if ~isfield(trace_old,'data')              
            trace_new = ta_load_traceData(trace_old,top.file_opts,top.DOY);                      
            %break from the inner most for loop if any traces on this axis are not present:
            if isempty(trace_new)
               break
            end
         else
            trace_new = trace_old;
         end      
         
         switch all_ax
         case 1
            %bottom left:
            top.trace_same_ax =[top.trace_same_ax, trace_new.data];
         case 2
            %bottom right:
            pos = get(gca,'Position');
            pos(3) = 0.85;
            set(gca,'Position',pos,'color','black');
            
            if isempty(top.trace_same_ax_right)
               top.trace_same_ax_right = trace_new;
               top.curr_ax_hdl = axes('parent',gcf,'HandleVisibility',' off',...
                  'Position',pos,'color','black','box','off');
            else
               top.trace_same_ax_right.data = [top.trace_same_ax_right.data, trace_new.data];
            end
            
         case 3            
            %top left:
            pos = get(gca,'Position');
            pos(4) = 0.39;
            set(gca,'Position',pos);
            pos(2) = 0.57;         
            if isempty(top.trace_other_ax)     
               top.trace_other_ax = trace_new;
               top.other_ax_hdl = axes('parent',gcf,'HandleVisibility','off',...
                  'Position',pos,'color','black','box','off');
            else
               top.trace_other_ax.data = [top.trace_other_ax.data, trace_new.data];
            end
            
         case 4
            %top right:
            pos = get(gca,'Position');
            pos(3) = 0.85;
            pos(4) = 0.39;
            set(gca,'Position',pos);
            pos(2) = 0.57;      
            
            if isempty(top.trace_other_ax_right)
               top.trace_other_ax_right = trace_new;
               top.other_ax_hdl_right = axes('parent',gcf,'HandleVisibility',' off',...
                  'Position',pos,'color','black','box','off');
            else
               top.trace_other_ax_right.data = [top.trace_other_ax_right.data, trace_new.data];
            end
         end
         
         col_temp = top.def_cols(top.col_curr(1),:);
         top.col_curr = top.col_curr(2:end);       
         top.trc_plot_params(all_ax).color = [top.trc_plot_params(all_ax).color; col_temp];
         top.trc_plot_params(all_ax).index = [top.trc_plot_params(all_ax).index i];         
         top.trc_plot_params(all_ax).symbol =[top.trc_plot_params(all_ax).symbol, {'-'}];
         top.trc_plot_params(all_ax).width =[top.trc_plot_params(all_ax).width, 1];
         top.trc_plot_params(all_ax).size = [top.trc_plot_params(all_ax).size, 8];      
      end
   end   
end

top_out = top;