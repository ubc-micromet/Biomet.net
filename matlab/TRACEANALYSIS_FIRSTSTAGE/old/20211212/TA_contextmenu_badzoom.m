function ta_contextmenu(action,clean_dependents)
%This is the callback function for the contextmenu(right mouse click) menu 
%For each menu option in the contextmenu, there is one switch case statement.
% Functionality:
%	1.  Remove/Restore selected points.
%	2.  Undo/Redo last operation.
%	3.	 Unselect All/Last points that are selected in the current window.
%	4.  Look at Fullview shows entire trace.
%	5.  Turning zoom on and off.
%
% Inputs:	
%			'action' 				-defines which callback for the contextmenu option selected
%			'clean_dependents'	-a flag indicating if the dependents of the current trace
%										should be cleaned(only off if removing/restoring points
%										from the advanced menu).
%
% Data is transferred using the 'UserData' property for the current working axis.
% All data for the current trace is located in this one place.
% See the function "TraceAnalysis_Tool" for more information about this top level
% data structure.

% revisions:
%   Oct 26, 2010
%   -explicitly use zoom v6 to prevent right click menu conflict with
%   matlab7 zoom tool.
%   Sept 14, 2007
%       -commented out David GG's local path setting (for chamber HF data)
%       (Nick)

top = get(gca,'UserData');			%Get all data associated with current trace
top.re_plot = 0;						%set flags for replotting and setting axes
top.new_axis = 0;
if ~exist('clean_dependents')
   clean_dependents = 'yes';
