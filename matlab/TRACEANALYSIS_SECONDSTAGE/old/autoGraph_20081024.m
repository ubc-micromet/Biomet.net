function autoGraph(trace_str)
% changed the printing statement Praveena
close all
set(0,'DefaultLineLinewidth',2);
set(0,'DefaultAxesLinewidth',2);

 orient portrait;
%pth_out = 'Y:\delete_me';
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
% Find indecies for the last seven days
%------------------------------------------------------------------
[tv_dum,ind] = intersect(round(tv.*48)./48,round([floor(disp_end)-7:1/48:floor(disp_end)].*48)./48);

tick_val = tv(ind(1)):tv(ind(end));
tick_label = datestr(tick_val,6);

%------------------------------------------------------------------
% Find indecies for traces to plot
%------------------------------------------------------------------
% Here it is essential that all third stage automated ini files
% give the same name to traces.
ind_plt(1) = find(strcmp(variableNames, {'radiation_net_main'}));
ind_plt(2) = find(strcmp(variableNames, {'h_main'}));
ind_plt(3) = find(strcmp(variableNames, {'le_main'}));
ind_plt(4) = find(strcmp(variableNames, {'nep_filled_with_fits'}));

nep_cum = trace_str(ind_plt(4)).data;
ind_nan = find(isnan(nep_cum));
nep_cum(ind_nan) = 0;
nep_cum = cumsum(nep_cum.*12e-6*1800);
ind_end = max(find(~isnan(trace_str(ind_plt(4)).data)));
nep_cum(ind_end+1:end) = NaN;
%------------------------------------------------------------------
% Plotting 7 days of energy & co2 fluxes 
%------------------------------------------------------------------
subplot('Position',subplot_position(2,1,1))

plot(tv(ind),trace_str(ind_plt(1)).data(ind),'m')
line(tv(ind),trace_str(ind_plt(2)).data(ind),'Color','r')
line(tv(ind),trace_str(ind_plt(3)).data(ind),'Color','b')
subplot_label(gca,2,1,1,tick_val,-200:200:1000,1);

xoff = 1;
text(tick_val(1)-xoff,-200+600,'Energy Fluxes (W m^{-2})',...
   'Rotation',90,'HorizontalA','center')
%h = ylabel('Energy Fluxes (W m^{-2})');

% Legend
line([tick_val(2) tick_val(2)+0.5],[900 900],'Color','m')
text(tick_val(2)+0.6,900,'Net Radiation','Fontsize',8);
line([tick_val(4) tick_val(4)+0.5],[900 900],'Color','r')
text(tick_val(4)+0.6,900,'Sensible Heat','Fontsize',8);
line([tick_val(6) tick_val(6)+0.5],[900 900],'Color','b')
text(tick_val(6)+0.6,900,'Latent Heat','Fontsize',8);


subplot('Position',subplot_position(2,1,2))

plot(tv(ind),trace_str(ind_plt(4)).data(ind),'g')
subplot_label(gca,2,1,2,tick_val,-20:10:30,1);
set(gca,'XTickLabel','');

text(tick_val(1)-xoff,-20+25,'NEP (\mumol m^{-2}s^{-1})',...
   'Rotation',90,'HorizontalA','center')
text(mean(tick_val),-40,'DOY','HorizontalA','center')

position_labels(gca,tick_val,tick_label);

print( '-djpeg',[fullfile(pth_out,lower(['graph_timeseries_' SiteId]))])

% exportfig(gcf,fullfile(pth_out,lower(['graph_timeseries_' SiteId])),...
%    'Format','jpeg100',...
%    'LineMode','fixed','LineWidth',1.5,...
%     'color', 'cmyk','height',5);

%------------------------------------------------------------------
% Plotting the cumulative NEP
%------------------------------------------------------------------
[tick_val,tick_label] = monthtick(tv(48:end-48),1);

figure;
plot(tv,nep_cum,'g')
line([tv(1) tv(end)],[0 0],'Color','k','LineStyle',':')
ylabel('cumulative NEP (g C m^{-2})')

% Printing the sum
if tv(ind_end)<datenum(trace_str(1).Year,5,1)
   tv_plot = datenum(trace_str(1).Year,5,1);
else 
   tv_plot = tv(ind_end);
end
if max(nep_cum)<0
   nep_plot = 30;
else
   nep_plot = max(nep_cum)+30;
end
text(tv_plot,nep_plot,['NEP up to ' datestr(trace_str(ind_plt(4)).timeVector(ind_end),6) ': ' num2str(nep_cum(ind_end),'%3.0f') 'g C'],...
   'HorizontalA','right');

axis([tick_val(1) tick_val(end) -100 500]);
set(gca,'XTick',tick_val,'XTickLabel','','YTick',-100:100:500);
position_labels(gca,tick_val,tick_label);
text(mean(tick_val),-150,datestr(tv(1000),10),'HorizontalA','center')

print( '-djpeg',[fullfile(pth_out,lower(['graph_sum_' SiteId]))])
% exportfig(gcf,fullfile(pth_out,lower(['graph_sum_' SiteId])),...
%    'Format','jpeg100',...
%    'LineMode','fixed','LineWidth',1.5,...
%     'color', 'cmyk','height',5);
%  
return