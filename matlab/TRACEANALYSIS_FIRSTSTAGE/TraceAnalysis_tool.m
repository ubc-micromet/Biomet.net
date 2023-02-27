function finished = TraceAnalysis_tool(trace_var,list_of_traces,local_use,file_opts)
%This is the main function for the visual point picking tool.  It is meant to be used
%with the function 'TA_FirstStage' originally, but has been adapted to be used
%by iteself as well(Described below).
%
%
%  INPUTS:   'trace_var'       -either a column of data, or a single structure
%                               containing a 'data' field(and various other fields).
%            'list_of_traces'  -an array of all trace structures present in the ini_file.
%                               This list tracks all operations on multiple traces.
%            'local_use'       -is a flag indicating if this function is called by 
%                               load_traces_local(local_use='no'), or at the command 
%                               prompt(local_use='yes').
%            'file_opts'       -this is used entirely with 'load_traces_local' and should
%                               be ignored in all other cases.  It tracks different state
%                               variables through out execution of 'load_traces_local'.
%  OUTPUTS:  'finished'        -this contain the same structure as input, except with
%                               indices of points restored/removed, and the cleaned data.									
%
%
%-------------------------------------------------------------------------------------
% FIRST USE:
% To use this function either input a single column of data, or a structure with a 
% single 'data' field. 
% If input is a single column of data, this stucture will be created automatically.
% If input is a structure, these other fields can be included:
%  1. 'trace_var.data'           -column vector with the initial (or continued) cleaned data.
%  2. 'trace_var.DOY'            -column vector indicating the y-axis domain.
%  3. 'trace_var.ini.title'      -character string giving the title to appear on the plots
%  4. 'trace_var.ini.units'      -char string indicating label on x-axis.
%  5. 'trace_var.ini.ylabel'     -char string indicating label on y-axis.
%  6. 'trace_var.ini.minMax'     -a two element vector indicating the minimum and maximum
%                                 y-axis dimensions(ex: minMax = [-100 100]).
%
% During program execution, other fields will be created to track information about the
% cleaning performed.  These fields are:
%  7. 'trace_var.data_old'       -column vector containing the initial input data.
%  8. 'trace_var.pts_removed'    -column vector of all points currently removed.
%  9. 'trace_var.pts_restored'   -column vector of all points currently restored.
%
% After program termination, this function will return a new structure containing all 
% fields listed above.  The field, 'trace_var.data', will contain the updated clean data.
% 
%CONTINUED USE:
% The structure returned by this function contains all optional fields, the cleaned data,
% lists of points removed/restored, and the original starting data.
% If further cleaning is required, this structure can be used as the input for this 
% function.  By doing this, all previous cleaning information will be reloaded, and you
% can continue from where you left off.
%-------------------------------------------------------------------------------------

