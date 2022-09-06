function x_filled = fr_fill_from_regres(y,x,window)
%  x_filled = fr_fill_from_regres(y,x,window)
%
% Filling x from a regression of x against y. The regression is done
% for moving window of width window observations (default 10*48, i.e. ten
% days) 
% eg: air_temp_main_filled = fr_fill_from_regres(air_temperature_2,air_temperature_x,window)
% October, 2005
 
arg_default('window', 10*48);

x_modelled = NaN.*ones(size(x));
 
 for i=[1:window:length(x)-window-1 length(x)-window-1]
     i2=i+window;
     x1=x(i:i2);
     y1=y(i:i2);
     [a,sig_a,r,y_cl95] = linreg(y1,x1);
     newx=a(2)+a(1).*y1;
     x_modelled(i:i2) = newx;
 end

 ind_nan = find(isnan(x));
 x_filled = x;
 x_filled(ind_nan) = x_modelled(ind_nan);
