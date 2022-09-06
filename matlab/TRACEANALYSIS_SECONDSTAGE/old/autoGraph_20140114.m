function autoGraph(trace_str)

% Revision history:
% Oct 25, 2012 (Hughie)
%   -Climate Variables (Temperature, RH) added to HP09 AND HP11
% Oct 22, 2012
%   -number of days plotted increased to 14 for HP sites

% changed the printing statement Praveena
close all
colordef('white');
%set(0,'DefaultLineLinewidth',2);
%set(0,'DefaultAxesLinewidth',2);


 %orient portrait;
%pth_out = 'Y:\delete_me';
%pth_out = 'D:\Nick_Share\tmp_nick\';
pth_out = '\\paoa001\web_page_wea\';


SiteId = trace_str(1).SiteID;
gmt_shift = FR_get_offsetGMT(upper(SiteId))/24;
tv        = trace_str(1).timeVector - gmt_shift;
doy       = trace_str(1).DOY - gmt_shift;

variableNames = {trace_str(:).variableName};

dv_now = datevec(now);
if dv_now(1) == trace_str(1).Year
   disp_end = now;
else
   disp_end = tv(end);
end

%------------------------------------------------------------------
% Find indexes for the last numdays days
%------------------------------------------------------------------
numdays = 14;
[tv_dum,ind] = intersect(round(tv.*48)./48,round([floor(disp_end)-numdays:1/48:floor(disp_end)].*48)./48);

tick_val = tv(ind(1)):tv(ind(end));
tick_label = datestr(tick_val,6);
tick_label = cellstr(tick_label);
n=2;
while n<=length(tick_label)
    tick_label{n}=' ';
    n=n+2;
end

%------------------------------------------------------------------
% Find indecies for traces to plot
%------------------------------------------------------------------
% Here it is essential that all third stage automated ini files
% give the same name to traces.

if ~ismember(SiteId,{'HP09' 'HP11' 'MPB1' 'MPB2' 'MPB3'})
    ind_plt(1) = find(strcmp(variableNames, {'radiation_net_main'}));
    ind_plt(2) = find(strcmp(variableNames, {'h_main'}));
    ind_plt(3) = find(strcmp(variableNames, {'le_main'}));
    ind_plt(4) = find(strcmp(variableNames, {'nep_filled_with_fits'}));
    ind_plt(5) = find(strcmp(variableNames, {'air_temperature_main'}));
    nep_cum = trace_str(ind_plt(4)).data;
    ind_nan = find(isnan(nep_cum));
    nep_cum(ind_nan) = 0;
    nep_cum = cumsum(nep_cum.*12e-6*1800);
    ind_end = max(find(~isnan(trace_str(ind_plt(4)).data)));
    nep_cum(ind_end+1:end) = NaN;
elseif ismember(SiteId,{'HP09' 'HP11'})
    ind_plt(1) = find(strcmp(lower(variableNames), {'net_radiation'}));
    ind_plt(2) = find(strcmp(variableNames, {'h_sonic_blockavg_rotated_5m_logger'}));
    ind_plt(3) = find(strcmp(variableNames, {'le_blockavg_rotated_5m_op_logger'}));
    ind_plt(4) = find(strcmp(variableNames, {'fc_blockavg_rotated_5m_op_logger'}));
    ind_plt(5) = find(strcmp(variableNames, {'temperature_avg_csat_logger'}));
elseif ismember(SiteId,{'MPB1' 'MPB2' 'MPB3'})
    ind_plt(1) = find(strcmp(lower(variableNames), {'net_radiation'}));
    ind_plt(2) = find(strcmp(variableNames, {'h_sonic_blockavg_rotated_26m_logger'}));
    ind_plt(3) = find(strcmp(variableNames, {'le_blockavg_rotated_26m_op_logger'}));
    ind_plt(4) = find(strcmp(variableNames, {'fc_blockavg_rotated_26m_op_logger'}));
end

%------------------------------------------------------------------
% Plotting numdays days of Temperature (CSAT)
%------------------------------------------------------------------

%if ismember(SiteId,{'HP09' 'HP11'})
figure('unit','inches','paperposition',[0 0 4 2]);

plot(tv(ind),trace_str(ind_plt(5)).data(ind),'r','linewidth',2)
set (gca,'XLim',[tv(ind(1)) tv(ind(end))]);
set (gca,'XTick',tick_val);
set (gca,'YLim',[-30 40],'FontSize',8);
set (gca,'YTick',-30:10:40,'FontSize',8);
set (gca,'XTickLabel','');
ylabel ('Temperature (C^O)','FontSize',10);

