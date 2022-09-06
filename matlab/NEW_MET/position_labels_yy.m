function h = position_labels_yy(h_org,tick_val,tick_label)
% h = position_labels_yy(h_org,xtick_val,tick_label)
%
% Based on kai*'s position_labels but tweaked to work properly with plotyy.
% Note: no zoom is possible and enabling it messes up the axes colors.

% CRS 09.02.05

pos_vec = get(h_org,'Position');
lim_vec = get(h_org,'XLim');
h = axes('Position',pos_vec,'XLim',lim_vec,'Visible','off');
label_pos = tick_val(1:end-1) + diff(tick_val)/2;
tick_label = cellstr(tick_label);
for i = 1:length(label_pos)
   text(label_pos(i),0,tick_label(i),'HorizontalA','center','VerticalA','top'); 
end