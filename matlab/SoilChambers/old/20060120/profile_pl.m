function[height] = profile_pl(DOY_start, dataOut);
%Program to plot CO2 profiles
%
% Possible DOY's 222:233 (Aug 10 to Aug 21, 1998)
%
% E.Humphreys      Oct 9, 1998

%setup for profile figs
height = [1 12 27 42]';
height_3d = height;
for i = 1:47
   height_3d = [height_3d height];
end

%change time series to ddoy
[ddoy] = ch_time(dataOut(:,1),8,3);

DOY = find(ddoy >=DOY_start & ddoy <=DOY_start+1);

fig = 0;

fig = fig+1; figure(fig);clf;

plot(dataOut(DOY(1),2:5),height,'-',dataOut(DOY(1)+8,2:5),height,'--',...
dataOut(DOY(1)+16,2:5),height,':',dataOut(DOY(1)+24,2:5),height,'-.',dataOut(DOY(1)+32,2:5),...
height,'-',dataOut(DOY(1)+40,2:5),height,'--',dataOut(DOY(1)+48,2:5),height,':');
xlabel('CO2(ppm)');ylabel('Height(m)');
legend('0hr', '4hr', '8hr','12hr','16hr','20hr','24hr',-1)


fig = fig+1; figure(fig);clf;
surface([ddoy(DOY)]',[dataOut(DOY,2:5)]',height_3d,[dataOut(DOY,2:5)]',...
   'edgecolor','bl','facecolor','interp','meshstyle','row');
set(gca,'ydir','rev');
view(45,50);grid;
%axis([ddoy(DOY(1)) ddoy(DOY(end)) 340 400 0 45]);
b = 0.75;
x = colormap;
x1 = [zeros(10,2) linspace(b,1,10)';x(11:end-10,:);linspace(1,b,10)' zeros(10,2)];
colormap (jet);
ylabel('CO_2(\mumol mol^{-1})')
xlabel('PST (hours)');
title('Concentration profiles at CR,1998');