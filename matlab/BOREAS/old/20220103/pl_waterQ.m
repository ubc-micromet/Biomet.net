function pl_waterQ(year,ind,ind_10min,nod_back,fig_num);

arg_default('nod_back',14);

if year~=2008
    return
else
    tv_10min = read_bor(fullfile(biomet_path(year,'cr','cl'),'WaterQ','WaterQ1_181_tv'),8);
    tv = read_bor(fullfile(biomet_path(2008,'cr','cl'),'WaterQ','WaterQ1_182_tv'),8);
    doy_10min = tv_10min-datenum(2008,1,0)-8/24;
    doy=tv-datenum(2008,1,0)-8/24;
    if isempty(ind)
        ind=find(doy>=floor(now-datenum(2008,1,0))-nod_back & doy < floor(now-datenum(2008,1,0)+1));
    end
    if isempty(ind_10min)
        ind_10min=find(doy_10min>=floor(now-datenum(2008,1,0))-nod_back & doy_10min < floor(now-datenum(2008,1,0)+1));
    end
    doy_10min=doy_10min(ind_10min);
    doy=doy(ind);
    % plot dissolved AVG, MAX, MIN
    vnam = {'DOmgl' 'DOpct' 'H_Level1' 'H_Level2' 'HL_Temp' 'O2' 'Pbar_kPa2' ...
        'pH' 'Redox' 'Sal' 'SB_temp_C' 'TH1_Temp' 'TH1_v1' 'TH1_v2'};

    for k=1:length(vnam)
      vstr = char(vnam{k});
      figure(fig_num+k);
      av = read_bor(fullfile(biomet_path(2008,'cr','cl'),'WaterQ',[vstr '_AVG']));
      mx = read_bor(fullfile(biomet_path(2008,'cr','cl'),'WaterQ',[vstr '_MAX']));
      mn = read_bor(fullfile(biomet_path(2008,'cr','cl'),'WaterQ',[vstr '_MIN']));
      plot(doy_10min,av(ind_10min),'y-',doy,mx(ind),'r-.',doy,mn(ind),'g--');
      title(['WaterQ: ' vstr ]);
      legend('AVG','MAX','MIN');
      set(gcf,'Name',['WaterQ: ' vstr ]);
      grid on; zoom on;
    end
end
