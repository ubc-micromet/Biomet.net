function view_hf_data(fig)

view_hf_ini(fig,'on');

plt(1) = findobj(fig,'Tag','plt_1');
plt(2) = findobj(fig,'Tag','plt_2');
plt(3) = findobj(fig,'Tag','plt_3');

ButtonType = '';
stp = 0;
while stp>=0;
   
   % If the window is killed during wait for fig is gone...
   waitfor(fig,'CurrentPoint');
   if ishandle(fig)
      enable_str = get(findobj(fig,'Tag','bt_select'),'Enable');
      if strcmp(enable_str,'off')
         ButtonType = get(fig,'SelectionType');
      else
         ButtonType =[];
         stp = -1;
      end
   else
      ButtonType =[];
      stp = -2;
   end
   
   if strcmp(ButtonType,'normal');
      for i = 1:3
         ln_last = findobj(plt(i),'Tag','ln_last');
         if ~isempty(ln_last)
         	delete(ln_last);
	      end
      end
      
      h = get(gca,'Children');
      % Extract the data
      x = get(h(end-1),'XData');
      y = get(h(end-1),'YData');
      
      mouse_pos = get(gca,'CurrentPoint');	
      dx        = get(gca,'DataAspectRatio');	
      
      
      point_pos = mean(mouse_pos);
      [min_diff,ind_min] = min(((x-point_pos(1))./dx(1)).^2+((y-point_pos(2))./dx(2)).^2);
      
      for i = 1:3
         axes(plt(i));
	      h = get(plt(i),'Children');
   	   % Extract the data
      	y = get(h(end-1),'YData');
         line(x(ind_min),y(ind_min),'Marker','o','MarkerSize',10,...
            'MarkerEdgeColor',[255 0 0]./255,...
            'LineWidth',2,...
            'Tag','ln_last');
      end
      
      t = findobj(get(fig,'Children'),'Tag','Year');
      set(fig,'UserData',datenum(str2num(get(t,'String')),1,x(ind_min))+6/24);
      
      set(findobj(fig,'Tag','bt_plt'),'Enable','on');
      stp = get(fig,'UserData');
   end
end

% If the window is killed during waitfor fig is gone...
if ishandle(fig)
   view_hf_ini(fig,'off')
end

return