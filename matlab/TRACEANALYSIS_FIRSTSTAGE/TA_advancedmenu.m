function ta_advancedmenu(action)
%This is the callback function for the advanced menu on the trace analysis tool.
%For each menu option in the advanced menu, there is one switch case statement.
% Functionality:
%		1.	Viewing, Creating, Removing the running mean and std envelopes.  Any changes
%		   only take effect during current program execution.  All filter envelopes
%			should be set in the initialization file to make permanent.
%		2. Setting the interpolation default length.
%		3. Removing points from multiple traces at the same time.
%		4. Restoring points in multiple traces at the same time.
%     5. For dependent traces(as described in the ini_file example)
%			the procedures in 3 & 4 will be used to remove and restore points
%			when doing the manual cleaning.
%
% Inputs:	'action' 		-defines which callback for the current menu option selected
%				'depend_trc'	-defines which traces to clean from all present in the ini_file.
%									 These traces are dependent on current working trace.
%
% Data is transferred using the 'UserData' property for the current working axis.
% All data for the current trace is located in this one place.
% See the function "TraceAnalysis_Tool" for more information:

top = get(gca,'UserData');		%get current working trace data.
top.new_axis = 0;					%flag indicates if new axis need to be set.
top.re_plot = 0;					%flag indicates if traces need to be replotted.
show_stats_flag = 0;
pointer_type =[];
%-----------------------------------------------------------------------
switch action
case 'view_env'		%View any current running filter envelopes:   
   if ~isfield(top.trace_var,'runFilter_stats') | ...
         ~isfield(top.trace_var.runFilter_stats,'envelope_matrix') | ...
         isempty(top.trace_var.runFilter_stats.envelope_matrix)
      return
   end
      
   if top.env_mat==0
      set(gcbo,'label','Hide Current');		%label changes since envelopes are being viewed
      top.env_mat=1;
   else
      set(gcbo,'label','View Current');		
      top.env_mat=0;									%flag to plot any current running envelope
   end
   top.re_plot=1;
  %-----------------------------------------------------------------------
case 'create_env'
   prompt={'Enter the Filter Length:','Enter the Number of Standard Deviations:',...
      'Enter the filter type: ''standard=1'' or ''no phase shift=2'''};
   def={num2str(top.span),'5','2'};
   title='Running Filter Options';
   answer=inputdlg(prompt,title,1,def);		%Get input from user.
   if isempty(answer),return,end					%if no answer then quit.
   
   filt_len =str2num(char(answer(1)));			%Get new filter length and std:
   num_std = str2num(char(answer(2)));
   filt_opt = char(answer(3));
   if strcmp(filt_opt,'1')							%Get filter type: standard or no-phaseshift
      filt_opt = 1;
   else
      filt_opt = 2;
   end
   
   %Calculate a new running filter:      
   try
      trace_out = calc_runMeanStd(top.trace_var.data,filt_len,num_std,filt_opt,1);
   catch            
      warn_message(lasterr);
      return
   end 
  
   %Update the current data trace:
   top.trace_var.data = trace_out.data;
   top.env_mat=1;
   set(top.hndls(6),'label','Hide Current');
   %update running filter stats if present:
   if isfield(top.trace_var,'runFilter_stats')
      top.trace_var.runFilter_stats.envelope_matrix = ...		
         [top.trace_var.runFilter_stats.envelope_matrix ...		
            trace_out.runFilter_stats.envelope_matrix(:,1:2)];	%combine envelopes(new&old)
      top.trace_var.runFilter_stats.pts_per_envelope = ...
         [top.trace_var.runFilter_stats.pts_per_envelope ...	%combine points per envelope
            trace_out.runFilter_stats.pts_per_envelope];
      top.trace_var.runFilter_stats.ind_filtered = ...			%index of points removed
         [top.trace_var.runFilter_stats.ind_filtered; ...
            trace_out.runFilter_stats.ind_filtered];
   else
      top.trace_var.runFilter_stats = trace_out.runFilter_stats;	%Add first envelope
   end   
   top.re_plot = 1;
