function h_new = yeargrid(h_org)
% h_new = yeargrid(h_org)
%
% Plots dotted grid lines into a time series plot with 
% handle h_hor. x-axis must be a matlab time vector.
% The grid consists of one horizontal line at 0 and a 
% vertical lines for each beginning of new year. 

% kai* June 13, 2002

% Make h_org current
h_old = gca;
subplot(h_org);

% Extract the dimensions from the handle
tick_val    = get(h_org,'XTick');
yaxis_range = get(h_org,'YLim');

% Find beginning of year
[yy,mm] = datevec(tick_val);
ind_jan = find(mm == 1);

% If first and last tick (at the axis) would have a 
% vertical line do not include these, as a dotted line
% plotted above the axis looks strange in PowerPoint
if ind_jan(1) == 1
   ind_jan = ind_jan(2:end);
end
if ind_jan(end) == length(tick_val)
   ind_jan = ind_jan(1:end-1);
end
   
% Plot the grid lines
hold on

plot(tick_val([1 end]),[0 0],'k:');

for i = 1:length(ind_jan) 
   plot([tick_val(ind_jan(i)) tick_val(ind_jan(i))],yaxis_range,'k:'); 
end

hold off

% Return current axes to what it was before
h_new = gca;
subplot(h_old);