pos_vec = get(gca,'Position');
lim_vec = get(gca,'XLim');
h = axes('Position',pos_vec,'XLim',lim_vec,'Visible','off');
label_pos = tick_val(1:end-1) + diff(tick_val)/2;

for i = 1:length(label_pos) %#ok<NOPRT>
   text(label_pos(i),0,tick_label(i),'HorizontalA','center','VerticalA','top','FontSize',8); 
end

print( '-djpeg',[fullfile(pth_out,lower(['graph_Temperature_timeseries_' SiteId]))])
%end
%------------------------------------------------------------------
% Plotting numdays days of energy & co2 fluxes 
%------------------------------------------------------------------
figure('unit','inches','PaperPosition',[0 0 4 2]);
%subplot('Position',subplot_position(2,1,1))

plot(tv(ind),trace_str(ind_plt(1)).data(ind),'k','linewidth',2)
line(tv(ind),trace_str(ind_plt(2)).data(ind),'Color','r','linewidth',2)
line(tv(ind),trace_str(ind_plt(3)).data(ind),'Color','b','linewidth',2)
set(gca,'XLim',[tv(ind(1)) tv(ind(end))]);
set(gca,'XTick',tick_val);
set(gca,'YLim',[-200 1000],'FontSize',8);
set(gca,'YTick',-200:200:1000,'FontSize',8);
set(gca,'XTickLabel','');
ylabel('Energy Fluxes (W m^{-2})','FontSize',10);

% Legend
line([tick_val(2) tick_val(2)+0.5],[900 900],'Color','k','linewidth',2)
text(tick_val(2)+0.6,900,'Net Radiation','Fontsize',6);
line([tick_val(6) tick_val(6)+0.5],[900 900],'Color','r','linewidth',2)
text(tick_val(6)+0.6,900,'Sensible Heat','Fontsize',6);
line([tick_val(10) tick_val(10)+0.5],[900 900],'Color','b','linewidth',2)
text(tick_val(10)+0.6,900,'Latent Heat','Fontsize',6);

pos_vec = get(gca,'Position');
lim_vec = get(gca,'XLim');
h = axes('Position',pos_vec,'XLim',lim_vec,'Visible','off');
label_pos = tick_val(1:end-1) + diff(tick_val)/2;

for i = 1:length(label_pos)
   text(label_pos(i),0,tick_label(i),'HorizontalA','center','VerticalA','top','FontSize',8); 
end



print( '-djpeg',[fullfile(pth_out,lower(['graph_EnergyFlx_timeseries_' SiteId]))])
%subplot('Position',subplot_position(2,1,2))

%Fc or NEP timeseries
figure('unit','inches','PaperPosition',[0 0 4 2]);
if ~ismember(SiteId,{'HP09' 'HP11' 'MPB1' 'MPB2' 'MPB3'})
    plot(tv(ind),trace_str(ind_plt(4)).data(ind),'Color',[0 0.502 0],'linewidth',2)
    set(gca,'XLim',[tv(ind(1)) tv(ind(end))]);
    Yhi = max(trace_str(ind_plt(4)).data(ind));
    Ylo = min(trace_str(ind_plt(4)).data(ind));
    set(gca,'YLim',[Ylo-0.05*Ylo Yhi+0.05*Yhi]);
    set(gca,'XTick',tick_val);
    %set(gca,'YTick',-20:10:30,'FontSize',8);
    set(gca,'XTickLabel','');
    ytcklab=get(gca,'YTickLabel');
    set(gca,'YTickLabel',ytcklab,'FontSize',8);
    ylabel('NEP (\mumol m^{-2}s^{-1})','FontSize',10);
    %text(mean(tick_val),-40,'DOY','HorizontalA','center')
else
    plot(tv(ind),trace_str(ind_plt(4)).data(ind),'Color',[0 0.502 0],'linewidth',2)
     set(gca,'XLim',[tv(ind(1)) tv(ind(end))]);
     set(gca,'XTick',tick_val);
     set(gca,'YLim',[-30 30]);
     set(gca,'YTick',-30:10:30);
     set(gca,'XTickLabel','','FontSize',10);
     ylabel('\itF\rm_{C} (\mumol m^{-2}s^{-1})','FontSize',10);
     %text(mean(tick_val),-40,'DOY','HorizontalA','center','FontSize',10)
end
pos_vec = get(gca,'Position');
lim_vec = get(gca,'XLim');
h = axes('Position',pos_vec,'XLim',lim_vec,'Visible','off');
label_pos = tick_val(1:end-1) + diff(tick_val)/2;
tick_label = cellstr(tick_label);
for i = 1:length(label_pos)
   text(label_pos(i),0,tick_label(i),'HorizontalA','center','VerticalA','top','FontSize',8); 
