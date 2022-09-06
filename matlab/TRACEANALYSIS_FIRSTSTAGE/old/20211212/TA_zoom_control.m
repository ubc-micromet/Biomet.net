function ta_zoom_control(action)
%This function matches the scaling change in the working axis(caused by a zoom command)
%with each of the other axes which contain imported plots.
%The result is that each imported axes will have an identical x-axis domain as the
%working axis, while the y-axis will change by the same scaling factor as in the 
%working axis.

% Data is transferred using the 'UserData' property for the current working axis.
% All data for the current trace is located in this one place.
% See the function "TraceAnalysis_Tool" for more information.

top = get(gca,'UserData');

%get the starting zoom axis since last zoom command:
zoom_start = top.zoom_start;

switch action
case 'down'
   %if action is down(button press) set the zoom start axis location:
   top.zoom_start = axis;
   set(gca,'UserData',top);
case 'up'   
   %Button has been release, so get the new working axis:
   zoom_end = axis;
   %calclate scaling factors to use with other plots:
   %calculate starting position scale factors:
   z_pos = (zoom_end(3) - zoom_start(3))/(zoom_start(4) - zoom_start(3));
   %calculate width and height scale 
   z_fact = (zoom_end(4) - zoom_end(3))/(zoom_start(4)  - zoom_start(3));
   
   %perform scaling on each set of axis(three possible extra axis):
   if ~isempty(top.curr_ax_hdl)
      %scale the bottom right axis the is behind the working axis:
      y_axis = get(top.curr_ax_hdl,'ylim');
      zoom_end(3) = y_axis(1) + z_pos*(y_axis(2) - y_axis(1));
      zoom_end(4) = zoom_end(3) + (y_axis(2) - y_axis(1))*z_fact;
      set(top.curr_ax_hdl,'xlim',[zoom_end(1) zoom_end(2)]);
      set(top.curr_ax_hdl,'ylim',[zoom_end(3) zoom_end(4)]);      
   end
   if ~isempty(top.other_ax_hdl)      
      %scale the top left axis:
      y_axis = get(top.other_ax_hdl,'ylim');
      zoom_end(3) = y_axis(1) + z_pos*(y_axis(2) - y_axis(1));
      zoom_end(4) = zoom_end(3) + (y_axis(2) - y_axis(1))*z_fact;
      set(top.other_ax_hdl,'xlim',[zoom_end(1) zoom_end(2)]);
      set(top.other_ax_hdl,'ylim',[zoom_end(3) zoom_end(4)]);
      
   end
   if ~isempty(top.other_ax_hdl_right)    
      %scale the top right axis:
      y_axis = get(top.other_ax_hdl_right,'ylim');
      zoom_end(3) = y_axis(1) + z_pos*(y_axis(2) - y_axis(1));
      zoom_end(4) = zoom_end(3) + (y_axis(2) - y_axis(1))*z_fact;
      set(top.other_ax_hdl_right,'xlim',[zoom_end(1) zoom_end(2)]);
      set(top.other_ax_hdl_right,'ylim',[zoom_end(3) zoom_end(4)]);     
   end
end
