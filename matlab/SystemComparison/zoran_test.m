function [x] = zoran_test

%Get all data associated with current trace
top = get(gcf,'UserData');

if ~isfield(top,'children') % Assume this has not been done before
   top.x      = [];
   top.y      = [];
   fig_child  = findobj(get(gcf,'children'),'flat','type','axes');
   for i = 1:length(fig_child)
      ax_child      = get(fig_child(i),'children');
      % Children are added at the beginning, 
      % so this assumes that the relevant data was plotted first
      plot_child(i) = ax_child(end); 
      top.x         = [top.x; get(plot_child(i),'xdata')];
      top.y         = [top.y; get(plot_child(i),'ydata')];
	   top.xlabel(i) = {get(get(fig_child(i),'XLabel'),'String')};
   	top.ylabel(i) = {get(get(fig_child(i),'YLabel'),'String')};
   end
   top.children  = fig_child;
   top.ind = [];
   top.tv_ind = [];
end

p1=get(gca,'currentpoint');
p2 = p1(1,2);
p1 = p1(1,1);
%disp(sprintf('Fig: %6.4f  Axis: %6.4f  Object: %6.4f  x = %4.2f y = %4.2f ',gcf,gca, gco,p1,p2))
if gco == gcf
    set(gcf,'WindowButtonDownFcn','');
    set(gcf,'pointer','arrow')
    return;
end

ind     = [];
%for i=1:length(p1)
ax = axis;
aspectX = ((ax(2)-ax(1))/ax(4)-ax(3));
[d1,ind_d1] = min(sqrt((p1-top.x').^2+((p2-top.y')/aspectX).^2));
[d2,ind_d2] = min(d1);
ind         = [ind,ind_d1(ind_d2)];
%end              
if isfield(top,'p1')
   top.p1  = [top.p1;p1];
   top.p2  = [top.p1;p2];
   top.ind = [top.ind,ind];
else
   top.p1  = p1;
   top.p2  = p2;
   top.ind = ind;
end   
  
% plot selected datapoints and store handle
for i = 1:length(top.children)
   j = length(top.children)+1 -i;
   subplot(top.children(i));
   for k = 1:length(ind)
      h(k,i) = line([top.x(i,ind(k)) top.x(i,ind(k))], ...
         [top.y(i,ind(k)) top.y(i,ind(k))], ...
         'marker','o','color','c','markersize',5, ...
         'linewidth',1.5);
   end
end
if isfield(top,'h_line')
   top.h_line = [top.h_line;h];
else
   top.h_line = h;
end   
   
set(gcf,'UserData',top);			%adjust top level data structure
 
