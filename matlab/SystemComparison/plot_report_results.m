function h = plot_report_results

h.hand = figure;
h.name = 'report_results';

sites = {'BC-HDF88','AB-WPL','SK-OBS','ON-EPL','QC-OBS'};
slopes_hs = [1.05 0.99 1.12 0.99 1.01];
slopes_le = [1.05 0.96 0.98 0.96 1.02];
slopes_fc = [0.96 0.96 1.07 0.96 0.99];
slopes_us = [1.01 1.03 1.01 1.01 1.03];

marker = 'sov^>d';
color = [[1 0 0];[0 0.8 0];[1 0 1];[0 0 1];[1 0.6 0];[0 0.8 1]];

ha = axes('Box','on','XLim',[0.5 4.5],'YLim',[0.9 1.15],...
    'XTick',[1:4],'XTickLabel','','FontSize',22);
for i = 1:length(sites);
    line(1+0.06*(i-length(sites)/2),slopes_hs(i),'Marker',marker(i),'Color',color(i,:),'MarkerFaceColor',color(i,:),'MarkerSize',10);
    text(1,0.895,'{\itH}_s','HorizontalA','center','VerticalA','top','FontSize',22);
    line(2+0.06*(i-length(sites)/2),slopes_le(i),'Marker',marker(i),'Color',color(i,:),'MarkerFaceColor',color(i,:),'MarkerSize',10);
    text(2,0.895,'\lambda{\itE}','HorizontalA','center','VerticalA','top','FontSize',22);
    line(3+0.06*(i-length(sites)/2),slopes_fc(i),'Marker',marker(i),'Color',color(i,:),'MarkerFaceColor',color(i,:),'MarkerSize',10);
    text(3,0.895,'{\itF}_C','HorizontalA','center','VerticalA','top','FontSize',22);
    line(4+0.06*(i-length(sites)/2),slopes_us(i),'Marker',marker(i),'Color',color(i,:),'MarkerFaceColor',color(i,:),'MarkerSize',10);
    text(4,0.895,'{\itu}_*','HorizontalA','center','VerticalA','top','FontSize',22);
end
line([0 5],[0.95 0.95],'Color','k','Marker','none','LineStyle',':');
line([0 5],[1.05 1.05],'Color','k','Marker','none','LineStyle',':');