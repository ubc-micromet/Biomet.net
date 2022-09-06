function ta_filemenu(action)
%This function lists all the callback routines for the 'file' menu and the 'trace' menu.
% INPUT:  'action'  - specifies which menu item was selected(defined in callbacks).
%
%Functionality:
%	1.	'reload' trace causes initial trace at program start to be reloaded.
%	2.	'curr_same' loads a trace into the bottom left axis (current working axis).
%  3. 'curr_next' loads a trace into a second axis(overlapping the current working axis).
%		so they appear to be in the same axis.
%	4.	'new_same' loads a trace into a new plot(top left)
%	5. 'new_next' loads a trace into a new plot(top right)
%			The new plots in 4&5 overlap each other and appear to be in the same plot
%  6. 'Rem_trc' removes a trace selected by the user from any of the plots in 2-5.
%	7. 'Quit' stops program execution.
%
% Data is transferred using the 'UserData' property for the current working axis.
% All data for the current trace is located in this one place.
% See the function "TraceAnalysis_Tool" for more information about the Top level data
% structure:
top = get(gca,'UserData');
top.re_plot = 0;
top.new_axis = 0;
pointer_type =[];
switch action
case 'reload'
   %top.trace_var = top.trace_var_st;
   %if isfield(top.trace_var,'stats')
%      top.pts_removed = top.trace_var.stats.index.pts_removed;
 %     top.pts_restored = top.trace_var.stats.index.pts_restored;
  % end
  % top.re_plot = 1;

case 'save_mat_file'
   
   if strcmp(top.local_use,'no')
      str = [top.file_opts.out_path top.file_opts.sv_fn];
      [fn,savepath] = uiputfile(str,'Save Trace Information:');
      if fn~=0
         trace_str = top.list_of_traces;
         save([savepath fn], 'trace_str');
      end      
   else            
      temp = top.trace_var;      
      [fn,savepath] = uiputfile([top.input_name '.mat'],'Save Trace Information:');
      if fn~=0
         [PTH,NAME,EXT,VER]= fileparts(fn);
         top.input_name = NAME;
         eval([NAME '= temp;']);         
         save([savepath fn],NAME);
      end
   end
      
case 'curr_same'  
   ta_zoom_control('down');		%reset axis and zoom properties
   zoom out;								%for each axis and trace currently plotted.
   zoom reset;
   ta_zoom_control('up');			
   top = get(gca,'UserData');
   
   str = {top.list_of_traces.variableName};   
   [answer, ok] = listdlg('PromptString','View Trace:','ListString',str,...
      'ListSize',[300 400],'InitialValue',[1:length(str)]);      
   if ok==1
      pointer_type =get(gcf,'pointer');
      set(gcf,'pointer','watch');
      %For each trace selected, load into current workspace and add to bottom left plot:
      for i=answer
         trace_new = top.list_of_traces(i);		%all traces in initialization file
         if ~isfield(trace_new,'data')  
            %This next function call is a variable load procedure depending on a few
            %user inputs(location of raw data, cache memory present, etc...)s
            trace_new = ta_load_traceData(trace_new,top.file_opts,top.DOY);            
            if isempty(trace_new)
               return
            end    
         end         
         %Track the data in a matrix:
         top.trace_same_ax =[top.trace_same_ax, trace_new.data];
         %Get some random colors that aren't in current use:
         col_temp = top.def_cols(top.col_curr(1),:);
         top.col_curr = top.col_curr(2:end);
         %Track all trace properties for each imported trace:
         top.trc_plot_params(1).color = [top.trc_plot_params(1).color; col_temp];
         top.trc_plot_params(1).index = [top.trc_plot_params(1).index i];         
         top.trc_plot_params(1).symbol =[top.trc_plot_params(1).symbol, {'-'}];
         top.trc_plot_params(1).width =[top.trc_plot_params(1).width, 1];
         top.trc_plot_params(1).size = [top.trc_plot_params(1).size, 8];
      end
      top.re_plot = 1;
      top.new_axis =1;
      %Update all traces located on the axes:
      top_out = ta_udpate_import_plots(top,answer,'');	%update all plots imported
      if ~isempty(top_out)
         top = top_out;
      end
   end
   
