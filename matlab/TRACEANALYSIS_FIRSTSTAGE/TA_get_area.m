function ta_get_area(action)
% This function allows the user to pick points from the working axis using the mouse.
%
% Single point picking(set in options menu, default is exact selection):
%	1.	Use exact picking: pick a single point by clicking the left 
%		mouse button down and up quickly directly over the desired point.
%	2. Use x-axis picking:  Click over the x-axis and the nearest point along the x-axis
%		is selected.
%
% Multiple point picking:
%  1. Pick mulitiple points by dragging out a rectangular region while holding
%		the left mouse button down.  Release the mouse button and points become selected.
%	2. Another option is to drag out a very thin horizontal rectangular across the axis.
%		Then move the cursor slightly up or down and release the mouse button.  
%		The result is all points over the range of the thin horizontal rectangle become 
%		selected above or below(depending if the mouse moved slighty up or down).
%
% Data is transferred using the 'UserData' property for the current working axis.
% All data for the current trace is located in this one place.
% See the function "TraceAnalysis_Tool" for more information about the Top level data
% structure:

top = get(gca,'UserData');				%get top level data associated with current figure 

ButtonType = get(gcf,'SelectionType');
if ~strcmp(ButtonType,'normal');
   return
end
  
top.re_plot = 0;
top.new_axis = 0;
view_stats = 0;

str = get(top.hndls(3),'label');
if strcmp(str,'Turn Zoom Off')
   return
end
switch action
case 'down'
   top.pointstart = get(gca,'CurrentPoint');		%get start mouse position
   rbbox;
case 'up'
   if isempty(top.pointstart)
      return
   end  
   count_before = top.pts_cnt;
   
   PointNew = get(gca,'CurrentPoint');					%get end mouse position
   
   x_limits = get(gca,'xlim');							%get axis scale
   y_limits = get(gca,'ylim');
   ybound = abs(y_limits(2)-y_limits(1))*0.01;	%calculate bounds for curr window.
   xbound = abs(x_limits(2)-x_limits(1))*0.01;		
   
   ind_x = sort([PointNew(1,1) top.pointstart(1,1)]);	%new (x,y) and old (x,y) points
   ind_y = sort([PointNew(1,2) top.pointstart(1,2)]);	
   ind_xarea = ind_x(2) - ind_x(1);
   ind_yarea = ind_y(2) - ind_y(1);
   %check if the box dragged out by the mouse is large enough in both x and y directions.
   if ind_xarea >= xbound						
      if ind_yarea >= ybound					
         %If so, add the index positions within this box.
         ind_xadd = find(top.trace_var.DOY >= ind_x(1) & top.trace_var.DOY <= ind_x(2)...
            & top.trace_var.data_old >= ind_y(1) & top.trace_var.data_old <= ind_y(2));
      else
         %If the box is a long thin rectangle(along the x-axis) then add the index
         %positions either below or above the rectangle (this depends on how the mouse
         %is moved: slighly up cuts above, slightly down cuts below).
         if PointNew(1,2) >= top.pointstart(1,2)
            %cut up
            ind_xadd = find(top.trace_var.DOY >= ind_x(1) & top.trace_var.DOY <= ind_x(2)...
            & top.trace_var.data_old >= top.pointstart(1,2));
         else
            %cut down
            ind_xadd = find(top.trace_var.DOY >= ind_x(1) & top.trace_var.DOY <= ind_x(2)...
            & top.trace_var.data_old <= top.pointstart(1,2));
         end
      end
      top.x_data = union(ind_xadd,top.x_data);		%udpate the currently selected points.
      top.pts_cnt = length(top.x_data);
      if ~isempty(ind_xadd)
         top.re_plot = 1;
      end
      set(top.hndls(4), 'label',sprintf('Points Selected: %6.3d', top.pts_cnt));
   else 
      %Either the mouse has been clicked once, or a long thin rectangle along the y-axis
      %has been drawn out.
      str = get(top.hndls(5),'Label');
      if strcmp(str,'Selection Type: Exact')
         xpos = find( abs(top.trace_var.DOY - PointNew(1,1)) < xbound & ...
            abs(top.trace_var.data_old - PointNew(1,2))< ybound);
         [val temp] = min( abs(top.trace_var.DOY(xpos)- PointNew(1,1)));
         curr_pos = xpos(temp);
      else
         [val curr_pos] = min(abs(top.trace_var.DOY - PointNew(1,1)));
      end
      %This following code adds a new point to those already selected.  If the
      %new point is already selected, then it is deselected.
      rep=[];
      if ~isempty(curr_pos)
         if ~isempty(top.x_data)						
            rep = find(top.x_data==curr_pos);			% check if point already exists.
         end
         if isempty(rep)
            top.pts_cnt = top.pts_cnt + 1;            % if not, add it to the data
            top.x_data(top.pts_cnt) = curr_pos;
         else
            top.pts_cnt = top.pts_cnt - 1;					
            new_ind = find(top.x_data~=curr_pos);		% if yes, then remove the point.
            top.x_data = top.x_data(new_ind);
         end
         top.re_plot = 1;
         set(top.hndls(4), 'label',sprintf('Points Selected: %6.3d', top.pts_cnt));   
      end
   end
   if top.x_data > 0 & top.pts_cnt ~= count_before
      view_stats = 1;
   end   
   top.pointstart = [];
end
temp = ta_plot_all_traces(top);
if ~isempty(temp)
   top.cb_plot = temp;
end  
set(gca,'UserData',top);

if view_stats == 1 & ~isempty(top.h_selectedStats) & ishandle(top.h_selectedStats)
   
   ta_statsmenu('curr_pts')
end
