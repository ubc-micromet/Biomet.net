function [list_of_traces, temp_raw]= ta_update_mult_traces(action, index_traces,...
    list_of_traces, x_data, file_opts, max_interp,DOY)
%This function is used to remove, restore, and interpolate in multiple traces.
%It is used with the "contextmenu" for dependent traces and with the "advancedmenu"
%for manually removing/restoring points in multiple traces.
%	INPUT:
%			action			 	-Is either remove or restore depending on user input.
%			index_traces	 	-The index of each trace in the list_of_traces.
%			list_of_traces		-The array of structures representing each trace listed
%									in the initialization file.
%			x_data				-The indices of currently selected points.
%			file_opts			-structure of input/output paths to load trace data.
%			max_interp			-The maximum interpolation length to use.
%
%	OUTPUT:
%			list_of_traces		-Input list of traces with fields "pts_removed", 
%									"pts_restored", and "interpolated" updated.
%			temp_raw				-Used to track points that changed over current interval
%									for each trace.

temp_raw = [];
for i=index_traces  
    %Track old and new points removed and restored:
    pts_rmv = [];
    pts_rst = [];
    %Check for any points already removed or restored:
    if isfield(list_of_traces(i),'pts_removed')
        pts_rmv = list_of_traces(i).pts_removed;		
    end
    if isfield(list_of_traces(i),'pts_restored')
        pts_rst = list_of_traces(i).pts_restored;                        
    end
    %Update all points removed or restored
    if strcmp(action,'restore')
        temp = union(pts_rst,x_data);
        list_of_traces(i).pts_removed = setdiff(pts_rmv,temp);
        list_of_traces(i).pts_restored = temp;                   
    else
        temp = union(pts_rmv,x_data);
        list_of_traces(i).pts_restored = setdiff(pts_rst,temp);
        list_of_traces(i).pts_removed = temp;  
    end      
    trace_out = ta_update_statistics(list_of_traces(i));
    if ~isempty(trace_out)
        list_of_traces(i) = trace_out;
    end
    
    %Update each interpolation point for each trace:         
    data_in = [];
    data_out = [];
    trc = list_of_traces(i);		%set temp variable for trace
    
    %First, load data without cleaning or interpolating:
    trc = ta_load_traceData(trc,file_opts,DOY,'no_interp');                             
    
    %If the data exists, then interpolate:
    if ~isempty(trc) & isfield(trc,'data') & isfield(trc,'data_old')             
        
        if strcmp(action,'restore')
            temp_raw(i).data = trc.data_old(trc.pts_restored);
        end     
        
        %Get the indices of real values surrounding the selected data:
        beforeNaNs = max(find(trc.DOY < trc.DOY(min(x_data)) & ~isnan(trc.data)));
        if isempty(beforeNaNs)
            beforeNaNs = 1;
        end
        afterNaNs = min(find(trc.DOY > trc.DOY(max(x_data)) & ~isnan(trc.data)));
        if isempty(afterNaNs)
            afterNaNs = length(trc.DOY);
        end        
        ind_real = [beforeNaNs:afterNaNs];           
        
        %Interplote over this window and reset the data:
        data_in(1:length(ind_real)) = trc.data(ind_real);                    
        
        % kai* & elyn Nov 27, 2001
        % Took out the interpolation for maxinterp == 0
        if max_interp ~= 0
            data_out = ta_interp_points(data_in,max_interp); 
        else
            data_out = data_in;
        end
        % end kai* & elyn
        trc.data(ind_real) = data_out;                     
        
        %get all indices that changed:
        ind_chg = find(trc.pts_removed >= min(ind_real) & trc.pts_removed <= max(ind_real));
        
        %Create a sparse array to track interpolation if doesn't exist:
        if ~isfield(list_of_traces(i),'interpolated') | ...
                isempty(list_of_traces(i).interpolated)
            list_of_traces(i).interpolated = sparse(length(trc.data),1);
            if ~isempty(list_of_traces(i).pts_removed)
                list_of_traces(i).interpolated(list_of_traces(i).pts_removed)=NaN;
            end         
        end                              
        %Update the each trace selected:    
        list_of_traces(i).interpolated(trc.pts_removed(ind_chg)) =...
            trc.data(trc.pts_removed(ind_chg));                  
    end           
end         
