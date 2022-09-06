function[chamber_data] = fr_chamber_plt_hhour(x);

WINTER_TEMPERATURE_OFFSET = 30;

%-------------------------------------------------------------------------------
%Define paths to retrieve Comma delimited files and where to 
%read (and/or put) binary files
if exist('x')~= 1 | isempty(x)
    error 'Input data structure is missing!'
end

t1    =  x.Time_vector;
t1_ind=  x.Time_ind;
t     = interp1(t1_ind,t1,t1_ind(1):t1_ind(end));    
Dec_day  = fr_get_doy(t,0);

%------------------------------------------------------------------------------------

close all
fig = 1;

%figure(fig)
%plot(Dec_day, data_21x(:,8));
%fig = fig+1;

N = length(x.co2_conc);

figure(fig)
plot(t, x.co2_conc);
datetick('x',15)
zoom on
grid on
title('High-freq. CO2 measurements')
xlabel('Time')
ylabel('ppm')
tmp=get(gcf,'WindowButtonDownFcn') ;
set(gcf,'WindowButtonDownFcn',[tmp ';datetick1(''x'',15) ;'])

A = fr_get_doy(x.TimeVectorHH_21x,0);

fig=fig+1;
figure(fig)
plot(A, x.CO2(:,1),A, x.CO2(:,2),A, x.CO2(:,3))
title('CO2 Stats')
zoom on
grid on

fig = fig+1;
figure(fig)
plot(A, x.Temp(:,1),A, x.Temp(:,2),A, x.Temp(:,3))
title('Licor temperature Stats')
zoom on
grid on
fig = fig+1;

figure(fig)
plot(A, x.Press(:,1),A, x.Press(:,2),A, x.Press(:,3))
title('Licor pressure Stats')
zoom on
grid on

A = fr_get_doy(x.TimeVectorHH_CR10,0);

fig = fig+1;
figure(fig);
plot(A, x.stats(:,1));
axis([-inf inf 9.5 14.5])
title('battery voltage');
xlabel('DDOY');
ylabel('voltage');
zoom on
grid on
fig = fig+1;

figure(fig);
plot(A, x.stats(:,[2 26]));
axis([-inf inf [10 40]])
legend('Ctrl Box','Pump Box');
title('Box Temperatures');
zoom on
grid on

for i = 1:6
 fig = fig+1;
 figure(fig);
 plot(A, x.stats(:,i*4 -1: i*4 + 2));
 axis([-inf inf [0 30]-WINTER_TEMPERATURE_OFFSET])
title('Chamber Temperatures');
 zoom on
 grid on
end
%if (SiteID)=='CR';
     fig = fig+1;
    figure(fig);
    plot(A, x.stats(:,27:28));
    axis([-inf inf -inf inf]);
    title('Photosynthetically Active Radiation')
    zoom on
    grid on
%end

    N=max(get(0,'children'));
    for i=1:N;
        figure(i);
        if i~=N
            pause;
        end
    end

