function h = position_labels(h_org,tick_val,tick_label)
% h = position_labels(h_org,xtick_val,tick_label)
%
% Positions  the monthly  tick  labels  given  in  the string matrix xtick_label 
% centered between the ticks given by xtick_val. The last label is skipped over. 
% The  function  first  generates an invisible axes  at the same position as the 
% graph represented  by  the  handle h_org. Then  it writes the labels into this 
% new axes as text. The handle to this new axes is the return argument.
%
% See also multiple_year_ticks

pos_vec = get(h_org,'Position');
lim_vec = get(h_org,'XLim');
h = axes('Position',pos_vec,'XLim',lim_vec,'Visible','off');
label_pos = tick_val(1:end-1) + diff(tick_val)/2;
tick_label = cellstr(tick_label);
for i = 1:length(label_pos)
   text(label_pos(i),0,tick_label(i),'HorizontalA','center','VerticalA','top'); 
end

% Reverse the order of plot children, so that the new axis 
% is first and zoom works on the one after it.
h_p = get(h_org,'Parent');
h_c = get(h_p,'Children');
set(h_p,'Children',h_c(end:-1:1));

subplot(h_org);