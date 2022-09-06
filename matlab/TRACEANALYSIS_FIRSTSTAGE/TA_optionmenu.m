function ta_optionmenu(action)
%This function contains all the callback routines for the option menu
%	INPUT: 'action' -specifies which menu item was selected (defined in the callbacks).
%Functionality:
%	1.	'exact'		-changes between exact point selection and x-axis point selection.
%	2. 'lin_style' -user can change the plotting options of all traces.
%	3. 'ax_opts'	-user can change the axes option(grid and dimensions)
%	4. 'legend'		-creates a legend, listing traces and colors.  This legend will update
%						if the plotting options are changed(or traces added or removed).
%	5. 'close_legend' - removes the legend if it exists.
%
% Data is transferred using the 'UserData' property for the current working axis.
% All data for the current trace is located in this one place.
% See the function "TraceAnalysis_Tool" for more information about the Top level data
% structure:
top = get(gca,'UserData');
top.re_plot = 0;
top.new_axis = 0;

switch action
case 'exact'
   str = get(gcbo,'Label');
   if strcmp(str,'Selection Type: Exact')
      set(gcbo,'Label','Selection Type: Xaxis');
   else
      set(gcbo,'Label','Selection Type: Exact');
   end
case 'lin_style'
   zoom out;
   data_out = ta_plot_options('init',top);
   if ~isempty(data_out)
      top = data_out;
      top.re_plot = 1;
      set(gca,'UserData',top);
      if ~isempty(top.h_legend)
         ta_optionmenu('legend');
         top = get(gca,'UserData');
      end
      top.re_plot=1;
   end
case 'ax_opts'
   ta_zoom_control('down');
   zoom out;
   zoom reset;
   ta_zoom_control('up');
   top = get(gca,'UserData');
   data_out = ta_axis_options('init',top);
   if isempty(data_out)
      return
   end   
   top.span = data_out.span;
   str = get(top.hndls(2),'label');
   if strcmp(str,'Look at Fullview')      
      top.ax_dim = [top.ax_dim(2)-top.span top.ax_dim(2) ...
            data_out.ylimits(1,1) data_out.ylimits(1,2)];
      top.old_xy = top.ax_dim;
   else
      top.ax_dim = [top.ax_dim(1) top.ax_dim(2) ...
            data_out.ylimits(1,1) data_out.ylimits(1,2)];
      top.old_xy(1:2) = [top.old_xy(2)-top.span top.old_xy(2)];
      top.old_xy(3:4) = top.ax_dim(3:4);
   end       
      
   if strcmp(data_out.grid,'on')
      grid on;
      set(gca,'xcolor',[1 1 1],'ycolor',[1 1 1]);
   else
      grid off;
   end
   if ~isnan(data_out.ylimits(2,1))
      top.trace_same_ax_right.ini.minMax = data_out.ylimits(2,:);
   end
   if ~isnan(data_out.ylimits(3,1))
      top.trace_other_ax.ini.minMax = data_out.ylimits(3,:);
      if strcmp(data_out.grid,'on')
         set(top.other_ax_hdl,'XGrid', 'on');
         set(top.other_ax_hdl,'YGrid', 'on');   
         set(top.other_ax_hdl,'xcolor',[1 1 1],'ycolor',[1 1 1]);
      else
         set(top.other_ax_hdl,'XGrid', 'off');
         set(top.other_ax_hdl,'YGrid', 'off');         
      end
      
   end
   if ~isnan(data_out.ylimits(4,1))
      top.trace_other_ax_right.ini.minMax = data_out.ylimits(4,:);
      if strcmp(data_out.grid,'on') & isempty(top.other_ax_hdl)
         set(top.other_ax_hdl_right,'XGrid', 'on');
         set(top.other_ax_hdl_right,'YGrid', 'on');  
         set(top.other_ax_hdl,'xcolor',[1 1 1],'ycolor',[1 1 1]);
      else
         set(top.other_ax_hdl_right,'XGrid', 'off');
         set(top.other_ax_hdl_right,'YGrid', 'off');
      end      
   end
 
   top.re_plot = 1;
   top.new_axis = 1; 
