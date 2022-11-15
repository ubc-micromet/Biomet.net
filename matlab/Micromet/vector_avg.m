function [WS, WD] = vector_avg(s,folder5min)

% Function to calculate vector average wind speed (WS) and (WD)
% Sara Knox                 File created:       Dec 20, 2019
%                           Last modification:  Dec 20, 2019
%

% Revisions (newest first)

ind_ws = find(strcmp({s.name},'MET_Young_WS_WVc1'));
ind_wd = find(strcmp({s.name},'MET_Young_WS_WVc2'));

ws = read_bor(fullfile(folder5min,s(ind_ws).name));
wd = read_bor(fullfile(folder5min,s(ind_wd).name));

% some basic filtering
ws(ws < 0 | ws > 25) = NaN;
wd(wd < 0.001 | ws > 359.999) = NaN;

u = -ws.*sin(2*pi.*wd./360);
v = -ws.*cos(2*pi.*wd./360);

[u_mean,cnt] = fastavg(u,6);
[v_mean,cnt] = fastavg(v,6);

WS = sqrt(u_mean.^2+v_mean.^2);
WD = atan2(u_mean,v_mean).*360/2/pi+180;
end