end
show_stats_flag = 0;
pointer_type = [];
%-----------------------------------------------------------------------
switch action
case 'remove_win'						%Remove selected points in current window
   if isempty(top.x_data)
      return
   end
   pointer_type = get(gcf,'pointer');
   set(gcf,'pointer','watch');
   xlim = get(gca,'xlim');				%get current axis dimensions
   ylim = get(gca,'ylim');
   DOY = top.trace_var.DOY;			%get decimal day of year
   orig = top.trace_var.data_old;	%get temporary uncleaned data
   
   %Get the indices of all points on the current x-axis:
   x_ind = find(DOY<= xlim(2)& DOY >= xlim(1));	
   
   %Track the points on the x-axis for the undo-operation:
   if strcmp(clean_dependents,'yes')
      undo.x_data = top.x_data;
      undo.list_of_traces = top.list_of_traces;
      top.undo = [top.undo undo];
      top.redo = [];
      top.redo.x_data = [];
      top.redo.list_of_traces = [];
   end
   
   
   %Alternate point removal and interpolation is required around clamped values
   %(Adjustments to clamped values should be done in the initialization file):
   ind_clmpMax=[];
   ind_clmpMin=[];
   if isfield(top.trace_var,'stats') & isfield(top.trace_var.stats,'index') & ...
         isfield(top.trace_var.stats.index,'indexPtsClampedMax')
      ind_clmpMax = top.trace_var.stats.index.PtsClampedMax;
      ind_clmpMin = top.trace_var.stats.index.PtsClampedMin;
   end
   
   %Find selected points within current window (both x-y directions) and replace with NaNs:
   xy_ind = find(DOY<= xlim(2) & DOY >= xlim(1) & orig <= ylim(2) & orig >= ylim(1));
   x_data = intersect(top.x_data, xy_ind);
   x_data = setdiff(x_data,ind_clmpMax);		%ignore selected points at clamped values 
   x_data = setdiff(x_data,ind_clmpMin);					
   if isempty(x_data)
      return					%if no points selected do nothing
   end
   top.trace_var.data(x_data) = NaN;	%put NaNs at all selected points.
   
   %reset the indices of points removed:
   top.trace_var.pts_removed = union(x_data,top.trace_var.pts_removed); 
   
   %Set the NaN points in the temporary uncleaned trace:
   orig(find(isnan(top.trace_var.data))) = NaN;
   
   %Puts NaNs at all points which were previously removed:
   orig(top.trace_var.pts_removed) = NaN;
   
   if isfield(top.trace_var,'stats') & isfield(top.trace_var.stats,'index') & ...
      isfield(top.trace_var.stats.index,'PtsInterpolated')
      %from basic cleaning interpolation:
      orig(top.trace_var.stats.index.PtsInterpolated) = NaN;	
   end
   
   orig(ind_clmpMax) = top.trace_var.data(ind_clmpMax);		%Use clamped values 
   orig(ind_clmpMin) = top.trace_var.data(ind_clmpMin);   
   
   %locate current window of interpolation.  Should only affect previously removed points
   %and currently selected points:  
   if top.max_interp >0     
      
      beforeNaNs = max(find(DOY < DOY(min(x_data))& ~isnan(orig)));
      if isempty(beforeNaNs)
         beforeNaNs = 1;
      end
      afterNaNs = min(find(DOY > DOY(max(x_data))& ~isnan(orig)));
      if isempty(afterNaNs)
         afterNaNs = length(DOY);
      end    
      
      x_span = [beforeNaNs:afterNaNs];     
      
		%Get x-axis span
      data_in(1:length(x_span)) = orig(x_span);					%Set which data to be interpolated
      data_out = ta_interp_points(data_in,top.max_interp);	%linear interpolation 
      top.trace_var.data(x_span) = data_out;			%Reset the current data
   end   
   
   %Reset all points currently restored:
   top.trace_var.pts_restored = setdiff(top.trace_var.pts_restored,x_data);
   %Reset selected points (any involved in current operation are removed): 
   top.x_data = setdiff(top.x_data,x_data);
   top.pts_cnt = length(top.x_data);
   set(top.hndls(4), 'label',sprintf('points selected = %6.3d', top.pts_cnt));  
   
   %Reset all the interpolation values at each point removed:
   top.trace_var.interpolated = sparse(length(top.trace_var.data),1);   
   top.trace_var.interpolated(top.trace_var.pts_removed) = ...
      top.trace_var.data(top.trace_var.pts_removed);
   
   trace_out = ta_update_statistics(top.trace_var);
   if ~isempty(trace_out)
      top.trace_var = trace_out;
   end        
   %Reset the equivalent trace in the current list of traces
   %(if user has imported a copy of the  working trace into another plot):
   indChange = [];
   if ~isempty(top.list_of_traces)
      top.list_of_traces(top.file_opts.trcInd).interpolated = top.trace_var.interpolated;
      top.list_of_traces(top.file_opts.trcInd).pts_removed = top.trace_var.pts_removed;    
      top.list_of_traces(top.file_opts.trcInd).pts_restored = top.trace_var.pts_restored;
      top.list_of_traces(top.file_opts.trcInd).stats = top.trace_var.stats;
      indChange = top.file_opts.trcInd;
   end   
   %In the case of dependent traces listed in the initialization file, remove
   %the same points in each:   
   if isfield(top.trace_var,'ind_depend') & ~isempty(top.trace_var.ind_depend)...
         & ~isempty(x_data) & strcmp(clean_dependents,'yes')
      top.list_of_traces = ta_update_mult_traces('remove',top.trace_var.ind_depend,...
         top.list_of_traces, x_data,top.file_opts,top.max_interp,top.DOY);      
      indChange = [indChange top.trace_var.ind_depend];
   end
   %Update current trace if imported into other axes locations, and if the dependent
   %traces are imported any of the four possible axes:
   top_out = ta_udpate_import_plots(top,indChange,'');
   if ~isempty(top_out)
      top = top_out;
   end
   
   top.re_plot = 1;   
   show_stats_flag = 1;
   
