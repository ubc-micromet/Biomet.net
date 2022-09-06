
% NEED TO DO THIS OVER SUCCESSIVE 10-DAY PERIODS !!!!

ind = find(~isnan(e39));
start = min(time(ind));
stop = max(time(ind));

period = find(time >= start & time <= stop);
time=time(period);
e39=e39(period);
data = e39;

k=2;

slope = diff(data)./diff(time);
ind = find(~isnan(slope));
out = find(slope > k*std(slope(ind)) | slope < -1*k*std(slope(ind)));
data(out) = NaN*ones(1,length(out));

ind = find(~isnan(data));
IntData = spline(time(ind),data(ind),time); 

ind = find(isnan(data));
data(ind) = IntData(ind); 

plot(time,[e39, data]);grid;