end
print( '-djpeg',[fullfile(pth_out,lower(['graph_Fc_timeseries_' SiteId]))])

% exportfig(gcf,fullfile(pth_out,lower(['graph_timeseries_' SiteId])),...
%    'Format','jpeg100',...
%    'LineMode','fixed','LineWidth',1.5,...
%     'color', 'cmyk','height',5,'width',4);

%------------------------------------------------------------------
% Plotting the cumulative NEP
%------------------------------------------------------------------

% Nick commented out below section and replaced with a function that
% creates nicer plots

dv_now = datevec(now);
year_now = unique(dv_now(:,1));
colordef('white');
switch upper(SiteId)
    case 'BS'
        years = 2000:1:year_now;
    case 'PA'
        years = 2000:1:year_now;
    case 'CR'
        years = 2000:1:year_now;
    case 'HDF11'
        years = 2011:1:year_now;
    case 'YF'
        years = 2002:1:year_now;
    case 'OY'
        years = 2001:1:year_now;
    case 'HP09'
        years = 2010:1:year_now;
    case 'HP11'
        years = 2011:1:year_now;
    otherwise
        years = year_now;
end

%set_powerpt_slide_defaults;
[NEP_FIG,GEP_FIG,R_FIG,NEP_MONTHLY,GEP_MONTHLY,R_MONTHLY,DOY,legstr]= calc_nep_gep_r_for_web_display(SiteId,years,[]);

if ismember(SiteId,{'HP09' 'HP11'})
% plot cumulative NEP
  % if strcmp(upper(SiteId),'HP11')
      pl_single_panel(DOY,NEP_FIG,NEP_MONTHLY,'TSER',legstr,1,'g C m^{-2}',[-100 300],[],[],2,4,'NEP_{csum}',[.75 .9],10,8,10);
   %else 
   %    pl_single_panel(DOY,NEP_FIG,NEP_MONTHLY,'TSER',legstr,1,'g C m^{-2}',[-100 300],[],[],2,4,'NEP_{csum}',[.75 .9],10,8,10);
   %end
else 
    pl_single_panel(DOY,NEP_FIG,NEP_MONTHLY,'TSER',legstr,1,'g C m^{-2}',[],[],[],2,4,'NEP_{csum}',[.75 .9],10,8,10);
end
print( '-djpeg',[fullfile(pth_out,lower(['graph_NEP_sum_' SiteId]))]);

% plot monthly NEP
pl_single_panel(DOY,NEP_FIG,NEP_MONTHLY,'MTH',legstr,1,'g C m^{-2}',[],[],[],2,4,'NEP_{mon}',[.75 .1],10,8,10);
print( '-djpeg',[fullfile(pth_out,lower(['graph_NEP_mon_' SiteId]))]);
% plot monthly GEP
[ylim_gep,ytck_gep,ytcklab_gep] = pl_single_panel(DOY,GEP_FIG,GEP_MONTHLY,'MTH',legstr,1,'g C m^{-2}',[],[],[],2,4,'GEP_{mon}',[.75 .9],10,8,10);
print( '-djpeg',[fullfile(pth_out,lower(['graph_GEP_mon_' SiteId]))]);
% plot monthly R
[ylim_resp,ytck_resp,ytcklab_resp]=pl_single_panel(DOY,R_FIG,R_MONTHLY,'MTH',legstr,1,'g C m^{-2}',ylim_gep,ytck_gep,ytcklab_gep,2,4,'\itR\rm_{mon}',[.75 .9],10,8,10);
print( '-djpeg',[fullfile(pth_out,lower(['graph_R_mon_' SiteId]))]);
if ylim_resp(2)~=ylim_gep(2)
    pl_single_panel(DOY,GEP_FIG,GEP_MONTHLY,'MTH',legstr,1,'g C m^{-2}',ylim_resp,ytck_resp,ytcklab_resp,2,4,'GEP_{mon}',[.75 .9],10,8,10);
    print( '-djpeg',[fullfile(pth_out,lower(['graph_GEP_mon_' SiteId]))]);
end
close all;

function [ylim_out,ytck_out,ytcklab_out] = pl_single_panel(DOY,DATA_FIG,DATA_MONTHLY,figtyp,legstr,xlabflg,ylabstr,ylimover,ytckover,ytcklabover,ht,wd,figlabstr,figlabposn,fsz_axlab,fsz_tcklab,fsz_figlab);

