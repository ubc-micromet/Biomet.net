function view_hf_empty(fig)

user_data = get(fig,'UserData');
tv           = user_data.tv;

for i = 1:3
   title_name(i) = {['Variable ' num2str(i)]};    % extract the trace name string (cell array)
   unit_name(i)  = {''};
end

% plot trace1
subplot(3,1,1);                              
plot([tv(1) tv(end)],[0 0],'w:');
g = gca;
set(g,'XGrid','on');
p = get(g,'Position');
set(g, 'Position', [0.75.*p(1) p(2) 0.75.*p(3) 0.95.*p(4)],'Color',[0 0.1 0.2],...
   'Xlim',[0 tv(end)],'YLim',[-1 1],...
   'Fontsize',10,'Tag','plt_1');
title([char(title_name(1))],'Fontsize',12);
ylabel([char(unit_name(1))],'Fontsize',12);

% plot trace2
subplot(3,1,2);                              
plot([tv(1) tv(end)],[0 0],'w:');
g = gca;
set(g,'XGrid','on');
p = get(g,'Position');
set(g, 'Position', [0.75.*p(1) p(2) 0.75.*p(3) 0.95.*p(4)],'Color',[0 0.1 0.2],...
   'Xlim',[0 tv(end)],'YLim',[-1 1],...
   'Fontsize',10,'Tag','plt_1');
title([char(title_name(2))],'Fontsize',12);
ylabel([char(unit_name(2))],'Fontsize',12);

% plot trace3
subplot(3,1,3);                              
plot([tv(1) tv(end)],[0 0],'w:');
g = gca;
set(g,'XGrid','on');
p = get(g,'Position');
set(g, 'Position', [0.75.*p(1) p(2) 0.75.*p(3) 0.95.*p(4)],'Color',[0 0.1 0.2],...
   'Xlim',[0 tv(end)],'YLim',[-1 1],...
   'Fontsize',10,'Tag','plt_1');
title([char(title_name(3))],'Fontsize',12);
ylabel([char(unit_name(3))],'Fontsize',12);
xlabel('t (s)','Fontsize',12)

zoom_together(fig,'x','on');

return