%-----------------------------------------------------------------------  
case 'remove_env'		%remove a filter envelope if exist
   %if does not exist return and do nothing
   if ~isfield(top.trace_var,'runFilter_stats') | ...          
         ~isfield(top.trace_var.runFilter_stats,'envelope_matrix') | ...
         isempty(top.trace_var.runFilter_stats.envelope_matrix)
      return
   end
   
   %get number of points taken out by most recent filter envelope:
   num_pts = top.trace_var.runFilter_stats.pts_per_envelope(end);
   dat_ind = [];
   if num_pts ~= 0
      %if points were taken out, then get the index position of each from:
      dat_ind = top.trace_var.runFilter_stats.ind_filtered(end - num_pts + 1:end);      
   end
   
   %Reset the current cleaned data with the old data:
   top.trace_var.data(dat_ind) = top.trace_var.data_old(dat_ind);
   
   %reset all the filter statistics:
   if min(size(top.trace_var.runFilter_stats.envelope_matrix)) <= 2        
      top.trace_var.runFilter_stats.pts_per_envelope = [];
      top.trace_var.runFilter_stats.ind_filtered = [];
      top.trace_var.runFilter_stats.envelope_matrix=[];
      set(top.hndls(6),'label','View Current');
      top.env_mat = 0;
   else
      top.trace_var.runFilter_stats.envelope_matrix = ...
         top.trace_var.runFilter_stats.envelope_matrix(:,1:end-2);
      top.trace_var.runFilter_stats.pts_per_envelope = ...
         top.trace_var.runFilter_stats.pts_per_envelope(1:end-1);
      if ~isempty(top.trace_var.runFilter_stats.ind_filtered)
         top.trace_var.runFilter_stats.ind_filtered = ...
            top.trace_var.runFilter_stats.ind_filtered(1:end-num_pts);
      end
      set(top.hndls(6),'label','Hide Current');
      top.env_mat = 1;      
   end   
   top.re_plot = 1;
%-----------------------------------------------------------------------
case 'interp_set'
   %get user information and reset the interpolation length for all traces:
   prompt={'Enter the maximum linear interpolation length (Choose 0 to 5)'};   
   def={num2str(top.max_interp)};
   ttl='Interpolation Options';
   % kai*, Nov 21, 2001
   % Disabled the interpolation
   %  answer = inputdlg(prompt,ttl,1,def);
   % interp_len = '';
   % if ~isempty(answer)
   %    s = cell2struct(answer,{'temp'},1);
   %    interp_len = str2num(s.temp);
   % end   
   % if ~isempty(interp_len) & interp_len >=0
   %    top.max_interp = interp_len;
   % end
   warndlg('At this stage no interpolation is allowed!','No Interpolation!');
   % end kai*
   
%-----------------------------------------------------------------------   
case 'rem_pts_traces'
   %remove points in multiple traces.  Dependent traces won't be effected.
   if isempty(top.x_data)
      return
   end  
   str = {top.list_of_traces.variableName};			%get list of current traces
    
   %get input from user:
   [answer, ok] = listdlg('PromptString','Remove Points in Traces:','ListString',str,...
      'ListSize',[300 400],'InitialValue',[1:length(str)]);								
     
   if ok==1     
      pointer_type = get(gcf,'pointer');
      set(gcf,'pointer','watch');
      
      %Save all the information if undo is requested, and reset redo:
      undo.x_data = top.x_data;
      undo.list_of_traces = top.list_of_traces;
      top.undo = [top.undo undo];
      top.redo = [];
      top.redo.x_data = [];
      top.redo.list_of_traces = [];
      
      %If the current trace is present in the list of multiple traces:
      if ismember(top.file_opts.trcInd, answer)
         %remove points from the current trace without removing 
         %from its dependents:
         set(gca,'UserData',top);
         top_old = top;         
         ta_contextmenu('remove_win','no');		
         top = get(gca,'UserData');
         answer = setdiff(answer,top.file_opts.trcInd);
         x_data = setdiff(top_old.x_data,top.x_data);
      else
         xlim = get(gca,'xlim');				%get current axis dimensions
         ylim = get(gca,'ylim');
         DOY = top.trace_var.DOY;			%get decimal day of year
         orig = top.trace_var.data_old;	%get uncleaned data
         %find the selected points within the current window and replace with nans:
         xy_ind = find(DOY<= xlim(2) & DOY >= xlim(1) & orig <= ylim(2) & orig >= ylim(1));
         x_data = intersect(top.x_data, xy_ind);        
      end      
      
      
      top.list_of_traces = ta_update_mult_traces('remove',answer,top.list_of_traces,...
         x_data,top.file_opts,top.max_interp,top.DOY);     
      
      %Update all imported traces currently plotted:
      top_out = ta_udpate_import_plots(top,answer,'');
      if ~isempty(top_out)
         top = top_out;
      end        
      top.re_plot = 1;            
      show_stats_flag = 1;   
   end
