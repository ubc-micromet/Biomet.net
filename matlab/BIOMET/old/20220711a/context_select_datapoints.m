function context_select_datapoints(action)
%
%-----------------------------------------------------------------------
% this is the callback function for the select_data_menu(mouse click). 
% for each menu option in the contextmenu, there is one switch case statement.
% functionality:
%	1.  select points.
%	2.	 unselect all/last points that are selected in the current window.
%
% input:	'action' defines which callback for the select_data_menu option is selected
%
% select datapoints from a subplot by mouseclick 
% (one point per mouseclick, end input by hitting 'enter')
% output index of data points -> use to mark same datapoints in other subplot
%
% data is transferred using the 'UserData' property for the current working axis.
% all data for the current trace is located in this one place.
%
% created 10 July 2002, natascha kljun
%
%-----------------------------------------------------------------------

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
end

%-----------------------------------------------------------------------
switch action
   
   %Select point in current window
case 'select_point'						
   [p1,p2] = ginput;
   ind     = [];
   for i=1:length(p1)
      [d1,ind_d1] = min(sqrt((p1(i)-top.x').^2+(p2(i)-top.y').^2));
      [d2,ind_d2] = min(d1);
      ind         = [ind,ind_d1(ind_d2)];
   end              
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
   
   
  %-----------------------------------------------------------------------   
   
   %unselect the last point selected
case 'unselect_last'
   if size(top.h_line,1)>=1
      delete(top.h_line(end,:));
      top.h_line = top.h_line(1:end-1,:); 
      top.ind = top.ind(1:end-1);			
   else
      top.ind    = [];
      top.h_line = [];
   end
   
   %-----------------------------------------------------------------------
   %Unselect all points
case 'unselect_all'   
   if isfield(top,'ind')				
      delete(top.h_line);
      top.ind    = [];
      top.p1     = [];
      top.p2     = [];
      top.h_line = [];
   end
   
   %-----------------------------------------------------------------------   
   
   % View HF data
case 'view_hf'   
   h_hf = gcf;
   for i = top.ind
      view_hf_menu(top.tv(i),top.SiteId);
   end
   figure(h_hf);
   plotting_setup;
   %-----------------------------------------------------------------------   
   
   % View time series data
case 'view_time_series'   
   h_bt = findobj(gcf,'Tag','uim_reg');
   set(h_bt,'Enable','on');
   h_bt = findobj(gcf,'Tag','uim_ts');
   set(h_bt,'Enable','off');
   
   yy = datevec(top.tv(1));
   doy = top.tv - datenum(yy(1),1,0);
   for i = 1:length(top.children)
      axes(top.children(i));
      plot(doy,[top.x(i,:); top.y(i,:)]);
      top.x_org(i,:) = top.x(i,:) ;
      top.x(i,:) = doy;
      xlabel('DOY');
      ylabel(top.ylabel(i));
	   for k = 1:length(top.ind)
         h(k,i) = line([top.x(i,top.ind(k)) top.x(i,top.ind(k))], ...
            [top.y(i,top.ind(k)) top.y(i,top.ind(k))], ...
            'marker','o','color','c','markersize',5, ...
            'linewidth',1.5);
      end
   end
   if exist('h')
      top.h_line = h;
   end   
   
   %-----------------------------------------------------------------------   
   
   % View regression plots
case 'view_regression'   
   h_bt = findobj(gcf,'Tag','uim_reg');
   set(h_bt,'Enable','off');
   h_bt = findobj(gcf,'Tag','uim_ts');
   set(h_bt,'Enable','on');
   
   for i = 1:length(top.children)
      axes(top.children(i));
      top.x(i,:) = top.x_org(i,:) ;
      plot_regression(top.x(i,:),top.y(i,:),[],[],'ortho');
      xlabel(top.xlabel(i));
      ylabel(top.ylabel(i));
      for k = 1:length(top.ind)
         h(k,i) = line([top.x(i,top.ind(k)) top.x(i,top.ind(k))], ...
            [top.y(i,top.ind(k)) top.y(i,top.ind(k))], ...
            'marker','o','color','c','markersize',5, ...
            'linewidth',1.5);
      end
   end
   if exist('h')
      top.h_line = h;
   end   
   
   %-----------------------------------------------------------------------   
   
end

set(gcf,'UserData',top);			%adjust top level data structure

return