%-----------------------------------------------------------------------  
case 'restore_win'    
   if isempty(top.x_data)
      return
   end
   pointer_type = get(gcf,'pointer');
   set(gcf,'pointer','watch');
   xlim = get(gca,'xlim');				%Get current axis dimension
   ylim = get(gca,'ylim');
   DOY = top.trace_var.DOY;			%get decimal day of year vector
   orig = top.trace_var.data_old;	%get copy of uncleaned data from DB
   
   %find the selected points within the current window and replace with nans:
   x_ind = find(DOY<= xlim(2) & DOY >= xlim(1));		%within x-bounds      
   
   %Track points before operation if undo is called later:
   if strcmp(clean_dependents,'yes')
      undo.x_data = top.x_data;
      undo.list_of_traces = top.list_of_traces;
      top.undo = [top.undo undo];
      top.redo = [];
      top.redo.x_data = [];
      top.redo.list_of_traces = [];
   end
   
   %Get the indices of all clamped values(defined in the ini_file examples)
   ind_clmpMax=[];
   ind_clmpMin=[];
   if isfield(top.trace_var,'stats') & isfield(top.trace_var.stats,'index') & ...
         isfield(top.trace_var.stats.index,'indexPtsClampedMax')
      ind_clmpMax = top.trace_var.stats.index.PtsClampedMax;
      ind_clmpMin = top.trace_var.stats.index.PtsClampedMin;
   end
   
   %Find selected points within current window (both x-y directions) and replace with NaNs:
   xy_ind = find(DOY<= xlim(2) & DOY >= xlim(1) & orig <= ylim(2) & orig >= ylim(1));
   x_data = intersect(top.x_data,xy_ind);
   x_data = setdiff(x_data,ind_clmpMax);		%Ignore clamped points currently selected
   x_data = setdiff(x_data,ind_clmpMin);
   if isempty(x_data)
      return					%if no points selected do nothing
   end
   
   %restore all points selected in current window and update points removed/restored:
   top.trace_var.data(x_data) = orig(x_data);
   top.trace_var.pts_restored = union(top.trace_var.pts_restored,x_data);
   top.trace_var.pts_removed = setdiff(top.trace_var.pts_removed,x_data);  
   
   %Place NaNs at all removed points, points initially interpolated:
   orig(top.trace_var.pts_removed) = NaN;
   orig(find(isnan(top.trace_var.data))) = NaN;
   
   if isfield(top.trace_var,'stats') & isfield(top.trace_var.stats,'index') & ...
      isfield(top.trace_var.stats.index,'PtsInterpolated')
      orig(setdiff(top.trace_var.stats.index.PtsInterpolated,x_data)) = NaN;     %single point interpolation    
   end
   
   orig(ind_clmpMax) = top.trace_var.data(ind_clmpMax); 		%keep clamped values the same
   orig(ind_clmpMin) = top.trace_var.data(ind_clmpMin);
   
   %locate current window of interpolation.  Should only affect previously removed points
   %and currently selected points:
   if top.max_interp >0                         
      ind_real = find(~isnan(orig));         %find all non-NaN points
      
      %find maximum index position of a real point coming before the minimum selected point
      %in the current window.  If no such point, use leftmost selected point:
      beforeNaNs = max(find(DOY < DOY(min(x_data)) & ~isnan(orig)));
      if isempty(beforeNaNs)
         beforeNaNs = 1;
      end
      afterNaNs = min(find(DOY > DOY(max(x_data)) & ~isnan(orig)));
      if isempty(afterNaNs)
         afterNaNs = length(top.trace_var.DOY);
      end    
      
      x_span = [beforeNaNs:afterNaNs];								%Get x-axis domain
      data_in(1:length(x_span)) = orig(x_span);		%Set which data to be interpolated
      data_out = ta_interp_points(data_in,top.max_interp);	%fast linear interpolation
      top.trace_var.data(x_span) = data_out;			%Reset the current data     
   end             
   
   %Reset selected data to exclude all selected points not present in current operation:
   top.x_data = setdiff(top.x_data,x_data);
   top.pts_cnt = length(top.x_data);
   
   %Reset all interpolated values:
   top.trace_var.interpolated = sparse(length(top.trace_var.data),1);
   top.trace_var.interpolated(top.trace_var.pts_removed) = ...
      top.trace_var.data(top.trace_var.pts_removed);       
   
   trace_out = ta_update_statistics(top.trace_var);
   if ~isempty(trace_out)
      top.trace_var = trace_out;
   end      
   
   %Reset the equivalent trace in the current list of traces(this makes sense if
   %user has imported a copy of the  working trace into another plot):
   temp_raw = [];
   indChange = [];
   if ~isempty(top.list_of_traces)
      top.list_of_traces(top.file_opts.trcInd).interpolated = top.trace_var.interpolated;
      top.list_of_traces(top.file_opts.trcInd).pts_removed = top.trace_var.pts_removed;
      top.list_of_traces(top.file_opts.trcInd).pts_restored = top.trace_var.pts_restored;
      top.list_of_traces(top.file_opts.trcInd).stats = top.trace_var.stats;
      
      %If copy of working trace is in another axis, then update that axis:
      temp_raw(top.file_opts.trcInd).data = ...
         top.trace_var.data_old(top.trace_var.pts_restored);         
      indChange = top.file_opts.trcInd;
   end
   
   %check for dependent traces listed in the initialization file and update
   %the restored points: 
   if isfield(top.trace_var,'ind_depend') & ~isempty(top.trace_var.ind_depend)...
         & ~isempty(x_data)& strcmp(clean_dependents,'yes')         
      [top.list_of_traces, temp_rest ]= ta_update_mult_traces('restore',...
         top.trace_var.ind_depend,top.list_of_traces,x_data,top.file_opts,top.max_interp,top.DOY); 
      temp_rest(top.file_opts.trcInd).data = temp_raw(top.file_opts.trcInd).data;
      temp_raw = temp_rest;
      indChange = [indChange top.trace_var.ind_depend];         
   end  
   
   top_out = ta_udpate_import_plots(top,indChange,temp_raw);
   if ~isempty(top_out)
      top = top_out;
   end
   
   %track operation type to be used with undo/redo functionality:
   set(top.hndls(4), 'label',sprintf('points selected = %6.3d', top.pts_cnt));
   top.re_plot = 1;
   show_stats_flag = 1;  
    
