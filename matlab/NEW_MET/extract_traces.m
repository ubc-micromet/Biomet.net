S=[];
tv = [];
DOY_offset = datenum(2002,1,0);
for i=floor(now-7):floor(now-1);
    tmpDate = datestr(i,2);
    tmpDate=tmpDate([7 8 1 2 4 5]);
    tmp =load(['\\paoa001\Sites\PAOA\hhour\' tmpDate 's.hp_under.mat']);
%    tmp =load(['e:\met-data\hhour\' tmpDate 's.hp_under.mat']);
    S=[S tmp];
    tv = [tv linspace(i+1/48,i+1,length(tmp.Stats))];
end
S1=[];
for i=1:length(S);
    S1 = [S1 S(i).Stats(:)'];
end

k=1:2;
x=[];
for i=1:length(S1);
    try
        x(i,k)=S1(i).UnderstoryEddy.Fluxes.LinDtr.AfterRot(k);
    catch
        x(i,k)= NaN;
    end
end
figure(1)
pth = biomet_path(2002,'pa','fl');
tvE = read_bor(fullfile(pth,'flxld_tv'),8);
ind = (find(tvE>= tv(1) & tvE<=tv(end)));
H = read_bor(fullfile(pth,'flxld.2'));
L = read_bor(fullfile(pth,'flxld.1'));
plot(tv-DOY_offset,x)
line(tvE(ind)-DOY_offset,[L(ind) H(ind)],'linewidth',2)
title('Sensible and latent heat fluxes')
zoom on
legend('L under','H under','L tower', 'H tower')


k=5;
x=[];
for i=1:length(S1);
    try
        x(i,k-k(1)+1)=S1(i).UnderstoryEddy.Fluxes.LinDtr.AfterRot(k);
    catch
        x(i,k-k(1)+1)= NaN;
    end
end

figure(gcf+1)
plot(tv-DOY_offset,x)
C = read_bor(fullfile(pth,'flxld.5'));
line(tvE(ind)-DOY_offset,C(ind),'linewidth',2,'color','r')
title('CO_2 flux')
legend('C under','C tower')
zoom on
k=5;
x=[];
x_min  =[];
x_max  =[];
x_std  =[];
for i=1:length(S1);
    try
        x(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(1,k);
        x_min(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(2,k);
        x_max(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(3,k);
        x_std(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(4,k);
    catch
        x(i,k-k(1)+1)= NaN;
        x_min(i,k-k(1)+1)= NaN;
        x_max(i,k-k(1)+1)= NaN;
        x_std(i,k-k(1)+1)= NaN;
    end
end
figure(gcf+1)
plot(tv-DOY_offset,[x x_max x_min x-x_std*3 x+x_std*3])
title('CO_2 (\mumoll/moll)')
zoom on

if 1==2
k=7;
t=[];
t_min  =[];
t_max  =[];
t_std  =[];
for i=1:length(S1);
    try
        t(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(1,k);
        t_min(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(2,k);
        t_max(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(3,k);
        t_std(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(4,k);
    catch
        t(i,k-k(1)+1)= NaN;
        t_min(i,k-k(1)+1)= NaN;
        t_max(i,k-k(1)+1)= NaN;
        t_std(i,k-k(1)+1)= NaN;
    end
end
figure(gcf+1)
plot(tv-DOY_offset,[t t_max t_min])
title('T_{licor}')
zoom on
end

k=4;
t=[];
t_min  =[];
t_max  =[];
t_std  =[];
for i=1:length(S1);
    try
        t(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(1,k);
        t_min(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(2,k);
        t_max(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(3,k);
        t_std(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(4,k);
    catch
        t(i,k-k(1)+1)= NaN;
        t_min(i,k-k(1)+1)= NaN;
        t_max(i,k-k(1)+1)= NaN;
        t_std(i,k-k(1)+1)= NaN;
    end
end
figure(gcf+1)
plot(tv-DOY_offset,[t t_max t_min])
title('T_{sonic}')
zoom on

k=1:3;
uvw  =[];
for i=1:length(S1);
    try
        uvw(i,k-k(1)+1)=S1(i).UnderstoryEddy.AfterRot.AvgMinMax(1,k);
    catch
        uvw(i,k-k(1)+1)= NaN;
    end
end
figure(gcf+1)
plot(tv-DOY_offset,(sum(uvw'.^2)).^0.5)
title('Wind speed (u^2+v^2)^{0.5}')
zoom on