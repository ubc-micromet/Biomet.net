function hndls = ta_create_contextmenu(axis_hndl)

%-----------------------------------------------------------------------
% Define the context menu:

ax_menu = uicontextmenu;
set(axis_hndl,'UIContextMenu', ax_menu);
c_remove = uimenu(ax_menu, 'Label', 'Remove Selected Points',...
   'Callback', 'ta_contextmenu(''remove_win'')');
c_restore = uimenu(ax_menu, 'Label', 'Restore Selected Points',...
   'Callback', 'ta_contextmenu(''restore_win'')');
c = uimenu(ax_menu, 'Label', 'Undo Last Operation',...
   'Callback','ta_contextmenu(''undo_op'')','separator','on');
c = uimenu(ax_menu, 'Label', 'Redo Last Operation',...
   'Callback','ta_contextmenu(''redo_op'')');

c = uimenu(ax_menu, 'Label', 'UnSelect All Points',...
   'Callback','ta_contextmenu(''unselect_all'')','separator','on');
c = uimenu(ax_menu, 'Label', 'UnSelect Last Point',...
   'Callback','ta_contextmenu(''unselect_last'')');
cb_fullview = uimenu(ax_menu, 'Label', 'Look At Fullview',...
   'Callback','ta_contextmenu(''fullview'')', 'separator','on');
% kai* June 27, 2001
% Inserted a new menu point - very basic for now
cb_hfview = uimenu(ax_menu, 'Label', 'Look at HF Data',...
   'Callback','ta_contextmenu(''hfview'')');
% end kai*
cb_zoom = uimenu(ax_menu, 'Label', 'Turn Zoom On',...
   'Callback','ta_contextmenu(''zoom'')', 'separator','on');
cb_n = uimenu(ax_menu, 'Label', 'Points Selected: 0','separator','on');
hndls = [ax_menu cb_fullview cb_zoom cb_n];