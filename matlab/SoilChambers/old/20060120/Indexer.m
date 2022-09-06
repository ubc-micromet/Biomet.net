function [start, finish] = Indexer(Time_vector, Signal)
%
figure(1);
plot (Time_vector, Signal);
zoom on
disp ('Zoom into the desired calibration period')
disp ('press any key to get the start and finish indexes of the time period')
pause
a = axis;
s = (find(Time_vector >= a(1)));
f = (find(Time_vector <= a(2)));
start = min(s)
finish  = max(f)
