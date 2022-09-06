function ta_delete_all_children(top,fig_top);
set(fig_top,'UserData',[]);
if ishandle(top.first_axis)
   delete(top.first_axis);
end
if ~isempty(top.curr_ax_hdl) & ishandle(top.curr_ax_hdl)
	delete(top.curr_ax_hdl);
end
if ~isempty(top.other_ax_hdl) & ishandle(top.other_ax_hdl)
   delete(top.other_ax_hdl);
end
if ~isempty(top.other_ax_hdl_right) & ishandle(top.other_ax_hdl_right)
   delete(top.other_ax_hdl_right);
end