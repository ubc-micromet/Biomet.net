function [doy,avg,stdev] = day_avg(t,data,start,stop,A_39,day);

%*****************************************************************%
% THIS MATLAB FUNCTION CALCULATES DAILY AVERAGES                  %
% Note: A "day" is defined by the decimal DOY time vector you are %
%       using ie 95.0 -> 95.9 is one day                          %
%                                                                 %
%       function [doy,avg] = day_avg(t,data,start,stop,A_39,day)  %
%                                                                 %
%       INPUT:                                                    %
%       t = decimal DOY (used to define your day)                 %
%       data = data you require daily averages for                %
%       start = begin averaging on this DOY                       %
%       stop = stop averaging on this DOY                         %
%       day 1 = A 39 > 0; day 0 = A 39 < 0; day 2 = 24 h          %
%       OUTPUT:                                                   %
%       doy = day of year                                         %
%       avg = daily average of variable                           %
%                                                                 %
%*****************************************************************%

if day == 1;
    ind = find(~ isnan(data) & A_39 > 0);
    elseif day == 0;
    ind = find(~ isnan(data) & A_39 < 0);
    elseif day == 2;
    ind = find(~ isnan(data));
end;    
    
t = floor(t(ind));
data = data(ind);

junk = find(t>=start);
st = junk(1)-1;
%start = t(junk(1));

doy=zeros(stop-start+1,1);
avg=zeros(stop-start+1,1);
stdev=zeros(stop-start+1,1);
   
ind = 1;
lendata = length(data);

%maxInd = start;
for i=start:stop;
    st = st + length(ind);
    stp = st + 50;

    if stp > lendata ;
        stp = lendata;
    end;
    ind = find(t(st:stp) == i);
    %if rem(i,50)==0;
        %disp(i);
    %end;
    if length(ind) > 0;
            xx = mean(data(ind+st-1));            
            xxx = std(data(ind+st-1));
            %maxInd = i;
        else
            xx = NaN;
            xxx = NaN;                
    end;
    doy(i-start+1)=i;
    avg(i-start+1)=xx;
    stdev(i-start+1)=xxx;                                           
end;          
%doy = doy(1:maxInd-start+1);
%avg = avg(1:maxInd-start+1);      