%-----------------------------------------------------------------------   
case 'fullview',
   %If fullview is off, then reset current working axis to include all data points:
   %else if fullview if on, go back to where fullview was called from:
   str = get(top.hndls(2),'label');
   if strcmp(str,'Look At Fullview')
      set(top.hndls(2),'label','Return from Fullview');
      top.old_xy = top.ax_dim;
      top.ax_dim = [floor(min(top.trace_var.DOY)) round(max(top.trace_var.DOY)) top.ax_dim(3) top.ax_dim(4)];
   elseif strcmp(str,'Return from Fullview')
      set(top.hndls(2),'label','Look At Fullview');
      top.ax_dim = top.old_xy;
   end
   %In each case the zoom must be reset to avoid zoom back out into the wrong frame:
   zoom reset;
   top.re_plot = 1;		%replot all traces and update axis
   top.new_axis = 1;
%-----------------------------------------------------------------------   
case 'hfview',
    if length(top.x_data) > 5
        warndlg('Cannot display more than 5 high frequency files at a time.','Warning');
    % dgg January 19, 2006
    % Added a warning dialog for HF chamber data
    elseif top.trace_var.ini.measurementType ~= 'fl' & top.trace_var.ini.measurementType ~= 'ch' 
        warndlg('Cannot display high frequency data for non-eddy or non-chamber traces.','Warning');
%    elseif  strcmp(top.trace_var.ini.measurementType,'fl')~=1
%        warndlg('Cannot display high frequency data for non-eddy traces.','Warning');
    else
       if top.trace_var.ini.measurementType == 'fl' 
          for i = 1:length(top.x_data)
             view_hf_menu(top.trace_var.timeVector(top.x_data(i)),...
                top.trace_var.SiteID,...
                fr_get_local_path);
          end
       else
          % dgg January 19, 2006
          % Added codes to plot HF chamber data (see function fr_chamber_plot_HF)
          % **modified fr_set_site to use network paths--so that all Biomet
          % PCs can view chamber HF data: Nick, Sep 14, 2007
            for i = 1:length(top.x_data)
               %fr_set_site(top.trace_var.SiteID,'local'); commented out
               % Sep 14, 2007
               chNumStr = top.trace_var.ini.inputFileName;
               indTmp   = findstr(chNumStr,'.');
               chNum    = chNumStr(indTmp+1:end); 
               fr_chamber_plot_HF(chNum,...
                                  top.trace_var.timeVector(top.x_data(i)),...
                                  top.trace_var.SiteID,...
                                  i); 
            end
        end
    end
%-----------------------------------------------------------------------   
case 'unselect_last'
   if top.pts_cnt > 0
      top.x_data = top.x_data(1:end-1);			%unselect the last point selected
      top.pts_cnt = top.pts_cnt - 1;
      set(top.hndls(4), 'label',sprintf('points selected = %6.3d', top.pts_cnt));
      top.re_plot  = 1;
   end
%-----------------------------------------------------------------------   
case 'unselect_all'   
   if top.pts_cnt > 0				%Unselect all points
      top.x_data = [];
      top.pts_cnt = 0;
      set(top.hndls(4), 'label',sprintf('points selected = %6.3d', top.pts_cnt));
      top.re_plot  = 1;
   end
