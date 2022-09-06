colordef white
pos = get(0,'screensize');
set(groot,'defaultfigureposition',[8 pos(4)/2-20 pos(3)-20 pos(4)/2-35]);
lineWidth = 2; 

%%
pth = '\\paoa001\Sites\LGR2\hhour\';
ext = '.hGLGR2.mat';
GradientStatsX = [];
t      = [];
days = [1:10];

firstDay = datenum(floor(now-1)-length(days)+1);
currentDate = firstDay;
for i = days
    
    filename_p = fr_DateToFileName(currentDate+.03);
    filename   = filename_p(1:6);
    
    pth_filename_ext = [pth filename ext];
    if ~exist([pth filename ext],'file')
        pth_filename_ext = [pth filename 's' ext];
    end
    
    if exist(pth_filename_ext,'file')
        try
            load(pth_filename_ext); %#ok<*LOAD>
            if i == 1
                GradientStatsX = [GradientStats]; %#ok<*NBRAK>
                t      = [currentDate+1/48:1/48:currentDate+1];
            else
                GradientStatsX = [GradientStatsX GradientStats]; %#ok<*AGROW>
                t      = [t currentDate+1/48:1/48:currentDate+1];
            end
            
        catch ME
            disp(ME);
        end
    end
    currentDate = currentDate + 1;
    
end
%%
StatsX = [];
tLGR1      = [];
ext = '.hLGR1.mat';
pth = '\\paoa001\Sites\LGR1\hhour\';
currentDate = firstDay;
for i = days
    
    filename_p = fr_DateToFileName(currentDate+.03);
    filename   = filename_p(1:6);
    
    pth_filename_ext = [pth filename ext];
    if ~exist([pth filename ext],'file')
        pth_filename_ext = [pth filename 's' ext];
    end
    
    if exist(pth_filename_ext,'file')
        try
            load(pth_filename_ext); %#ok<*LOAD>
            if i == 1
                StatsX = [Stats]; %#ok<*NBRAK>
                tLGR1      = [currentDate+1/48:1/48:currentDate+1];
            else
                StatsX = [StatsX Stats]; %#ok<*AGROW>
                tLGR1      = [tLGR1 currentDate+1/48:1/48:currentDate+1];
            end
            
        catch ME
            disp(ME);
        end
    end
    currentDate = currentDate + 1;
    
end
%%
hhourMax = length(GradientStatsX);
for variableX = {'N2O','CH4','H2O_LGR','H2O_7200','CO2'}
    variableStr = char(variableX);
    switch variableStr
        case 'H2O_LGR'
            maxValue = 400000;
            gain = 1000;
        case 'H2O_7200'
            maxValue = 100;
            gain = 1;
        case 'CO2'
            maxValue = 1000;
            gain = 1;
        otherwise
            maxValue = 10;
            gain=1;
    end
    for k=1:hhourMax
        try
            LGR2.(variableStr).upper(k,1)=GradientStatsX(k).(variableStr).upper.Avg/gain;
            LGR2.(variableStr).lower(k,1)=GradientStatsX(k).(variableStr).lower.Avg/gain;
            if max(abs([LGR2.(variableStr).upper(k) LGR2.(variableStr).lower(k)] )) > maxValue
                LGR2.(variableStr).upper(k,1) = NaN;
                LGR2.(variableStr).lower(k,1) = NaN;
            end
        catch ME
                LGR2.(variableStr).upper(k,1) = NaN;
                LGR2.(variableStr).lower(k,1) = NaN;
        end
    end
    
end

hhourMax = length(StatsX);
variableX = {'N2O','CH4','H2O_LGR','CO2','H2O_7200'};
variableChans = [8 9 7 5 6];
for i=1:length(variableX)
    variableStr = char(variableX(i));
    for k=1:hhourMax
        try
            LGR1.(variableStr)(k,1)=[StatsX(k).MainEddy.Zero_Rotations.Avg(variableChans(i)) ];
            if max(abs(LGR1.(variableStr)(k,1))) > maxValue
                LGR1.(variableStr)(k,1) = [NaN ];
            end
        catch ME
            LGR1.(variableStr)(k,1) = [NaN ];
        end
    end
    
end

%% plots
tLGR1 = tLGR1 - 8/24;
t = t - 8/24;
doy = tLGR1-datenum(2021,1,0);

fig = 0;

fig=fig+1;
figure(fig);
plot(doy,[LGR1.CH4 LGR2.CH4.lower LGR2.CH4.upper],'linewidth',lineWidth);
legend('main','lower','upper')
title('CH_4')
ylabel('ppm')
xlabel('DOY')
zoom on
grid on
set(fig,'name','CH_4');

fig=fig+1;
figure(fig);
plot(doy,[LGR1.CH4-LGR2.CH4.upper(:,1)],'linewidth',lineWidth);
%legend('main','lower','upper')
title('CH_4 (main-upper)')
ylabel('ppm')
xlabel('DOY')
zoom on
grid on
set(fig,'name','CH_4 (main-upper)');

fig=fig+1;
figure(fig);
plot(doy,[LGR1.N2O-0.0135 LGR2.N2O.lower LGR2.N2O.upper],'linewidth',lineWidth);
legend('main-0.0135','lower','upper')
title('N_2O')
ylabel('ppm')
xlabel('DOY')
zoom on
grid on
set(fig,'name','N_2O');

fig=fig+1;
figure(fig);
plot(doy,[LGR1.N2O-LGR2.N2O.upper(:,1)],'linewidth',lineWidth);
%legend('main','lower','upper')
title('N_2O (main-upper)')
ylabel('ppm')
xlabel('DOY')
zoom on
grid on
set(fig,'name','N_2O (main-upper)');

fig=fig+1;
figure(fig);
plot(doy,[LGR1.H2O_LGR LGR2.H2O_LGR.lower LGR2.H2O_LGR.upper],'linewidth',lineWidth);
legend('main','lower','upper')
title('H_2O')
ylabel('mmol')
xlabel('DOY')
zoom on
grid on
set(fig,'name','H_2O');

fig=fig+1;
figure(fig);
plot(doy,[LGR1.H2O_LGR-LGR2.H2O_LGR.upper(:,1) LGR2.H2O_LGR.upper(:,1)-LGR2.H2O_7200.upper(:,1) LGR1.H2O_7200-LGR2.H2O_7200.upper(:,1)],'linewidth',lineWidth);
legend('(main LGR)- (upper LGR)','(upper LGR) - (upper LI7200)','(main 7200)-(upper 7200)')
title('H_2O differences')
ylabel('mmol/mol')
xlabel('DOY')
zoom on
grid on
set(fig,'name','H_2O (differences)');


fig=fig+1;
figure(fig);
plot(doy,[LGR1.CO2+4 LGR2.CO2.lower LGR2.CO2.upper],'linewidth',lineWidth);
legend('main+4','lower','upper')
title('CO_2')
ylabel('ppm')
xlabel('DOY')
zoom on
grid on
set(fig,'name','CO2');

fig=fig+1;
figure(fig);
plot(doy,[LGR1.CO2+4-LGR2.CO2.upper(:,1)],'linewidth',lineWidth);
title('CO_2 differences (main-upper)')
ylabel('mmol/mol')
xlabel('DOY')
zoom on
grid on
set(fig,'name','CO_2 (differences)');
%------------------------------------------

childn = get(0,'children');
childn = sort(childn);
N = length(childn);
for i=1:N
    if i < 200
        figure(i);
        %            if i ~= childn(N-1)
        pause;
        %            end
    end
end
return

