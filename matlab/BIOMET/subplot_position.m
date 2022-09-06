function pos_vec = subplot_position(no_row,no_col,i)
%SUBPLOT_POSITION Calculate position for tiled axes.
%
%   POS = SUBPLOT_POSITION(N,M,P) where N,M and P are used
%   in the same way they are in SUBPLOT, returns a position 
%   vector for a tiled axes set tighter than the default.
%   The vector might be used in SUBPLOT:
%   SUBPLOT('Position',SUBPLOT_POSITION(N,M,P));
%
%   Axis labels that cannot be used in the tight configuration 
%   can be removed using SUBPLOT_LABEL.
%
%   See also SUBPLOT_PRIMER, SUBPLOT, SUBPLOT_LABEL 

%   kai* Dec 02, 2003

left = 0.13;
bottom = 0.11;

height = (1-2*bottom)/no_row;			% height of plots
width  = (1-2*left)/no_col;			% width of plots

pos_win = get(gcf,'Position');
aspect_ratio = pos_win(3)/pos_win(4);

if no_row ~= 1
   height_of_figure = height - (aspect_ratio*height*0.025);
else
   height_of_figure = height;
end

if no_col ~= 1
   width_of_figure = width - (height*0.025);
else
   width_of_figure = width;
end

if no_col ~= 1
   this_col = mod(i,no_row);
else
   this_col = 1;
end

this_row = ceil(i/no_col);
this_col = i - (this_row-1)*no_col;

pos_vec = [(this_col-1)*width+left (no_row-this_row)*height+bottom width_of_figure height_of_figure];

return
