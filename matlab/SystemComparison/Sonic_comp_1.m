function h = sonic_comp

kais_plotting_setup

close all;

tv =[];
tv = [tv datenum(2004,6,24)+[74/96:1/48:98/96]];
tv = tv([1:13 17:end]);
tv = [tv datenum(2004,6,25)+[64/96:1/48:96/96]];
tv = [tv datenum(2004,6,26)+[2/96:1/48:10/96]];
tv = [tv datenum(2004,6,26)+[70/96:1/48:96/96]];
tv = [tv datenum(2004,6,27)+[2/96:1/48:16/96]];

pth = 'D:\met-data\data';

for i = 1:length(tv)
%for i = length(tv)
     disp(['Processing ' datestr(tv(i))]);

    filename = fr_datetofilename(tv(i));

    % XSITE Sonic
    sonic_XSITE = FR_read_raw_data(fullfile(pth,[filename '.dx5']),5)';
    sonic_XSITE = sonic_XSITE./100;
    sonic_XSITE(:,4) = sonic_XSITE(:,4)-273.15;
    
    [meansSr,statsSr,angles] = FR_rotate(mean(sonic_XSITE(:,1:4)),cov(sonic_XSITE(:,1:4)),'N');
    dir   = FR_Sonic_wind_direction(sonic_XSITE','GillR3');
    sonic_XSITE_dir(i,:) = histc(dir,0:10:360);
    [sonic_XSITE] = fr_rotatn_hf(sonic_XSITE,angles);      
    sonic_XSITE_mean(i,:) = mean(sonic_XSITE(:,1:4));
    sonic_XSITE_cov(i,:,:)  = cov(sonic_XSITE(:,1:4));
    sonic_XSITE_len(i)  = length(sonic_XSITE);

    if sonic_XSITE_cov(i,4,4) > 2
        sonic_XSITE_dir(i,:) = NaN.*zeros(1,37);
        sonic_XSITE_mean(i,:) = NaN.*zeros(1,4);
        sonic_XSITE_cov(i,:,:)  = NaN.*zeros(1,4,4);
        sonic_XSITE_len(i)  = 0;
    end
    
    % Gill SN 244 Sonic
    sonic_244 = FR_read_raw_data(fullfile(pth,[filename '.dx15']),5)';
    sonic_244 = sonic_244./100;
    sonic_244(:,4) = sonic_244(:,4)-273.15;
    
    [meansSr,statsSr,angles] = FR_rotate(mean(sonic_244(:,1:4)),cov(sonic_244(:,1:4)),'N');
    dir   = FR_Sonic_wind_direction(sonic_244','GillR3');
    sonic_244_dir(i,:) = histc(dir,0:10:360);
    [sonic_244] = fr_rotatn_hf(sonic_244,angles);      
    sonic_244_mean(i,:) = mean(sonic_244(:,1:4));
    sonic_244_cov(i,:,:)  = cov(sonic_244(:,1:4));
    sonic_244_len(i)  = length(sonic_244);

    if sonic_244_cov(i,4,4) > 2
        sonic_244_dir(i,:) = NaN.*zeros(1,37);
        sonic_244_mean(i,:) = NaN.*zeros(1,4);
        sonic_244_cov(i,:,:)  = NaN.*zeros(1,4,4);
        sonic_244_len(i)  = 0;
    end

    % Gill S/N 295 Sonic
    sonic_295 = FR_read_raw_data(fullfile(pth,[filename '.dx16']),5)';
    if length(sonic_295>1e3)
        sonic_295 = sonic_295./100;
        sonic_295(:,4) = sonic_295(:,4)-273.15;
        
        [meansSr,statsSr,angles] = FR_rotate(mean(sonic_295(:,1:4)),cov(sonic_295(:,1:4)),'N');
        dir   = FR_Sonic_wind_direction(sonic_295','GillR3');
        sonic_295_dir(i,:) = histc(dir,0:10:360);
        [sonic_295] = fr_rotatn_hf(sonic_295,angles);      
        sonic_295_mean(i,:) = mean(sonic_295(:,1:4));
        sonic_295_cov(i,:,:)  = cov(sonic_295(:,1:4));
        sonic_295_len(i)  = length(sonic_295);
    else
        sonic_295_dir(i,:) = NaN.*zeros(1,37);
        sonic_295_mean(i,:) = NaN.*zeros(1,4);
        sonic_295_cov(i,:,:)  = NaN.*zeros(1,4,4);
        sonic_295_len(i)  = 0;
    end
    
    % XSITE Sonic
    sonic_csat = fr_read_digital2_file(fullfile(pth,[filename '.dh7']));
    
    [meansSr,statsSr,angles] = FR_rotate(mean(sonic_csat(:,1:4)),cov(sonic_csat(:,1:4)),'N');
    dir   = FR_Sonic_wind_direction(sonic_csat','CSAT3');
    sonic_csat_dir(i,:) = histc(dir,0:10:360);
    [sonic_csat] = fr_rotatn_hf(sonic_csat,angles);      
    sonic_csat_mean(i,:) = mean(sonic_csat(:,1:4));
    sonic_csat_cov(i,:,:)  = cov(sonic_csat(:,1:4));
    sonic_csat_len(i)  = length(sonic_csat);

    if sonic_csat_cov(i,4,4) > 2
        sonic_csat_dir(i,:) = NaN.*zeros(1,37);
        sonic_csat_mean(i,:) = NaN.*zeros(1,4);
        sonic_csat_cov(i,:,:)  = NaN.*zeros(1,4,4);
        sonic_csat_len(i)  = 0;
    end

    % Tcs Sonic
    try
        [n,tc0] = textread(fullfile(pth,['TC' filename '.bin']),'%d,%f','headerlines',1);
        if length(tc0)>3e4 & var(tc0)<1
            tc0_var(i)  = var(tc0);
        else
            tc0_var(i)  = NaN;
        end
    end

    try
        [n,tc1] = textread(fullfile(pth,['TC1' filename '.bin']),'%d,%f','headerlines',1);
        if length(tc1)>3e4 & var(tc1)<1
            tc1_var(i)  = var(tc1);
        else
            tc1_var(i)  = NaN;
        end
    end
    
end


figure
plot([sonic_XSITE_len;sonic_244_len;sonic_295_len;sonic_csat_len]')

figure
surf(sonic_244_dir)
view(2)

h(1).name = 'var_Tc';
h(1).hand = figure;
set(h(1).hand,'Name',h(1).name);
set(h(1).hand,'NumberTitle','off');

subplot(2,2,1)
plot_regression(tc0_var,tc1_var,[],[],'ortho')
xlabel('Tc0')
ylabel('Tc1')

subplot(2,2,2)
plot_regression(tc0_var,sonic_XSITE_cov(:,4,4)',[],[],'ortho')
xlabel('Tc0')
ylabel('XSITE')

subplot(2,2,3)
plot_regression(tc0_var,sonic_244_cov(:,4,4)',[],[],'ortho')
xlabel('Tc0')
ylabel('244')

subplot(2,2,4)
plot_regression(tc0_var,sonic_csat_cov(:,4,4)',[],[],'ortho')
xlabel('Tc0')
ylabel('CSAT')


h(2).name = 'wp_Tsp';
h(2).hand = figure;
set(h(2).hand,'Name',h(2).name);
set(h(2).hand,'NumberTitle','off');

j = [3 4];
subplot(2,2,1)
plot_regression(sonic_XSITE_cov(:,j(1),j(2)),sonic_244_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('XSITE');
ylabel('244')

subplot(2,2,2)
plot_regression(sonic_XSITE_cov(:,j(1),j(2)),sonic_295_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('XSITE');
ylabel('295')

subplot(2,2,3)
plot_regression(sonic_XSITE_cov(:,j(1),j(2)),sonic_csat_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('XSITE');
ylabel('CSAT')

subplot(2,2,4)
plot_regression(sonic_csat_cov(:,j(1),j(2)),sonic_244_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('CSAT');
ylabel('244')

h(3).name = 'var_w';
h(3).hand = figure;
set(h(3).hand,'Name',h(3).name);
set(h(3).hand,'NumberTitle','off');

j = [3 3];
subplot(2,2,1)
plot_regression(sonic_XSITE_cov(:,j(1),j(2)),sonic_244_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('XSITE');
ylabel('244')

subplot(2,2,2)
plot_regression(sonic_XSITE_cov(:,j(1),j(2)),sonic_295_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('XSITE');
ylabel('295')

subplot(2,2,3)
plot_regression(sonic_XSITE_cov(:,j(1),j(2)),sonic_csat_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('XSITE');
ylabel('CSAT')

subplot(2,2,4)
plot_regression(sonic_csat_cov(:,j(1),j(2)),sonic_244_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('CSAT');
ylabel('244')

h(4).name = 'var_Ts';
h(4).hand = figure;
set(h(4).hand,'Name',h(4).name);
set(h(4).hand,'NumberTitle','off');

j = [4 4];
subplot(2,2,1)
plot_regression(sonic_XSITE_cov(:,j(1),j(2)),sonic_244_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('XSITE');
ylabel('244')

subplot(2,2,2)
plot_regression(sonic_XSITE_cov(:,j(1),j(2)),sonic_295_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('XSITE');
ylabel('295')

subplot(2,2,3)
plot_regression(sonic_XSITE_cov(:,j(1),j(2)),sonic_csat_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('XSITE');
ylabel('CSAT')

subplot(2,2,4)
plot_regression(sonic_csat_cov(:,j(1),j(2)),sonic_244_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('CSAT');
ylabel('244')

h(5).name = 'up_wp';
h(5).hand = figure;
set(h(5).hand,'Name',h(5).name);
set(h(5).hand,'NumberTitle','off');

j = [1 3];
set(gcf,'Name','u''w''');
subplot(2,2,1)
plot_regression(sonic_XSITE_cov(:,j(1),j(2)),sonic_244_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('XSITE');
ylabel('244')

subplot(2,2,2)
plot_regression(sonic_XSITE_cov(:,j(1),j(2)),sonic_295_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('XSITE');
ylabel('295')

subplot(2,2,3)
plot_regression(sonic_XSITE_cov(:,j(1),j(2)),sonic_csat_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('XSITE');
ylabel('CSAT')

subplot(2,2,4)
plot_regression(sonic_csat_cov(:,j(1),j(2)),sonic_244_cov(:,j(1),j(2)),[],[],'ortho')
xlabel('CSAT');
ylabel('244')

return

N=min(length(sonic_295),length(sonic_XSITE))
plot(sonic_295(1:N,5)-sonic_XSITE(1:N,5))
 
plot(sonic_XSITE(:,5)); hold on
hold on; plot(sonic_295(:,5),'r')

plot(linspace(0,1800,length(sonic_XSITE)),sonic_XSITE(:,2),...
     linspace(0,1800,length(sonic_csat)),sonic_csat(:,2))
 
plot(linspace(0,1800,length(sonic_XSITE)),sonic_XSITE(:,4),...
     linspace(0,1800,length(sonic_244)),sonic_244(:,4))

plot(linspace(0,1800,length(sonic_XSITE)),sonic_XSITE(:,4),...
     linspace(0,1800,length(sonic_295)),sonic_295(:,4))

plot(linspace(0,1800,length(sonic_XSITE)),sonic_XSITE(:,5),...
     linspace(0,1800,length(sonic_295)),sonic_295(:,5))

plot(linspace(0,1800,length(tc0)),tc0,...
     linspace(0,1800,length(tc1)),tc1)

 return
