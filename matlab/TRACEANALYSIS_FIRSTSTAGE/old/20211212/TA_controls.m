function ta_controls(action)
%This function contains all the callback routines for buttons located on the 
%trace analysis tool: scroll/end right, scroll/end left,next trace, and previous trace.
%
%	INPUT: 'action' -specifies which button was pressed(defined in the callbacks).
%
% Data is transferred using the 'UserData' property for the current working axis.
% All data for the current trace is located in this one place.
% See the function "TraceAnalysis_Tool" for more information about the Top level data
% structure:

top = get(gca,'UserData');		%get current data stored in 'top' structure.
top.re_plot = 0;
top.new_axis = 0;

switch action
case 'scroll_right',
   
   
   str = get(top.hndls(2),'label');
   if ~strcmp(str,'Look At Fullview')
      return
   end
   xlim = get(gca,'xlim');   
   if (xlim(2)+ top.span) <= top.DOY(end)
      top.ax_dim(1)= top.ax_dim(1) + top.span;		
      top.ax_dim(2)= top.ax_dim(2) + top.span;
   else
      top.ax_dim(1) = top.DOY(end) - top.span;
      top.ax_dim(2) = top.DOY(end);
   end
   top.new_axis = 1;
   top.re_plot = 1;
   zoom reset;								%at each shift,the zoom must be resey.

case 'scroll_left',   
   
   str = get(top.hndls(2),'label');
   if ~strcmp(str,'Look At Fullview')
      return
   end   
   xlim = get(gca,'xlim');
   if (xlim(1)- top.span) >= 0
      top.ax_dim(1)= top.ax_dim(1) - top.span;
      top.ax_dim(2)= top.ax_dim(2) - top.span;		%shift left by span (default=100)      
   else
      top.ax_dim(1) = 0;
      top.ax_dim(2) = top.span;
   end
   top.new_axis = 1;
   top.re_plot = 1;
   zoom reset;								
  
case 'end_right'
   
   str = get(top.hndls(2),'label');
   if ~strcmp(str,'Look At Fullview')
      return
   end  
   top.ax_dim(1)= top.DOY(end) - top.span;
   top.ax_dim(2)= top.DOY(end);       
   top.new_axis = 1;
   top.re_plot = 1;
   zoom reset;   

case 'end_left'   
   
   str = get(top.hndls(2),'label');
   if ~strcmp(str,'Look At Fullview')
      return
   end  
   top.ax_dim(1)= 0;
   top.ax_dim(2)= top.span;   
   top.new_axis = 1;
   top.re_plot = 1;
   zoom reset;   

case 'next',
   %load next trace if exists:
   top.program_action = 'next';
   temp = 'Continue';
   ind = top.list_of_traces(1).ind_toView;  
   if strcmp(top.list_of_traces(ind(end)).variableName,top.trace_var.variableName)
      %Warn if user already at last trace:
      temp=questdlg('This is the last trace for manual cleaning. Continue with main program ?', ...
         'Warning', ...
         'Cancel','Continue','Continue');
      if strcmp(temp,'Continue')
        top.program_action = 'quit';
      end
      %warndlg('This is the last trace!');
      %temp = 'doNothing';
   elseif ~isempty(top.x_data)
      %Warn user that points are currently selected and wait for response:
      temp=questdlg('Points Are Still Selected!', ...
         'Warning', ...
         'Cancel','Continue','Continue');
   end 
   if strcmp(temp,'Continue')     
      set(gcf,'pointer','watch');
      set(gcf,'UserData',top);
      set(gcf,'Tag','digtool:Off');		%Quit current and load next
      return
   end
   
case 'prev',
   %load next trace if exists:
   top.program_action = 'prev';
   temp = 'Continue';
   ind = top.list_of_traces(1).ind_toView;
   if strcmp(top.list_of_traces(ind(1)).variableName,top.trace_var.variableName)
      %Warn if user already at first trace:
      warndlg('This is the first trace!');
      temp = 'doNothing';
   elseif ~isempty(top.x_data)
      %Warn user that points are currently selected and wait for response:
      temp=questdlg('Points Are Still Selected!', ...
         'Warning', ...
         'Cancel','Continue','Continue');
   end 
   if strcmp(temp,'Continue')
      set(gcf,'pointer','watch');
      set(gcf,'UserData',top);
      set(gcf,'Tag','digtool:Off'); %Quit current and load previous
      return
   end
end
temp = ta_plot_all_traces(top);		%plot as necessary
if ~isempty(temp)
   top.cb_plot = temp;
end
set(gca,'UserData',top);			%reset the top level data structure
