function subplot_label(h,no_row,no_col,i,xlabel_vec,ylabel_vec,range_flag)
%SUBPLOT_LABEL Remove unwanted axis labels in tight subplot configuration
%   
%   SUBPLOT_LABEL(H,N,M,P) where H is a subplot axes and N,M and P 
%   give its position in the same way as in SUBPLOT, removes axis 
%   labels if they would overlap with a neighbouring axis.
% 
%   SUBPLOT_LABEL(H,N,M,P,XTICK,YTICK) also changes the tick values
%   and labels to the values given in the to axis
%
%   SUBPLOT_LABEL(H,N,M,P,XTICK,YTICK,1) furhtermore adjusts the 
%   axis to range from the minimum to maximum of the respective
%   tick values.
%
%   See also SUBPLOT_PRIMER, SUBPLOT, SUBPLOT_POSITION 

% kai* Dec 02, 2003

if exist('xlabel_vec') ~= 1 | isempty(xlabel_vec)
   xlabel_vec = get(h,'XTick');
end

if exist('ylabel_vec') ~= 1 | isempty(ylabel_vec)
   ylabel_vec = get(h,'YTick');
end

if exist('range_flag')~= 1 | isempty(range_flag)
   range_flag = 0;
end

if range_flag > 0
   set(h,'XLim',xlabel_vec([1 end]));
   set(h,'YLim',ylabel_vec([1 end]));
end

if range_flag ==2
   xlabel_vec = get(h,'XTick');
   ylabel_vec = get(h,'YTick');
end

this_row = ceil(i/no_col);
this_col = i - (this_row-1)*no_col;

xlabel_str = cellstr(num2str(xlabel_vec'));
xlabel_str = deleadingblank(xlabel_str);
ylabel_str = cellstr(num2str(ylabel_vec'));
ylabel_str = deleadingblank(ylabel_str);

pos_x = get(h,'XAxisLocation');
pos_y = get(h,'YAxisLocation');


if (this_row == no_row & this_col == 1 & no_col~=1 & strcmp(pos_x,'bottom')) 
   xlabel_str = [xlabel_str(1:end-1); cellstr('')];
elseif (this_row == no_row & this_col == 1 & no_col==1 & strcmp(pos_x,'bottom')) 
   xlabel_str = [xlabel_str(1:end)];
elseif (this_row == no_row & this_col > 1 & strcmp(pos_x,'bottom')) 
   xlabel_str = [xlabel_str(1:end)];
else
   xlabel_str = '';   
end

if range_flag == 2
    set(h,'XTickLabel',xlabel_str);
else
    set(h,'XTick',xlabel_vec,'XTickLabel',xlabel_str);
end

if ( ( this_col == 1 & strcmp(pos_y,'left') ) | ( this_col == no_col & strcmp(pos_y,'right') ) ) ...
      & this_row == 1 
   ylabel_str = [ylabel_str(1:end)];
elseif ( ( this_col == 1 & strcmp(pos_y,'left') ) | ( this_col == no_col & strcmp(pos_y,'right') ) ) ...
      & this_row > 1 
   ylabel_str = [ylabel_str(1:end-1); cellstr('')];
else
   ylabel_str = '';   
end
   
if range_flag == 2
    set(h,'YTickLabel',ylabel_str);
else
    set(h,'YTick',ylabel_vec,'YTickLabel',ylabel_str);
end

return

function out = deleadingblank(s)
% assume that s is a cellstr - check @cell\deblank
out=cell(size(s));
for i=prod(size(s)):-1:1,
   c = s{i};
   ind = find(c ~= 32);
   out{i} = c(ind(1):end);
end
