function autoGraphCheck(trace_str)
% autoGraphCheck(trace_str) Plot graphs for checking the site status

close all

%------------------------------------------------------------------
% Load plotting info
%------------------------------------------------------------------
SiteId = trace_str(1).SiteID;
eval(['plt_info = plt_ini_' SiteId ';']);

%------------------------------------------------------------------
% Find indecies for the last seven days
%------------------------------------------------------------------
gmt_shift = FR_get_offsetGMT(upper(SiteId))/24;
tv        = trace_str(1).timeVector - gmt_shift;
doy       = trace_str(1).DOY - gmt_shift;

dv_now = datevec(now);
if dv_now(1) == trace_str(1).Year
   disp_end = now;
else
   disp_end = tv(end);
end

[tv_dum,ind] = intersect(round(tv.*48)./48,round([ceil(disp_end)-7:1/48:ceil(disp_end)].*48)./48);
tv = tv(ind);

variableNames = {trace_str(:).variableName};

for i = 1:length(plt_info)
   % close all
   figure
   k = 1;
   
   %------------------------------------------------------------------
   % Find indecies for traces to plot
   %------------------------------------------------------------------
   [dum,ind_topleft]     = intersect(variableNames, plt_info(i).plotTopLeft);
   [dum,ind_topright]    = intersect(variableNames, plt_info(i).plotTopRight);
   [dum,ind_bottomleft]  = intersect(variableNames, plt_info(i).plotBottomLeft);
   [dum,ind_bottomright] = intersect(variableNames, plt_info(i).plotBottomRight);
   
   %------------------------------------------------------------------
   % Plot TopLeft 
   %------------------------------------------------------------------
   for j = 1:length(ind_topleft)
	   plt(j).data       = trace_str(ind_topleft(j)).data(ind);
   	plt(j).leg_text   = trace_str(ind_topleft(j)).ini.title;
   	plt(j).y_minmax   = trace_str(ind_topleft(1)).ini.minMax;
	   plt(j).y_label    = trace_str(ind_topleft(1)).ini.units;
		plt(j).tv         = tv;
      plt(j).plt_color  = get_col(k);
      plt(j).pos        = 1;
      k = k+1;
   end
   
   plt_subplot(plt);
   clear plt; 
   
   %------------------------------------------------------------------
   % Plot TopRight 
   %------------------------------------------------------------------
   for j = 1:length(ind_topright)
	   plt(j).data       = trace_str(ind_topright(j)).data(ind);
   	plt(j).leg_text   = trace_str(ind_topright(j)).ini.title;
   	plt(j).y_minmax   = trace_str(ind_topright(1)).ini.minMax;
	   plt(j).y_label    = trace_str(ind_topright(1)).ini.units;
		plt(j).tv         = tv;
      plt(j).plt_color  = get_col(k);
      plt(j).pos        = 2;
      k = k+1;
   end
   
   plt_subplot(plt);
   clear plt; 
   
   %------------------------------------------------------------------
   % Plot BottomLeft 
   %------------------------------------------------------------------
   for j = 1:length(ind_bottomleft)
	   plt(j).data       = trace_str(ind_bottomleft(j)).data(ind);
   	plt(j).leg_text   = trace_str(ind_bottomleft(j)).ini.title;
   	plt(j).y_minmax   = trace_str(ind_bottomleft(1)).ini.minMax;
	   plt(j).y_label    = trace_str(ind_bottomleft(1)).ini.units;
		plt(j).tv         = tv;
      plt(j).pos        = 3;
      plt(j).plt_color  = get_col(k);
      k = k+1;
   end
   
   plt_subplot(plt);
   clear plt; 
   
   %------------------------------------------------------------------
   % Plot BottomRight 
   %------------------------------------------------------------------
   for j = 1:length(ind_bottomright)
	   plt(j).data       = trace_str(ind_bottomright(j)).data(ind);
   	plt(j).leg_text   = trace_str(ind_bottomright(j)).ini.title;
   	plt(j).y_minmax   = trace_str(ind_bottomright(1)).ini.minMax;
	   plt(j).y_label    = trace_str(ind_bottomright(1)).ini.units;
		plt(j).tv         = tv;
      plt(j).pos        = 4;
      plt(j).plt_color  = get_col(k);
      k = k+1;
   end
   
   plt_subplot(plt);
   clear plt; 
   
   exportfig(gcf,['c:\temp\graph_' SiteId '_' num2str(i)],...
      'Format','jpeg100',...
      'LineMode','fixed','LineWidth',1,...
      'color', 'cmyk','height',5);
   
end

return


function plt_subplot(plt)

tick_val = plt(1).tv(1):plt(1).tv(end);
tick_label = datestr(tick_val,6);

if plt(1).pos <= 2
   pos = subplot_position(2,1,1);
else
   pos = subplot_position(2,1,2);
end   

if mod(plt(1).pos,2) == 1
   axes('Position',pos,...
      'XAxisLocation','bottom','YAxisLocation','left',...
      'Box','off','Color','none');
   x_legend = tick_val(1)+0.5;
else
   axes('Position',pos,...
      'XAxisLocation','top','YAxisLocation','right',...
      'Box','off','Color','none');
   x_legend = tick_val(floor(length(tick_val)/2))+0.5;
end

for j = 1:length(plt)
   line(plt(j).tv,plt(j).data,'Color',plt(j).plt_color)
   axis([tick_val([1 end]) plt(j).y_minmax])
   yticks = get(gca,'YTick');
   subplot_label(gca,2,1,1,tick_val,yticks,0);
   ylabel(plt(j).y_label);
   
	y_legend = plt(j).y_minmax(1)+diff(plt(j).y_minmax)*(1-j*0.1);
   
   line([x_legend x_legend+0.5],[y_legend y_legend],'Color',plt(j).plt_color)
   text(x_legend+0.6,y_legend,plt(j).leg_text,'Fontsize',8);
   
   if plt(1).pos == 4
      position_labels(gca,tick_val,tick_label);      
   end
   
end

return

function c = get_col(k)

col = [...
      1 0 0;...
      0 1 0;...
      0 0 1;...
      1 1 0;...
      1 0 1;...
      0 1 1;...
   ];

c = col(mod(k-1,6)+1,:);

return

