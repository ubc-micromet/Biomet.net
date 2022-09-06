function xsite_plot_sample_tube_tc(Stats_xsite)

[a,b,c,pth_csi_net] = fr_get_local_path;

h = dir(fullfile(pth_csi_net,'*xsite_23X.met'));

% [t_dum,ind] = max(datenum({h(:).date}))

T_all = [];
Pgauge_all = [];
tv_all = [];

for i = 1:length(h)
    
    format_string ='01%f  02%f  03%f  04%f  05%f  06%f  07%f  08%f'; 
    fileName = fullfile(pth_csi_net,h(i).name);
    [TableID,YY,DOY,HHMM,T1,T2,T3,Pgauge] = textread(fileName,...
        format_string,'headerlines',5);

    [TableID,YY,DOY,HHMM,T1,T2,T3,Pgauge] = textread('d:\kai\Projects\XSITE\Capture_23x_tst.TXT',...
        format_string,'headerlines',5);
        
    tv = datenum(YY,1,DOY,floor(HHMM./100),mod(HHMM,100),0);
    
    tv_all     = [tv_all; tv];
    T_all      = [T_all; T1 T2 T3];
    Pgauge_all = [Pgauge_all; Pgauge];
    
end

[tv,ind] = unique(tv);
T_all = T_all(ind,:);
Pgauge = Pgauge_all(ind,:);

tv_xsite = get_stats_field(Stats_xsite,'TimeVector');
Tair     = get_stats_field(Stats_xsite,'MiscVariables.Tair');
Tb     = get_stats_field(Stats_xsite,'Instrument(3).Avg(4)');

[tv,ind_tv,ind_xsite] = intersect(fr_round_hhour(tv),fr_round_hhour(tv_xsite));
T_all  = T_all(ind_tv,:);
Pgauge_all = Pgauge_all(ind_tv,:);
Tair   = Tair(ind_xsite);
Tb   = Tb(ind_xsite);

doy = tv - datenum(YY(1),1,0);

figure('Name','XSITE 23X');
subplot('Position',subplot_position(2,1,1))
plot(doy,[Tair Tb T_all])
legend('Tair','Tbox','Tout','Tmid','Tin');
subplot_label(gca,2,1,1,[floor(doy(1)) ceil(doy(end))],[10:10:30],1)


subplot('Position',subplot_position(2,1,2))
plot(doy,[Pgauge_all])
subplot_label(gca,2,1,1,[floor(doy(1)) ceil(doy(end))],[900:50:1100],1)


