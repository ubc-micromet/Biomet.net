function y_ticks = yticks(x,dec)

x = x(:);
range = max(x)-min(x);

if ~exist('dec') | isempty(dec)
    if range< 1
        dec = 0.2;
    elseif range < 5
        dec = 1;
    elseif range < 10
        dec = 2;
    elseif range < 20
        dec = 4;
    elseif range < 50
        dec = 10;
    elseif range < 50
        dec = 10;
    elseif range < 100
        dec = 20;
    else 
        dec = 100;
    end
        
end

y_ticks = [floor(min(x)./dec).*dec:dec:ceil(max(x)./dec).*dec];
%y_ticks = [min(y_ticks) max(y_ticks)];

% In case something goes wrong or if there only is a single value
if isnan(sum(y_ticks))
    y_ticks = [0 dec];
elseif length(y_ticks) == 1
    y_ticks = [floor(y_ticks-1):1:ceil(y_ticks+1)];
end

return

