function result = bin(start, stop, bins, time, A_39, x, x_name, y, y_name, leaf, day)

%=============================================
% leaf 1 = yes          day 1 = A_39 > 0
% leaf 0 = no           day 0 = A_39 < 0
% leaf 2 = all 1994     day 2 = 24-h
%=============================================
%if start < 0;
%    step = (stop-start)/bins*2;
%    else step = (stop-start)/bins;
%end;    
step = (stop-start)/bins;
begin = [start : step : stop-step]';
over = [start+step : step: stop]';
a = zeros(size(begin));
b = zeros(size(begin));
[n,p] = size(begin) ;
 
for i = 1:size(begin);
    
    sprintf('   In Loop...Processing Cycle %d of %d',i,n)
    
    % Loop
    if      leaf == 1 & day == 2;
            per = find( x >= start & x < start + step & time > 152 & time < 250);
        elseif leaf == 1 & day == 1;
            per = find( x >= start & x < start + step & time > 152 & time < 250 & A_39 > 0);    
        elseif leaf == 1 & day == 0;
            per = find( x >= start & x < start + step & time > 152 & time < 250 & A_39 < 0);  
    
        elseif leaf == 0 & day == 2;
            per = find( x >= start & x < start + step & time > 0 & time <= 152);
        elseif leaf == 0 & day == 1;
            per = find( x >= start & x < start + step & time > 0 & time <= 152 & A_39 > 0);    
        elseif leaf == 0 & day == 0;
            per = find( x >= start & x < start + step & time > 0 & time <= 152 & A_39 < 0);   
         
        elseif leaf == 2 & day == 2;
            per = find( x >= start & x < start + step & time > 0 & time <= 365);
        elseif leaf == 2 & day == 1;
            per = find( x >= start & x < start + step & time > 0 & time <= 365 & A_39 > 0);    
        elseif leaf == 2 & day == 0;
            per = find( x >= start & x < start + step & time > 0 & time <= 365 & A_39 < 0);   
    end; 
     
    ind = find(~isnan(y(per)));
    avg(i) = mean(y(per(ind)));
    std_dev(i) = std(y(per(ind)));
    [freq(i),p] = size(ind);
    
    start = start + step;    
    
end;

if leaf == 1 & day == 1;
    top = 'Leaf DOY 152 to 250 1994; Daytime A_39 > 0';
    elseif leaf == 1 & day == 0;
    top = 'Leaf DOY 152 to 250 1994; Nighttime A_39 < 0';
    elseif leaf == 1 & day == 2;
    top = 'Leaf DOY 152 to 250 1994; 24 h';
    elseif leaf == 0 & day == 1;
    top = 'Pre-Leaf DOY 0 to 152 1994; Daytime A_39 > 0';
    elseif leaf == 0 & day == 0;
    top = 'Pre-Leaf DOY 0 to 152 1994; Nighttime A_39 < 0';
    elseif leaf == 0 & day == 2;
    top = 'Pre-Leaf DOY 0 to 152 1994; 24 h';
    elseif leaf == 2 & day == 1;
    top = '1994; Daytime A_39 > 0';
    elseif leaf == 2 & day == 0;
    top = '1994; Nighttime A_39 < 0';
    elseif leaf == 2 & day == 2;
    top = '1994; 24 h';
end;

figure:plot(begin+step/2,avg,'o',begin+step/2,avg,'-',begin+step/2,avg+std_dev,'+',begin+step/2,avg-std_dev,'+');grid;
title([top])    
xlabel([x_name])
ylabel([y_name])

figure:bar(begin+step/2',freq);
title([top])    
ylabel('Number of Observations');
xlabel([x_name]);

result = [begin+step/2,avg',std_dev',freq'];

ind = find(~isnan(x) & time > 152 & time < 250);
AVG_X = mean(x(ind))
STD_X = std(x(ind))

ind = find(~isnan(y) & time > 152 & time < 250);
AVG_Y = mean(y(ind))
STD_Y = std(y(ind))