case 'legend'
   pos = [450 100 200 400];    
   if ~isempty(top.h_legend)
      pos = get(top.h_legend, 'Position');
      delete(top.h_legend);
   end  
   h_legend = figure('handlevisibility','off','IntegerHandle','off',...
      'NumberTitle','off','MenuBar','none','color',[0 0 0],...
      'Position',pos,'Name','Legend');
   ind = [];
   col = [];
   if ~isempty(top.trace_same_ax)
      ind = top.trc_plot_params(1).index;
      col = top.trc_plot_params(1).color;
   end
   if ~isempty(top.curr_ax_hdl)
      ind = [ind top.trc_plot_params(2).index];
      col = [col; top.trc_plot_params(2).color];
   end
   if ~isempty(top.other_ax_hdl)
      ind = [ind top.trc_plot_params(3).index];
      col = [col; top.trc_plot_params(3).color];
   end
   if ~isempty(top.other_ax_hdl_right)
      ind = [ind top.trc_plot_params(4).index];
      col = [col; top.trc_plot_params(4).color];
   end
   x = 0.01;
   y = 0.95;
   wy= 0.8;
   wx= 0.04;
   for i=1:length(ind)
      str = top.list_of_traces(ind(i)).variableName;
      if length(str)>28
         set(h_legend,'Position',[450 100 270 400]);
      end      
      uicontrol(h_legend,'style','text','Units','normalized','Position',[x y wy wx],...
         'string',str,'HorizontalAlignment','left',...
         'backgroundcolor',[0 0 0],'foregroundcolor',[1 1 1]);
      uicontrol(h_legend,'style','text','Units','normalized',...
         'Position',[x+0.8 y+0.01 wy-0.62 wx-0.02],'string','',...
         'HorizontalAlignment','left','backgroundcolor',col(i,:));
      y = y  - wx;
   end
   
   uicontrol(h_legend,'style','text','Units','normalized','Position',[x y wy wx],...
         'string','Current Trace','HorizontalAlignment','left',...
         'backgroundcolor',[0 0 0],'foregroundcolor',[1 1 1]);
   uicontrol(h_legend,'style','text','Units','normalized',...
         'Position',[x+0.8 y+0.01 wy-0.62 wx-0.02],'string','',...
         'HorizontalAlignment','left','backgroundcolor',top.init_colors(1,:));
   y=y-wx;
   uicontrol(h_legend,'style','text','Units','normalized','Position',[x y wy wx],...
      'string','Initial Trace','HorizontalAlignment','left',...
      'backgroundcolor',[0 0 0],'foregroundcolor',[1 1 1]);
   uicontrol(h_legend,'style','text','Units','normalized',...
      'Position',[x+0.8 y+0.01 wy-0.62 wx-0.02],'string','',...
      'HorizontalAlignment','left','backgroundcolor',top.init_colors(2,:));
   if ~isempty(top.x_data)
      y=y-wx;
      uicontrol(h_legend,'style','text','Units','normalized','Position',[x y wy wx],...
         'string','Selected Points:','HorizontalAlignment','left',...
         'backgroundcolor',[0 0 0],'foregroundcolor',[1 1 1]);
      uicontrol(h_legend,'style','text','Units','normalized',...
         'Position',[x+0.8 y+0.01 wy-0.62 wx-0.02],'string','',...
         'HorizontalAlignment','left','backgroundcolor',top.init_colors(3,:));
   end  
   
   if top.env_mat ==1 & isfield(top.trace_var,'runFilter_stats')
      y=y-wx;
      uicontrol(h_legend,'style','text','Units','normalized','Position',[x y wy wx],...
         'string','Envelope Filter:','HorizontalAlignment','left',...
         'backgroundcolor',[0 0 0],'foregroundcolor',[1 1 1]);
      uicontrol(h_legend,'style','text','Units','normalized',...
         'Position',[x+0.8 y+0.01 wy-0.62 wx-0.02],'string','',...
         'HorizontalAlignment','left','backgroundcolor',top.init_colors(4,:));
   end   
   set(h_legend,'CloseRequestFcn','ta_optionmenu(''close_legend'')');
   top.h_legend = h_legend;
     
case 'close_legend'
   delete(top.h_legend);
   top.h_legend = [];
end
temp = ta_plot_all_traces(top);
if ~isempty(temp)
   top.cb_plot = temp;
end
set(gca,'UserData',top);

   
