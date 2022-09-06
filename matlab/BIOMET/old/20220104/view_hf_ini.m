function view_hf_ini(fig,flag);
% Function that creates and deletes everything associated with view_hf_plt

switch lower(flag)
case 'on'
   zoom_together(fig,'x','clear');
   set(fig,'Pointer','crosshair');
   bt_sel = findobj(fig,'Tag','bt_select');
   set(bt_sel,'Enable','off');
   
   h_bt = findobj(fig,'Tag','bt_plt');
   set(h_bt,'Enable','on');
   
   h_bt = findobj(fig,'Tag','bt_stp');
   set(h_bt,'Enable','on');
   
case 'off'
   set(fig,'UserData',[]);
   
   h_bt = findobj(fig,'Tag','bt_plt');
   set(h_bt,'Enable','off');
   
   h_bt = findobj(fig,'Tag','bt_stp');
   set(h_bt,'Enable','off');
   
   set(findobj(fig,'Tag','bt_select'),'Enable','on');
   set(fig,'Pointer','arrow');
   zoom_together(fig,'x','on');
   
   % Get handles for the three plots
	plt(1) = findobj(fig,'Tag','plt_1');
	plt(2) = findobj(fig,'Tag','plt_2');
	plt(3) = findobj(fig,'Tag','plt_3');
   for i = 1:3
      ln_last = findobj(plt(i),'Tag','ln_last');
      if ~isempty(ln_last)
         delete(ln_last);
      end
   end
   
end

return
   