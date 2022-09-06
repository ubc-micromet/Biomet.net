function view_hf_plt(fig)

h_bt = findobj(fig,'Tag','bt_spec');
set(h_bt,'Enable','on');
h_bt = findobj(fig,'Tag','bt_1to1');
set(h_bt,'Enable','on');
h_bt = findobj(fig,'Tag','bt_corr');
set(h_bt,'Enable','on');

user_data = get(fig,'UserData');

for i = 1:3
   a = ['Trace' num2str(i)'];
   b = findobj(fig,'Tag',a);            % get the selected trace from popup menu
   k = get(b,'Value');
   c = get(b,'String');                 % read the string matrix
   
   title_name = user_data(k).title;    % extract the trace name string (cell array)
   trace_name = {deblank(c(k,:))};
   unit_name  = user_data(k).unit;
   trace = user_data(k).data;
   tv    = user_data(k).tv;
   
   subplot(3,1,i);                              
   plot([tv(1) tv(end)],[0 0],'w:',tv,trace(:,1),'y-','LineWidth',1.2);
   g = gca;
   set(g,'XGrid','on');
   p = get(g,'Position');
   set(g,'Position', [0.75.*p(1) p(2) 0.75.*p(3) 0.95.*p(4)],...
         'Color',[0 0.1 0.2],...
         'Xlim',[0 tv(end)],...
         'YLim',[mean(trace(:,1))-4*std(trace(:,1)) mean(trace(:,1))+4*std(trace(:,1))],...
         'Fontsize',10,...
         'Tag','plt_1');
      
   title([char(title_name)],'Fontsize',12);
	ylabel([char(unit_name)],'Fontsize',12);

end

xlabel('t (s)','Fontsize',12)

zoom_together(fig,'x','on');

return

