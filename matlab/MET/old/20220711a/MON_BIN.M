function result = mon_bin(time, start, stop, x)

%=============================================
% 
% 
% 
%=============================================
start_hr    = 0;
step_hr     = 1/24;
stop_hr     = 1;

hour = [0+0.5 : 1 : 24-1+0.5]';
a = zeros(size(hour));
b = zeros(size(hour));
[n,p] = size(hour) ;
 
for i = 1:size(hour);
    
    sprintf('   In Loop...Processing Cycle %d of %d',i,n)
    
    % Loop
    
    per = find( time >= start & time <= stop  & time-floor(time) >= start_hr & time-floor(time) < start_hr+step_hr);
        
    ind         = find(~isnan(x(per)));
    avg(i)      = mean(x(per(ind)));
    std_dev(i)  = std(x(per(ind)));
    [freq(i),p] = size(ind);
    std_err(i)  = std_dev(i) / sqrt(freq(i));
    
    start_hr = start_hr + step_hr;    
    
end;

%figure:plot(hour,avg,'o',hour,avg,'-',hour,avg+std_err,'+',hour,avg-std_err,'+');grid;
%title([top])    
%xlabel([x_name])
%ylabel([y_name])

result = [hour,avg',std_dev', std_err'];