% Revisions:
%
% Feb 27, 2023 (Zoran)
%   - had to change back some of TA_ from upper to lower case.
% May 12, 2020 (Zoran)
%   - Converted all ta_ names to TA_ to avoid issues with newer Matlabs
%      that are case sensitive (including this function's own name)
%


if nargin<1
   error('Wrong Number of Inputs!');
end
if ~exist('local_use') | isempty(local_use)
   local_use  = 'yes';
end
if ~exist('file_opts')
   file_opts  = '';
end
if ~exist('list_of_traces')
   list_of_traces = '';
end
%-----------------------------------------------------------------------
%Check for proper data types when using this program by itself:
if ~isfield(trace_var,'data')
   if ~isnumeric(trace_var)
      error('Must input a one column data vector, or a structure with a ''data'' field!');
   end      
   trace_var.data = trace_var;
end
[m,n] = size(trace_var.data);
if m==1 | n>1
   error('Input data must be a single column vector, containing at least a few elements!')   
end
if ~isfield(trace_var,'data_old')
   trace_var.data_old = trace_var.data;
end
%-----------------------------------------------------------------------
%Check if the input trace is a structure with ini field, if not then empty fields
%need to be created:
if ~isfield(trace_var,'ini')
   trace_var.ini.minMax = [min(trace_var.data) max(trace_var.data)];
   trace_var.ini.title = '';
   trace_var.ini.units = '';
   trace_var.ini.xlabel= '';
else
   if ~isfield(trace_var.ini,'minMax')
      trace_var.ini.minMax = [min(trace_var.data) max(trace_var.data)];
  end
  %overwrite axes min/max with field avMinMax if it exists
   if isfield(trace_var.ini,'axMinMax')
      trace_var.ini.minMax = [trace_var.ini.axMinMax];
   end
   if ~isfield(trace_var.ini,'title')
      trace_var.ini.title = '';
   end
   if ~isfield(trace_var.ini,'units')
      trace_var.ini.units = '';
   end
   if ~isfield(trace_var.ini,'xlabel')
      trace_var.ini.xlabel = '';
   end
end
%-----------------------------------------------------------------------

if ~isfield(trace_var,'pts_removed')
   trace_var.pts_removed = [];
   if ~isempty(list_of_traces)
      list_of_traces(file_opts.trcInd).pts_removed = [];
   end
end   
if ~isfield(trace_var,'pts_restored')
   trace_var.pts_restored = [];
   if ~isempty(list_of_traces)
      list_of_traces(file_opts.trcInd).pts_restored = [];
   end   
end

%Check for the list of interpolated points.  This list contains values
%for each point manually removed:
if ~isfield(trace_var,'interpolated') | isempty(trace_var.interpolated)
   trace_var.interpolated = [];
   if ~isempty(list_of_traces)
      for i = 1:length(file_opts.trcInd)
         list_of_traces(file_opts.trcInd(i)).interpolated = [];
      end
   end   
end

%-----------------------------------------------------------------------
%A Day Of Year field is necessary, and will be created from the length of
%the data column if not present (even though the input may not be measured in
%days):
if ~isfield(trace_var,'DOY') | isempty(trace_var.DOY)
   trace_var.DOY(1:length(trace_var.data),1) = 1:length(trace_var.data);   
end

if length(trace_var.data) ~= length(trace_var.DOY)
   error('The input data, and the x-axis range do not match!');
end
%The span is the initial x-axis range when useing the visual tool:
top.span = 10;
if strcmp(local_use,'yes')  
    top.input_name = inputname(1);	%input name is used for saving files in the filemenu
    if isempty(top.input_name)
        top.input_name = '*';
    end   
    t = trace_var.DOY;
    if (max(t) -  min(t)) < 10
        top.span = ceil(max(t) -  min(t));
    end    
%    top.span=round(((max(t) -  min(t))/length(t))*10);   
end

%-----------------------------------------------------------------------
curr_day = trace_var.DOY(end);	%Find Starting Point of trace (last day of data input).
if strcmp(local_use,'no')
   curr = now;
   currYear = datevec(curr);     				%find current year
   Year = currYear(1);   
   if trace_var.Year == Year			%If data is from current year start at current day:
      curr_day = ceil(curr - datenum(Year,1,0)) + 0;      
   else										%Else start at last day of year:
      curr_day = 368;
   end
end

%-----------------------------------------------------------------------
%Get the screen size of current computer.
rec_pos = get(0,'screensize');
offset = 0;
if rec_pos(4)==768
   offset = 150;
end

%create new figure to place gui and first axis which contains the working trace:
state_pos = '';
top.file_opts = '';
if ~isempty(file_opts)
   state_pos = file_opts.state_pos;
   top.file_opts = file_opts;   
end
if isempty(state_pos)
   pos =  [rec_pos(1) rec_pos(2)+30 rec_pos(3) rec_pos(4)-68];
   % kai*, Nov 21, 2001
   % Disabled the interpolation
   top.max_interp = 0;
   % end kai*
else
   pos =  state_pos.window;
   top.max_interp = state_pos.interp_len;
end

%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
%CREATE USER INTERFACE:
if isfield(state_pos,'fig_top') & ~isempty(state_pos.fig_top) & ishandle(state_pos.fig_top)
   fig_top = state_pos.fig_top;
   top.hndls = state_pos.hndls;
   set(fig_top,'handlevisibility','on',...
      'NumberTitle','off','MenuBar','none',...
      'Name','Trace Analysis Tool','Tag','Top Level','color',[.6 .6 .65]);
   UIFLAG = 1;
else
   fig_top = figure('handlevisibility','on','IntegerHandle','off',...
      'NumberTitle','off','MenuBar','none',...
      'Name','Trace Analysis Tool','Tag','Top Level','color',[.6 .6 .65]);
   UIFLAG = 0;
end
set(0,'ShowHiddenHandles','off');		%make sure the handles are hidden
%position the figure and axis on the screen.
set(fig_top,'position',pos);

set(gca,'Position',[0.075 0.10 0.900 0.850],'color','black',...
   'Tag','axis1');
top.first_axis = gca;

%-----------------------------------------------------------------------
if UIFLAG == 1
   set(gca,'UIContextMenu', top.hndls(1));
   delete(top.hndls(1));
   top.hndls(1:4) = TA_create_contextmenu(gca);
else
   %CREATE USER INTERFACE CONTROLS:
   %order of handles = ax_menu cb_fullview cb_zoom cb_n m_select h_viewFilt
   context_hndls = TA_create_contextmenu(gca);
   button_hndls = TA_create_interface(fig_top,local_use,list_of_traces);
   top.hndls = [context_hndls button_hndls];
end

%-----------------------------------------------------------------------
%Initialize all the fields for the current axis.  All information is kept in the 
%'top' structure which is set to the current axis 'UserData'.  It is necessary to keep
%all information in one place since there are operations that require changing the state
%of all the parameters. The 'top' structure mimics a global variable and
%makes it a lot easier to debug.
top.local_use = local_use;
%list of all traces (used with removing and restoring from multiple traces):
top.list_of_traces = list_of_traces;
%Store the initial(input) trace structure:
top.trace_var = trace_var;	

%-----------------------------------------------------------------------
%To be able to import multiple traces and keep functionality, there are four different
%axis used:  the current axis(bottom left), the bottom right axis, the top left axis,
%and the top right axis.  Each of these is its own axis object which contain all traces
%imported to that axis.  Since these axis overlap each other, the background color is
%switched from black to invisible when appropriate.
top.trace_same_ax = [];					%Matrix of all imported traces into bottom left axis
top.trace_same_ax_right = [];			%Matrix of all imported traces into bottom right axis
top.curr_ax_hdl = '';					%Handle of bottom right axis
top.other_ax_hdl = '';					%Handle for a new axis on the top left.
top.trace_other_ax = [];				%Matrix of traces imported to top left axis.
top.trace_other_ax_right = [];		%Matrix of traces imported to top right axis.
top.other_ax_hdl_right = '';			%Handle for a new axis on the top right.

%For each trace imported to each of the four plots, certain information must be tracked:
%color, index in the ini_file, plotting symbol, line width, and symbol size.
for j=1:4
   top.trc_plot_params(j).color = [];			%multiple trace plot options
   top.trc_plot_params(j).index = [];			%index of traces in 'list_of_traces'
   top.trc_plot_params(j).symbol ={};
   top.trc_plot_params(j).width =[];
   top.trc_plot_params(j).size = [];
end

%For the current working trace (initially yellow), the original raw trace, the filter
%envelopes, and point selecting,  certain info must be tracked: color,symbol,size,width.
top.init_colors = [1 1 0;0.5 1 1;1 1 1;1 0 0];		%current trace plotting options
top.init_symbols = {'-' '-' 'o' '-'};
top.init_size= [8 8 10 8];
top.init_width = [1 1 1 1];

top.zoom_scale = [0 0 1 1];		%Zooming on multiple axis at the same time requires
top.zoom_start = axis;					%a scale factor to be tracked for each zoom command.

top.pts_cnt = 0;                 %Number of points currently selected.
top.x_data =[];						%Index of currently selected points.	

top.trace_old_filt = [];			%Track each filter envelope created
top.env_mat = 0;						%flag indicating if the filter envelopes should be plotted  
top.picktype = 1;						%flag indicating which type of point selecting: exact,x-axis.
top.pointstart = [];					%start point for drawing rubberband box for pnt-selecting.
top.new_axis = 1;						%flag indicating if the axis should be reset.
top.re_plot = 1;						%flag indicating if the all the plots should be updated

top.h_legend = [];					%handle for the legend figure
top.h_statbox = [];					%handle for the statistics figure
top.h_selectedStats=[];

%-----------------------------------------------------------------------
%Create some default colors.  Needed since so many traces can be viewed at once, with
%some of the default colors changing between matlab environments.
top.def_cols = TA_get_some_colors;			
top.col_curr = 1:max(size(top.def_cols));

%After finding the current day, set the current axis appropriately.
top.ax_dim = [curr_day-top.span curr_day trace_var.ini.minMax(1) trace_var.ini.minMax(2)];
if strcmp(local_use,'no') & trace_var.Year ~= Year
   top.ax_dim(1:2) = [0 top.span];
end

top.old_xy = top.ax_dim;

top.trace_var_st = trace_var;					%Track the initial input trace if ever reset.	

top.undo.x_data = [];
top.undo.list_of_traces = [];
top.redo = top.undo;

%All information for current working axis is initialized.
%-----------------------------------------------------------------------
top.DOY = trace_var.DOY;				%used for reference while creating other traces
%plot the initial traces.
top.cb_plot = '';									%The handle of the current plot (working trace).
top.cb_plot = ta_plot_all_traces(top);		%Initial plot of the traces.
title(trace_var.ini.title);					
ylabel(trace_var.ini.units);
if strcmp(local_use,'yes')
   xlabel(trace_var.ini.xlabel);
else
   xlabel(['DOY (Decimal Day of Year)';...
      	  '1.5 = Jan 01, 12:00 Noon ']);
end
  
%The following function initializes any traces that should be plotted with the
%input trace.  These traces are indicated in the initialization file:
top_out = ta_setup_addplots(top);
if ~isempty(top_out)
   top = top_out;
   temp = ta_plot_all_traces(top);
   if ~isempty(temp)
      top.cb_plot = temp;
      set(gca,'UserData',top);
   end   
end

%Set all this information to the current axis 'userdata'.  This avoids using global
%variables and all the information can be accessed from one place.
set(gca,'UserData',top);

%-----------------------------------------------------------------------
%callback function for the mouse button (set to getp.m)
set(fig_top,'WindowButtonDownFcn','TA_get_area(''down'')','Interruptible','off');
set(fig_top,'WindowButtonUpFcn','TA_get_area(''up'')');

% Set pointer to 'crosshair'
set(fig_top,'pointer','crosshair','handlevisibility','callback');
set(fig_top,'CloseRequestFcn','TA_filemenu(''terminate'')');
set(fig_top,'KeyPressFcn','TA_shortcuts');

%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
%Closing digtool for this trace. the 'waitfor' command will keep the program active while
%in use.  When the user is done, all the necessary state information is returned.
waitfor(fig_top,'Tag','digtool:Off');

%Get all current information associated with current working trace:
%If used locally (call traceanalysis_tool from command prompt):
top_dat = get(fig_top,'UserData');
if ~isempty(top_dat.h_legend) & ishandle(top_dat.h_legend)
   delete(top_dat.h_legend);
end
if ~isempty(top_dat.h_statbox) & ishandle(top_dat.h_statbox)
   delete(top_dat.h_statbox);
end 
if ~isempty(top_dat.h_selectedStats) & ishandle(top_dat.h_selectedStats)
   delete(top_dat.h_selectedStats);
end 
if strcmp(local_use,'yes')
   finished = top_dat.trace_var; 
   delete(fig_top);
else
   finished.data = top_dat.trace_var.data;
   finished.program_action = top_dat.program_action;	%Next program action
   finished.state_pos.window = get(fig_top,'Position'); 	%last window position
   finished.state_pos.interp_len = top_dat.max_interp;   %interpolation length setting
   finished.state_pos.fig_top = fig_top;   %interpolation length setting
   finished.state_pos.hndls = top_dat.hndls;   %interpolation length setting
   finished.list_of_traces = top_dat.list_of_traces;   	%list of all traces in ini_file    
   TA_delete_all_children(top_dat,fig_top);   
end
%delete(fig_top);		%delete the interface