%-----------------------------------------------------------------------   
case 'zoom'      
   str = get(top.hndls(3),'label');		%Check if zoom is on or off    
   if strcmp(str,'Turn Zoom On')
      %If zoom is currently off:
      set(gcf,'WindowButtonUpFcn','');				%set all button callbacks off
      set(gcf,'WindowButtonDownFcn','');
      %zoom on;			
      zoom v6 on;	% Oct 26/2010: temporary workaround for matlab7 zoom tool which defaults to a right click menu.
      top.zoom_start = axis;							%get the starting axis when zoom called
      set(gcf,'pointer','arrow');
      %Now the only functionality when clicking on the working axis is the zoom command.
      %However, if the user zooms into the current axis, the other axes must also be
      %updated.  The function 'ta_zoom_control' does this, matching both x-axis and 
      %the SCALE change on the y-axis:
      set(gcf,'WindowButtonDownFcn','ta_zoom_control(''down'');zoom down;ta_zoom_control(''up'')');
      
      %Switch the context menu from the working axis to the figure surrounding the axis:
      set(gca,'UIContextMenu','');
      set(gcf,'UIContextMenu', top.hndls(1));
      
      %Change the label(which is also used as a flag to indicate if zoom is on or off)
      set(top.hndls(3), 'label','Turn Zoom Off');    
   else
      %zoom off;  
      zoom v6 off;  %Oct 26/2010: temporary workaround for matlab7 zoom tool which defaults to a right click menu.
      %Reset the button press callbacks to their original callbacks:
      set(gcf,'WindowButtonDownFcn','ta_get_area(''down'')','Interruptible','off');
      set(gcf,'WindowButtonUpFcn','ta_get_area(''up'')');
      
      %Rest the context menu to the current axis:
      set(gcf,'UIContextMenu', '');
      set(gca,'UIContextMenu', top.hndls(1));
      
      %Reset zoom label and pointer symbol:
      set(top.hndls(3), 'label','Turn Zoom On');
      set(gcf,'pointer','crosshair');
   end
      
%-----------------------------------------------------------------------   
case 'undo_op'
   %Undo the most recent operation:
   
   all_trcs = top.undo(end).list_of_traces;
   if ~isempty(all_trcs)
      
      pointer_type = get(gcf,'pointer');
      set(gcf,'pointer','watch');
      redo.x_data = top.x_data;
      redo.list_of_traces = top.list_of_traces;       
      top.redo = [top.redo redo];   
      
      top.list_of_traces = all_trcs;
      top.x_data = top.undo(end).x_data;						
      top.trace_var.stats = all_trcs(top.file_opts.trcInd).stats;
      top.trace_var.pts_removed = all_trcs(top.file_opts.trcInd).pts_removed;
      top.trace_var.pts_restored = all_trcs(top.file_opts.trcInd).pts_restored;
      top.trace_var.interpolated = all_trcs(top.file_opts.trcInd).interpolated;	
      top.undo = top.undo(1:end-1);		
      
      top.pts_cnt = length(top.x_data);
      set(top.hndls(4), 'label',sprintf('points selected = %6.3d', top.pts_cnt));
      top.re_plot = 1;
      
      top_out = ta_undo_allTraces(top);
      if ~isempty(top_out)
         top = top_out;
      end  
      show_stats_flag = 1; 
   end
   
%-----------------------------------------------------------------------   
case 'redo_op'
   %Redo the most recent undo:
   all_trcs = top.redo(end).list_of_traces;
   if ~isempty(all_trcs)
      pointer_type = get(gcf,'pointer');
      set(gcf,'pointer','watch');
      undo.x_data = top.x_data;
      undo.list_of_traces = top.list_of_traces;         
      top.undo = [top.undo undo];
      
      %Set the current trace to the redo values:
      top.list_of_traces = all_trcs;
      top.x_data = top.redo(end).x_data;						%Reset currently selected points
      top.trace_var.stats = all_trcs(top.file_opts.trcInd).stats;	
      top.trace_var.pts_removed = all_trcs(top.file_opts.trcInd).pts_removed;
      top.trace_var.pts_restored = all_trcs(top.file_opts.trcInd).pts_restored;
      top.trace_var.interpolated = all_trcs(top.file_opts.trcInd).interpolated;	
            
      %Reset the redo list:
      top.redo = top.redo(1:end-1);
                   
      top.pts_cnt = length(top.x_data);
      set(top.hndls(4), 'label',sprintf('points selected = %6.3d', top.pts_cnt)); 
      top.re_plot = 1;
      
      top_out = ta_undo_allTraces(top);
      if ~isempty(top_out)
         top = top_out;
      end       
      show_stats_flag = 1;  
   end
end
%-----------------------------------------------------------------------
temp = ta_plot_all_traces(top);		%replot traces and axis if flag set.
if ~isempty(temp)
   top.cb_plot = temp;
end
set(gca,'UserData',top);			%reset top level data structure

if  show_stats_flag == 1 & ~isempty(top.h_statbox)
   ta_statsmenu('stats');
end
if ~isempty(pointer_type)   
   set(gcf,'pointer',pointer_type);
end