case 'curr_new'
   ta_zoom_control('down');		%reset axis and zoom properties
   zoom out;
   zoom reset;
   ta_zoom_control('up');
   top = get(gca,'UserData');
   str = {top.list_of_traces.variableName};  
   
   [answer, ok] = listdlg('PromptString','View Trace:','ListString',str,...
      'ListSize',[300 400],'InitialValue',[1:length(str)]);      
   
   if ok==1
      pointer_type =get(gcf,'pointer');
      set(gcf,'pointer','watch');
      for i=answer
         trace_new = top.list_of_traces(i);
         if ~isfield(trace_new,'data')
            %Variable load procedures depending on user inputs:
            trace_new = ta_load_traceData(trace_new,top.file_opts,top.DOY);
            if isempty(trace_new)
               return
            end         
         end       
         
         %If nothing plotted to the bottom right axis, then create the axis.
         %Make new axis black and set behind the working axis.
         %Set the working axis invisible.  Axis appear to be the same but actually two:
         if isempty(top.trace_same_ax_right)
            top.trace_same_ax_right = trace_new;      
         else
            %or just add the new data column to the existing trace:
            top.trace_same_ax_right.data = [top.trace_same_ax_right.data, trace_new.data];
         end
         %update the trace plotting information:
         col_temp = top.def_cols(top.col_curr(1),:);
         top.col_curr = top.col_curr(2:end);
         top.trc_plot_params(2).color = [top.trc_plot_params(2).color; col_temp];
         top.trc_plot_params(2).index = [top.trc_plot_params(2).index, i];         
         top.trc_plot_params(2).symbol =[top.trc_plot_params(2).symbol, {'-'}];
         top.trc_plot_params(2).width =[top.trc_plot_params(2).width, 1];
         top.trc_plot_params(2).size = [top.trc_plot_params(2).size, 8];
      end  
      pos = get(gca,'Position');
      pos(3) = 0.85;
      set(gca,'Position',pos,'color','black');
      top.curr_ax_hdl = axes('parent',gcf,'HandleVisibility',' off',...
         'Position',pos,'color','black','box','off');
      
      top.re_plot = 1; 
      top.new_axis =1;     
   end

case 'next_same'
   
   ta_zoom_control('down');		%reset axis and zoom properties
   zoom out;
   zoom reset;
   ta_zoom_control('up');
   top = get(gca,'UserData');
   str = {top.list_of_traces.variableName};
   
   [answer, ok] = listdlg('PromptString','View Trace:','ListString',str,...
      'ListSize',[300 400],'InitialValue',[1:length(str)]);         
   
   if ok==1
      pointer_type =get(gcf,'pointer');
      set(gcf,'pointer','watch');
      for i=answer
         trace_new = top.list_of_traces(i);
         if ~isfield(trace_new,'data')
            trace_new = ta_load_traceData(trace_new,top.file_opts,top.DOY);
            if isempty(trace_new)
               return
            end         
         end 
                                 
                  
         if isempty(top.trace_other_ax)     
            top.trace_other_ax = trace_new;
         else
            top.trace_other_ax.data = [top.trace_other_ax.data, trace_new.data];
         end
         col_temp = top.def_cols(top.col_curr(1),:);
         top.col_curr = top.col_curr(2:end);
         top.trc_plot_params(3).color = [top.trc_plot_params(3).color; col_temp];
         top.trc_plot_params(3).index = [top.trc_plot_params(3).index i];         
         top.trc_plot_params(3).symbol =[top.trc_plot_params(3).symbol, {'-'}];
         top.trc_plot_params(3).width =[top.trc_plot_params(3).width, 1];
         top.trc_plot_params(3).size = [top.trc_plot_params(3).size, 8];
      end
      pos = get(gca,'Position');
      pos(4) = 0.39;
      set(gca,'Position',pos);
      pos(2) = 0.57;
      top.other_ax_hdl = axes('parent',gcf,'HandleVisibility','off',...
         'Position',pos,'color','black','box','off');

      top.re_plot = 1;
      top.new_axis =1;    
   end  
   
case 'next_new'
   ta_zoom_control('down');		%reset axis and zoom properties
   zoom out;
   zoom reset;
   ta_zoom_control('up');
   top = get(gca,'UserData');   
   str = {top.list_of_traces.variableName};
   
   [answer, ok] = listdlg('PromptString','View Trace:','ListString',str,...
      'ListSize',[300 400],'InitialValue',[1:length(str)]);        
   
   if ok==1
      pointer_type =get(gcf,'pointer');
      set(gcf,'pointer','watch');
      for i=answer
         trace_new = top.list_of_traces(i);
           if ~isfield(trace_new,'data')
            trace_new = ta_load_traceData(trace_new,top.file_opts,top.DOY);
            if isempty(trace_new)
               return
            end         
         end 
                  
         if isempty(top.trace_other_ax_right)
            top.trace_other_ax_right = trace_new;       
         else
            top.trace_other_ax_right.data = [top.trace_other_ax_right.data, trace_new.data];
         end
         col_temp = top.def_cols(top.col_curr(1),:);
         top.col_curr = top.col_curr(2:end);
         top.trc_plot_params(4).color = [top.trc_plot_params(4).color; col_temp];
         top.trc_plot_params(4).index = [top.trc_plot_params(4).index i];         
         top.trc_plot_params(4).symbol =[top.trc_plot_params(4).symbol, {'-'}];
         top.trc_plot_params(4).width =[top.trc_plot_params(4).width, 1];
         top.trc_plot_params(4).size = [top.trc_plot_params(4).size, 8];
      end
      pos = get(gca,'Position');
      pos(3) = 0.85;
      pos(4) = 0.39;
      set(gca,'Position',pos);
      pos(2) = 0.57;      
      top.other_ax_hdl_right = axes('parent',gcf,'HandleVisibility',' off',...
         'Position',pos,'color','black','box','off');
      
      top.re_plot = 1; 
      top.new_axis =1;     
   end
   
