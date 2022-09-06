function hatch_example(climate_trace_name)

close all;

% Read data
yy = datevec(now);

years = [1997:yy(1)];
pth_in = biomet_path('yyyy','cr','HIGH_LEVEL');
clean_tv   = read_bor([pth_in 'clean_tv'],8,[],years,[],1);
trc        = read_bor([pth_in climate_trace_name],[],[],years,[],1);
tv_doy = convert_tv(clean_tv,'nod');

[tv,trc_avg] = monthlystat(clean_tv, trc);
trc_yearly = reshape(trc_avg,12,length(trc_avg)/12);

trc_yearly(1:7,1) = NaN;
trc_yearly(yy(2):end,end) = NaN;

figure

[hp,hl] = hatch_bar(trc_yearly);

% Expand yaxis so there is space for the legend
ylim = get(gca,'YLim');
ylim(2) = ylim(2)*1.25;
set(gca,'YLim',ylim);
ylabel('Monthly Averages')

% Make the x axis a month axis
ticks = [0.5 get(gca,'XTick')+0.5];
set(gca,'XTick',ticks,'XTickLabel', '| |', 'XLim',[0.5 12.5]);
month = ['J' 'F' 'M' 'A' 'M' 'J' 'J' 'A' 'S' 'O' 'N' 'D'];
for i = 1:12; text(i,ylim(1)-diff(ylim)*0.01,month(i),'HorizontalAlignment','center','VerticalAlignment','top'); end
xlabel('Month');


% Make the legend
dh = 0.25*diff(ylim)/length(years); h_org = ylim(2);
for i = 1:length(years)
   % get(hl(i),'EdgeColor') gets the color of the hatch pattern
   h = patch([10 11 11 10],[h_org-(i+1)*dh h_org-(i+1)*dh h_org-i*dh h_org-i*dh],get(hl(i),'EdgeColor'));
   hatch_pattern(h,i);
   text(11.3,h_org-dh/2-i*dh,num2str(years(i)),'FontSize',10);
end

