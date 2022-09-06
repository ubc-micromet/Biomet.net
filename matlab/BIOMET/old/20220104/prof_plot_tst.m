load c:\sites\paoa\hhour\010620s.hp.mat
x = stats.Profile.co2.Avg;
ind =  [1:12 14:48];
z = interp1(ind,x(ind,:),1:48);
h=surf(z,'facecol','interp','edgecol','none');
colormap(jet)
view(-90,90);
set(gca,'ydir','rev');
colorbar