case 'rem_trc'
   str = {top.list_of_traces.variableName};
   curr_ax = [];
   ind = [];
   if max(size(top.trc_plot_params))>=1
      if ~isempty(top.trc_plot_params(1).index)
         ind = [top.trc_plot_params(1).index];
         curr_ax=1;
      end
   end
   if max(size(top.trc_plot_params))>1
      if ~isempty(top.trc_plot_params(2).index)
         ind = [ind top.trc_plot_params(2).index];
         curr_ax = [curr_ax 2];
      end
   end
   if max(size(top.trc_plot_params))>2
      if ~isempty(top.trc_plot_params(3).index)
         ind = [ind top.trc_plot_params(3).index];
         curr_ax = [curr_ax 3];
      end
   end
   if max(size(top.trc_plot_params))>3
      if ~isempty(top.trc_plot_params(4).index)
         ind = [ind top.trc_plot_params(4).index];
         curr_ax = [curr_ax 4];
      end
   end
   if ~isempty(ind)
      str_t = str(ind);     
      
      [answer, ok] = listdlg('PromptString','Remove Trace:','ListString',str_t,...
         'ListSize',[300 400],'InitialValue',[1:length(str_t)]);
      
      if ok==1
         len = 0;
         for j=curr_ax
            index_trc = top.trc_plot_params(j).index;
            len_temp = len + length(index_trc);
            temp = find(answer<=len_temp & answer>len);
            remv = answer(temp) - len;
            len = len_temp;
            ind_rem = [];
            if ~isempty(remv)
               ind_rem = setdiff(1:length(index_trc),remv);
            end           
                      
            if j==1  & ~isempty(temp)           
               if min(size(top.trace_same_ax))==1
                  top.trace_same_ax = [];
                else
                  top.trace_same_ax = top.trace_same_ax(:,ind_rem);
               end
            end
            if j==2 & ~isempty(temp)  
               if min(size(top.trace_same_ax_right.data))==1 | isempty(ind_rem)
                  delete(top.curr_ax_hdl);
                  top.trace_same_ax_right = [];
                  top.curr_ax_hdl = '';
               else
                  top.trace_same_ax_right.data = top.trace_same_ax_right.data(:,ind_rem);
               end
            
            end
            if j==3 & ~isempty(temp)
               if min(size(top.trace_other_ax.data))==1 | isempty(ind_rem)
                  delete(top.other_ax_hdl);         
                  top.trace_other_ax = [];
                  top.other_ax_hdl = '';
               else
                  top.trace_other_ax.data =top.trace_other_ax.data(:,ind_rem);
               end
            end
            if j==4 & ~isempty(temp)
               if min(size(top.trace_other_ax_right.data))==1 | isempty(ind_rem)
                  delete(top.other_ax_hdl_right);         
                  top.trace_other_ax_right = [];
                  top.other_ax_hdl_right = '';
               else
                  top.trace_other_ax_right.data =top.trace_other_ax_right.data(:,ind_rem);
               end
            end
            if ~isempty(temp)
               if isempty(ind_rem)
                  top.trc_plot_params(j).color = [];
                  top.trc_plot_params(j).index = [];      
                  top.trc_plot_params(j).symbol = {};
                  top.trc_plot_params(j).width = [];
                  top.trc_plot_params(j).size = [];
               else
                  top.trc_plot_params(j).color = top.trc_plot_params(j).color(ind_rem,:);
                  top.trc_plot_params(j).index =  top.trc_plot_params(j).index(ind_rem);       
                  top.trc_plot_params(j).symbol = top.trc_plot_params(j).symbol(ind_rem);
                  top.trc_plot_params(j).width = top.trc_plot_params(j).width(ind_rem);
                  top.trc_plot_params(j).size = top.trc_plot_params(j).size(ind_rem);
               end
            end
            top.re_plot = 1;
            top.new_axis = 1;
         end
         
         pos = get(gca,'Position');
         if isempty(top.curr_ax_hdl)
            set(gca,'color','black');
            if isempty(top.other_ax_hdl_right)
               pos(3) = 0.9;
            end
         end
         
         if isempty(top.other_ax_hdl) & isempty(top.other_ax_hdl_right)
            pos(4) = 0.850;
         end
         set(gca,'Position',pos);
      end
   end
   
case 'quit'      
   %Quit traceanalysis_tool, but continue running program
   top.program_action = 'quit';
   set(gcf,'UserData',top);
   set(gcf,'Tag','digtool:Off');
   return
case 'terminate'
   %Quit all programs and return to matlab main prompt.
   top.program_action = 'terminate';
   set(gcf,'UserData',top);
   set(gcf,'Tag','digtool:Off');
   return
end

temp = ta_plot_all_traces(top);
if ~isempty(temp)
   top.cb_plot = temp;
end

set(gca,'UserData',top);

if ~isempty(top.h_legend)
   ta_optionmenu('legend');
end
if ~isempty(pointer_type)
   set(gcf,'pointer',pointer_type);
end
   
