function top_out = ta_udpate_import_plots(top,answer,temp_raw)
%This function updates all the interpolation done on imported plots when operations
%affect them:	
%	1. Either the user selects remove/restore multiple plots from the advanced menu
%	2. The ini_file specifications for the current working trace contain
%		a 'dependent' field(which lists traces to match removed and resotored points
%		with the current trace).
%In either case if one of these traces, selected or dependent, is presently imported
%it will be updated here.
% 
% Input:
%		'top'			-contains all the data associated with the current working trace and
%						the visual point picking tool.See the function "TraceAnalysis_Tool"
%						for more information.
%		'answer'		-contains indices of traces currently operated on.
%		'temp_raw'	-contains uncleaned data points for all imported traces in a structure
%						form(prevents tracking all points,cleaned and raw).
% Ouput:
%		'top_out'	-The new top level data structure that tracks all information associated
%						with the current trace and the interface.


if ~exist('temp_raw')
   temp_raw = '';
end

%Update the bottom left axis if contains imported traces:
if ~isempty(top.trace_same_ax)
   for j=1:length(top.trc_plot_params(1).index)				%for each imported trace
      index_trc = top.trc_plot_params(1).index(j);			%get the index in the ini_file
      trc = top.list_of_traces(index_trc);           
      %if trace is currently operated on(in answer), and currently plotted then update:
      if ismember(index_trc,answer)
         %restore operation requires raw data(located in temp_raw structure):
         if ~isempty(temp_raw)
            top.trace_same_ax(trc.pts_restored,j) = temp_raw(index_trc).data;
         end         
         if isfield(trc,'pts_removed') & ~isempty(trc.pts_removed)
            trc.data(trc.pts_removed) = NaN;
            %Include all the interpolated points that are being tracked:
            if isfield(trc,'interpolated') & ~isempty(trc.interpolated)
               top.trace_same_ax(trc.pts_removed,j) = trc.interpolated(trc.pts_removed);
            end
         end         
      end
   end 
end
%Update the bottom right axis if contains imported traces:
if ~isempty(top.curr_ax_hdl)
    %for each trace imported, check if its been imported:
   for j=1:length(top.trc_plot_params(2).index)
      index_trc = top.trc_plot_params(2).index(j);
      trc = top.list_of_traces(index_trc);           
      %if trace is currently operated on(in answer), and currently plotted then update:
      if ismember(index_trc,answer)
         %restore operation requires raw data(located in temp_raw structure):
         if ~isempty(temp_raw)
            top.trace_same_ax_right.data(trc.pts_restored,j) = temp_raw(index_trc).data;               
         end          
         if isfield(trc,'pts_removed') & ~isempty(trc.pts_removed)
            trc.data(trc.pts_removed) = NaN;
            %Include all the interpolated points that are being tracked:
            if isfield(trc,'interpolated') & ~isempty(trc.interpolated)
               top.trace_same_ax_right.data(trc.pts_removed,j) = ...
                  trc.interpolated(trc.pts_removed);
            end
         end  
      end
   end 
end
%Update the top left axis if contains imported traces:
if ~isempty(top.other_ax_hdl)
   %for each trace imported, check if its been imported:
   for j=1:length(top.trc_plot_params(3).index)
      index_trc = top.trc_plot_params(3).index(j);
      trc = top.list_of_traces(index_trc);           
      %if trace is currently operated on(in answer), and currently plotted then update:
      if ismember(index_trc,answer)         
         %restore operation requires raw data(located in temp_raw structure):
         if ~isempty(temp_raw)                 
            top.trace_other_ax.data(trc.pts_restored,j) = temp_raw(index_trc).data;            
         end
         
         if isfield(trc,'pts_removed') & ~isempty(trc.pts_removed)
            trc.data(trc.pts_removed) = NaN;
            %Include all the interpolated points that are being tracked:
            if isfield(trc,'interpolated') & ~isempty(trc.interpolated)
               top.trace_other_ax.data(trc.pts_removed,j) = ...
                  trc.interpolated(trc.pts_removed);
            end
         end    
      end       
   end 
end
%Update the top left axis if contains imported traces:
if ~isempty(top.other_ax_hdl_right)
   %for each trace imported, check if its been imported:
   for j=1:length(top.trc_plot_params(4).index)				
      index_trc = top.trc_plot_params(4).index(j);			     
      trc = top.list_of_traces(index_trc);        
      %if trace is currently operated on(in answer), and currently plotted then update:
      if ismember(index_trc,answer)
         %restore operation requires raw data(located in temp_raw structure):
         if ~isempty(temp_raw)
            top.trace_other_ax_right.data(trc.pts_restored,j) = temp_raw(index_trc).data;               
         end        
         if isfield(trc,'pts_removed') & ~isempty(trc.pts_removed)
            trc.data(trc.pts_removed) = NaN;
            %Include all the interpolated points that are being tracked:
            if isfield(trc,'interpolated') & ~isempty(trc.interpolated)
               top.trace_other_ax_right.data(trc.pts_removed,j) = ...
                  trc.interpolated(trc.pts_removed);
            end
         end   
      end 
   end 
end
top_out = top;