arg_default('ylimover',[]);
arg_default('ytckover',[]);
arg_default('ytcklabover',[]);
c_all = [[ 0 0 0 ]
    [ 0.000 0.000 0.750 ];
    [ 0.5 0.5 0 ];
    [ 0.502 0.000 1.000 ];  
    [1 0 1]; 
    [0 1 0];
    [0 1 1]; 
    [ 1.000 0.502 0.000 ];
    [1 0 0]; 
    [ 0.502 0.251 0.000 ];
    [ 0.000 0.502 0.251 ]; 
    [ 0.502 0.000 0.502 ];
    [ 0.502 0.502 0.502 ]; 
    [ 0.000 0.000 0.502 ];    
      [ 0.251 0.251 0.0 ]                      ];

c_bw = [[0 0 0];
        [0 0 0]
        [0.3 0.3 0.3];
        [0.3 0.3 0.3];
        [0.3 0.3 0.3];
        [0.3 0.3 0.3];
        [.649 .649 .649]
        [.649 .649 .649]
        [.649 .649 .649];
        [.649 .649 .649]  
        [.649 .649 .649]];
     
lwi  = [ 3 2 2 2 2 2 2 2 2 2 2];
lsty = {':','--','-.','-',':','--','-.','-','-.','-'};
lsty = flipud(lsty');

numYears = size(DATA_MONTHLY,2);
[tick_val,tick_label] = monthtick(DOY,1);
c_all = c_all(1:numYears,:); % trim to proper length
colordef('white');
figure('unit','inches','PaperPosition',[0 0 wd ht]);

switch upper(figtyp)
    case 'MTH'
        difftick = diff(tick_val)./2;
        hb = bar(tick_val(1:12)+difftick,DATA_MONTHLY,'grouped');
        hh = get(gca,'Children');
        for k=1:length(hh),set(hh(k),'FaceColor',c_all(k,:),'EdgeColor',c_all(k,:)); end
        set(gca,'XTick',tick_val,'XTickLabel','');
        set(gca,'Xlim',[min(floor(DOY)) max(ceil(DOY))]);
        ylabel(ylabstr,'FontSize',fsz_axlab);
        ytck_out = get(gca,'YTick');
        ytcklab_out = get(gca,'YTickLabel');
        set(gca,'YTick',ytck_out,'YTickLabel',ytcklab_out,'FontSize',fsz_tcklab);
        text(figlabposn(1),figlabposn(2),figlabstr,'Units','Normalized','FontSize',fsz_figlab);
        set(gca,'Xlim',[min(floor(DOY))+1 max(ceil(DOY))]);
        ylim_out = get(gca,'YLim');
        if ~isempty(ylimover)
            if ylimover(2)>ylim_out(2)
              set(gca,'YLim',ylimover);
              set(gca,'YTick',ytckover);
              set(gca,'YTickLabel',ytcklabover);
              ylim_out = ylimover;
              ytck_out = ytckover;
              ytcklab_out = ytcklabover;
            end
        end
        set(gca,'YLim',ylim_out);

    case {'TSER'}
        difftick = diff(tick_val)./2;
        hb=plot(DOY,DATA_FIG(:,1:end-1),'LineWidth',2); hold on; plot(DOY,DATA_FIG(:,end),'LineWidth',3);
        ylabel(ylabstr,'FontSize',fsz_axlab);
        hh = get(gca,'Children');
        for k=1:length(hh),set(hh(k),'Color',c_all(k,:)); end
        set(gca,'Xlim',[min(floor(DOY))+1 max(ceil(DOY))]);
        set(gca,'XTick',tick_val,'XTickLabel','');
        text(figlabposn(1),figlabposn(2),figlabstr,'Units','Normalized','FontSize',fsz_figlab);
        ylim_out = get(gca,'YLim');
        if ~isempty(ylimover)
            set(gca,'YLim',ylimover);
            ylim_out = ylimover;
        end
        set(gca,'YLim',ylim_out);
        ytck = get(gca,'Ytick');
        ytcklab=get(gca,'Yticklabel');
        set(gca,'Ytick',ytck);
        set(gca,'Yticklabel',ytcklab,'FontSize',fsz_tcklab);
        if ~isempty(legstr)
           HLEG = legend(legstr,'location','NorthWest');
           %set(HLEG,'FontSize',fsz_tcklab);
           set(HLEG,'FontSize',6);
           legend(gca,'boxoff');
        end
end

if xlabflg
    month = ['J' 'F' 'M' 'A' 'M' 'J' 'J' 'A' 'S' 'O' 'N' 'D'];
    %set(gca,'YLim',ylim_out);
    yaxmin = min(get(gca,'YLim'));
    for j = 1:12; text(tick_val(j)+difftick(j),yaxmin-0.001, month(j),'HorizontalAlignment','center',...
            'VerticalAlignment','top','FontSize',fsz_axlab);  
    end
end