%-----------------------------------------------------------------------
case 'restore_mult_traces'
  
  %User can manually selects traces from the advanced menu.  The points selected
  %in the current trace will be restored in the traces selected.    
  %Dependent traces won't be effected. 
   if isempty(top.x_data)
      return
   end
   str = {top.list_of_traces.variableName};			%get list of current traces

   [answer, ok] = listdlg('PromptString','Restore Points in Traces:','ListString',str,...
      'ListSize',[300 400],'InitialValue',[1:length(str)]);								%get input from user
 
   
   if ok==1 
      pointer_type = get(gcf,'pointer');
      set(gcf,'pointer','watch');
      
      %Save all the information if undo is requested, and reset redo:
      undo.x_data = top.x_data;
      undo.list_of_traces = top.list_of_traces;
      top.undo = [top.undo undo];
      top.redo = [];
      top.redo.x_data = [];
      top.redo.list_of_traces = [];
      
      if ismember(top.file_opts.trcInd, answer)
         %restore points in the current trace without restoring 
         %in any of its dependents:
         set(gca,'UserData',top);
         top_old = top;
         ta_contextmenu('restore_win','no');
         top = get(gca,'UserData');
         answer = setdiff(answer,top.file_opts.trcInd);
         x_data = setdiff(top_old.x_data,top.x_data);
      else
         xlim = get(gca,'xlim');				%get current axis dimensions
         ylim = get(gca,'ylim');
         DOY = top.trace_var.DOY;			%get decimal day of year
         orig = top.trace_var.data_old;	%get uncleaned data
         %find the selected points within the current window and replace with nans:
         xy_ind = find(DOY<= xlim(2) & DOY >= xlim(1) & orig <= ylim(2) & orig >= ylim(1));
         x_data = intersect(top.x_data, xy_ind);        
      end  
      %Track the points on the x-axis for the undo-operation:    
      %undo.x_data = top.x_data;
      %undo.list_of_traces = top.list_of_traces;
      %top.undo = [top.undo undo];
      %top.redo = [];
      %top.redo.x_data = [];
      %top.redo.list_of_traces = [];
    
      %Temp_raw will save all values of points that will be restored.
      temp_raw.data = [];
      [top.list_of_traces,temp_raw]= ta_update_mult_traces('restore',answer,...
         top.list_of_traces,x_data,top.file_opts,top.max_interp,top.DOY);
      
      %Update each currently plotted trace that changed:
      top_out = ta_udpate_import_plots(top,answer,temp_raw);
      if ~isempty(top_out)
         top = top_out;
      end      
      top.re_plot = 1; 
      show_stats_flag = 1;         
   end    
end
%-----------------------------------------------------------------------
temp = ta_plot_all_traces(top);		%replot and set new axis as necessary 
if ~isempty(temp)
   top.cb_plot = temp;
end
set(gca,'UserData',top);		%Save all data to the current axis 'UserData'

if ~isempty(top.h_legend)
   ta_optionmenu('legend');
end
if  show_stats_flag == 1 & ~isempty(top.h_statbox)
   ta_statsmenu('stats');
end
if ~isempty(pointer_type)   
   set(gcf,'pointer',pointer_type);
end
