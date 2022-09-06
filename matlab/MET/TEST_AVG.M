function [doy,avg] = test_avg(t,data,start,stop);

doy=zeros(stop-start+1,1);
avg=zeros(stop-start+1,1);
   
ind = find(~ isnan(data));
t = ceil(t(ind));
data = data(ind);

junk = find(t==start);
st = junk(1)-1;
ind = 1;
lendata = length(data);

for i=start:stop;
        st = st + length(ind);
        stp = st + 50;

                if stp > lendata ;
                        stp = lendata;
                end;
        ind = find(t(st:stp) == i);
                if rem(i,50)==0;
                        %disp(i);
                end;
%        disp(sprintf('st = %d stp = %d len = %d',[st stp length(ind)]))
                if length(ind) > 0;
                          xx = mean(data(ind+st-1));
                       else
                          xx == 0;                
                end;
                doy(i-start+1)=i;
                avg(i-start+1)=xx;                       
                                
end;                

