pth = 'h:\zoran\07-31-96\';
y = '60730';
fluxes = zeros(4,48);
k = 1;
for h = 6:6
    hh = 1;
    if h < 10
        h1 = ['0' num2str(h)];
    else
        h1 = num2str(h);
    end
    s = sprintf('%s%s%s',y,h1,num2str(hh));
    [wc1, wc2, wh1, wh2] = longflux(pth,s);
    fluxes(:,h*2+hh) = [wc1, wc2, wh1, wh2]';
    %disp(s)
    hh = 2;
    if h < 10
        h1 = ['0' num2str(h)];
    else
        h1 = num2str(h);
    end
    s = sprintf('%s%s%s',y,h1,num2str(hh));
    [wc1, wc2, wh1, wh2] = longflux(pth,s);
    fluxes(:,h*2+hh) = [wc1, wc2, wh1, wh2]';    
    %disp(s)
end
