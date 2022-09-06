function subplot_label(h,no_row,no_col,i,xlabel,ylabel,range_flag)

if ~exist('xlabel') | isempty(xlabel)
   xlabel = get(h,'XTick');
end

if ~exist('ylabel') | isempty(ylabel)
   ylabel = get(h,'YTick');
end

if ~exist('range_flag') | isempty(range_flag)
   range_flag = 0;
end

this_row = ceil(i/no_col);
this_col = i - (this_row-1)*no_col;

xlabel_str = cellstr(num2str(xlabel'));
ylabel_str = cellstr(num2str(ylabel'));

pos_x = get(h,'XAxisLocation');
pos_y = get(h,'YAxisLocation');

if range_flag
   set(h,'XLim',xlabel([1 end]));
   set(h,'YLim',ylabel([1 end]));
end

if (this_row == no_row & this_col == 1 & no_col~=1 & strcmp(pos_x,'bottom')) 
   xlabel_str = [xlabel_str(1:end-1); cellstr('')];
elseif (this_row == no_row & this_col == 1 & no_col==1 & strcmp(pos_x,'bottom')) 
   xlabel_str = [xlabel_str(1:end)];
elseif (this_row == no_row & this_col > 1 & strcmp(pos_x,'bottom')) 
   xlabel_str = [xlabel_str(1:end)];
else
   xlabel_str = '';   
end

set(h,'XTick',xlabel,'XTickLabel',xlabel_str);

if ( ( this_col == 1 & strcmp(pos_y,'left') ) | ( this_col == no_col & strcmp(pos_y,'right') ) ) ...
      & this_row == 1 
   ylabel_str = [ylabel_str(1:end)];
elseif ( ( this_col == 1 & strcmp(pos_y,'left') ) | ( this_col == no_col & strcmp(pos_y,'right') ) ) ...
      & this_row > 1 
   ylabel_str = [ylabel_str(1:end-1); cellstr('')];
else
   ylabel_str = '';   
end
   
set(h,'YTick',ylabel,'YTickLabel',ylabel_str);

return
