function fig_ID = ta_plot_all_traces(top)
%This function is used with the graphical point removing tool to do optional plotting
%on the various data present.
%	Input:	'top'		-contains the current information associated with the working trace.
%							All info related to this trace is store into top(located in the
%							working axis 'UserData'). See the function "TraceAnalysis_Tool".
%
%	Ouput:	'fig_ID' -the axis handle of the current working axis
%


fig_ID = [];
%If calling function requires axis to be re-plotted:
if top.re_plot == 1
   hold on;
   %Check if the current working axis contains any plotted data:
   chck = top.cb_plot;
   if exist('chck') == 1 & ~isempty(chck)
      %if so, then delete all the data from the axis:
      delete(chck);	
      temp=get(gca,'children');		%delete all imported traces
      delete(temp);
   end   
   
   t = top.trace_var.DOY;			%for x-axis
   d = top.trace_var.data_old;	%y-axis data values
   if ~isempty(top.trace_same_ax)
      %if user imported plots to bottom left axis,add these traces to current plot:
      sz = min(size(top.trace_same_ax));        
      %for each trace imported set the symbol, the color, linewidth, and markersize:
      for i=1:sz
         plot(t,top.trace_same_ax(:,i),char(top.trc_plot_params(1).symbol(i)),...
            'color',top.trc_plot_params(1).color(i,:),...
            'linewidth',top.trc_plot_params(1).width(i),...
            'markersize',top.trc_plot_params(1).size(i));      
      end        
   end
   
   %regular plotting contains raw uncleaned trace, cleaned trace, selected points
   %and any filter envelopes that are being viewed:
   count=1;
   if top.env_mat ==1 & isfield(top.trace_var,'runFilter_stats')
      envs = top.trace_var.runFilter_stats.envelope_matrix;
      fig_ID(count:min(size(envs))) = plot(t,envs(:,:),char(top.init_symbols(4)),...
         'color',top.init_colors(4,:),...
         'LineWidth',top.init_width(4),...
         'MarkerSize',top.init_size(4));   
      count = count + min(size(envs));
   end
   %plot raw uncleaned data and set line properties:
   fig_ID(count) = plot(t,d,char(top.init_symbols(2)),...
      'color',top.init_colors(2,:),...
      'LineWidth',top.init_width(2),...
      'MarkerSize',top.init_size(2));
   %plot cleaned data and set properties:
   fig_ID(count+1) = plot(t,top.trace_var.data,char(top.init_symbols(1)),...
      'color',top.init_colors(1,:),...
      'LineWidth',top.init_width(1),...
      'MarkerSize',top.init_size(1));  
   %plot selected points if available:
   if ~isempty(top.x_data)
      fig_ID(count+2) = plot(t(top.x_data),d(top.x_data),char(top.init_symbols(3)),...
         'color',top.init_colors(3,:),...
         'LineWidth',top.init_width(3),...
         'MarkerSize',top.init_size(3));
   end
   %reset the working axis if calling function sets flag:
   if top.new_axis == 1
      axis(top.ax_dim);				%Set Current Traces axis.
   end 
      
   %create plots in the bottom right axis if it exists.  This axis will always remain
   %behind the current working axis(no background color) and set to a black background:
   if ~isempty(top.curr_ax_hdl)
      xlimits = get(gca,'xlim');			%get working axis x-limits
      set(gca,'color','none');			%make the working axis transparent
      pos_old = get(gca,'Position');	%get the position of the working axis
      
      %Make the handle of the new bottom right axis visible, and current:
      set(top.curr_ax_hdl,'HandleVisibility','on');
      axes(top.curr_ax_hdl);
      
      %Remove any data plots on this axis:
      delete(get(top.curr_ax_hdl,'children'));      
      
      %re-Plot all traces on this axis:
      t = top.trace_same_ax_right.DOY;
      sz=min(size(top.trace_same_ax_right.data));      
      hold on;            
      for i=1:sz
         %plot each imported trace and set the properties:
         plot(t,top.trace_same_ax_right.data(:,i),...
            char(top.trc_plot_params(2).symbol(i)),...
            'color',top.trc_plot_params(2).color(i,:),...
            'linewidth',top.trc_plot_params(2).width(i),...
            'markersize',top.trc_plot_params(2).size(i)); 
      end       
      hold off;
      %if new axis setting required then reset the bottom right y-axis only. The
      %x-axis must remain the same as the working axis:
      if top.new_axis ==1
         axis([xlimits(1) xlimits(2) ...
               top.trace_same_ax_right.ini.minMax(1) top.trace_same_ax_right.ini.minMax(2)]);
      end
      %label the y-axis with the 
      ylabel(top.trace_same_ax_right.ini.units);
      %Reset the new axis properties:
      set(top.curr_ax_hdl,'Position',pos_old,'box','off','XTickLabel','',...
         'YAxisLocation','right','HandleVisibility','off','color','black');      
      %Make the working axis the current axis:
      axes(findobj('Tag','axis1'));
   end
   
   %Plot and imported traces to the top left axis:
   if ~isempty(top.other_ax_hdl)
      xlimits = get(gca,'xlim');					%Use the same x-axis as the bottom plot
      pos_old = get(gca,'Position');
      
      %Make the handle of the new top left axis visible, and current:
      set(top.other_ax_hdl,'HandleVisibility','on');
      axes(top.other_ax_hdl);
      
      %Remove any data plots on this axis:
      delete(get(top.other_ax_hdl,'children'));
      
      %re-Plot all traces on this axis:
      pos_new = get(top.other_ax_hdl,'Position');
      t = top.trace_other_ax.DOY;
      sz=min(size(top.trace_other_ax.data));
      hold on;
      for i=1:sz
         %plot each imported trace and set the properties:
         plot(t,top.trace_other_ax.data(:,i),...
            char(top.trc_plot_params(3).symbol(i)),...
            'color',top.trc_plot_params(3).color(i,:),...
            'linewidth',top.trc_plot_params(3).width(i),...
            'markersize',top.trc_plot_params(3).size(i)); 
      end 
      hold off;  
      
      if top.new_axis ==1
         %if new axis setting required then reset the y-axis only. The
         %x-axis must remain the same as the working axis:
         axis([xlimits(1) xlimits(2) ...
               top.trace_other_ax.ini.minMax(1) top.trace_other_ax.ini.minMax(2)]);
      end
      pos_new(3) = pos_old(3);
      set(top.other_ax_hdl,'Position',pos_new,'box','off','XTickLabel','');
      title(top.trace_other_ax.ini.title);
      ylabel(top.trace_other_ax.ini.units);
      
      %Reset the new axis properties:
      set(top.other_ax_hdl,'HandleVisibility','off','color','black');
      
      %Make the working axis the current axis:
      axes(findobj('Tag','axis1'));
   end
   
   %create plots in the bottom right axis if it exists.  This axis will always remain
   %behind the current working axis(no background color) and set to a black background:
   if ~isempty(top.other_ax_hdl_right)
      xlimits = get(gca,'xlim');
      pos_old = get(gca,'Position');
      
      %Make the handle of the new top left axis visible, and current:
      set(top.other_ax_hdl_right,'HandleVisibility','on');
      axes(top.other_ax_hdl_right);
      
      %Remove any data plots on this axis:
      delete(get(top.other_ax_hdl_right,'children'));
      
      %re-Plot all traces on this axis:
      pos_new = get(top.other_ax_hdl_right,'Position');
      t = top.trace_other_ax_right.DOY;
      sz=min(size(top.trace_other_ax_right.data));
      hold on;
      for i=1:sz
         %plot each imported trace and set the properties:
         plot(t,top.trace_other_ax_right.data(:,i),...
            char(top.trc_plot_params(4).symbol(i)),...
            'color',top.trc_plot_params(4).color(i,:),...
            'linewidth',top.trc_plot_params(4).width(i),...
            'markersize',top.trc_plot_params(4).size(i)); 
      end 
      hold off;  
      if top.new_axis ==1
         %if new axis setting required then reset the y-axis only. The
         %x-axis must remain the same as the working axis:         
         axis([xlimits(1) xlimits(2) ...
               top.trace_other_ax_right.ini.minMax(1) top.trace_other_ax_right.ini.minMax(2)]);
      end
      pos_new(3) = pos_old(3);
      ylabel(top.trace_other_ax_right.ini.units);
      
      %Reset the new axis properties:
      set(top.other_ax_hdl_right,'Position',pos_new,'box','off','XTickLabel','',...
         'YAxisLocation','right','HandleVisibility','off','color','black');
      if ~isempty(top.other_ax_hdl)
         set(top.other_ax_hdl_right,'color','none');
      end
      %Make the working axis the current axis:
      axes(findobj('Tag','axis1'));
   end
end
hold off;

