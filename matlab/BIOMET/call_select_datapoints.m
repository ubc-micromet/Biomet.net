function call_select_datapoints
%
% example for how to use function 'select_datapoints'
% select datapoints from a subplot by mouseclick 
% (one point per mouseclick, end input by hitting 'enter')
% output index of data points -> use to mark same datapoints in other subplot
%
% created 10 July 2002, natascha kljun
% 
clear all;
close all;

x1  = [1:1:100];
x2  = x1.*2;
y1  = x1.^2;
y2  = x2.^(1/5);
x3  = [20:1:200];
x4  = (x3-4).*2;
y3  = x3.^2;
y4  = x4.^(1/5);

figure(1)
subplot(2,2,1);
plot (x1,y1,'.');

subplot(2,2,2);
plot (x2,y2,'.');

subplot(2,2,3);
plot (x1,x1,'.');

subplot(2,2,4);
plot (y1,y2,'.');

% create menu-window on mouseclick
select_datapoints(gcf);

return
%----------------------------------------

figure(2)
subplot(2,2,1);
plot (x3,y3,'.');

subplot(2,2,2);
plot (x4,y4,'.');

subplot(2,2,3);
plot (x3,x3,'.');

subplot(2,2,4);
plot (y3,y4,'.');


% create menu-window on mouseclick
select_datapoints(gcf);
   
%----------------------------------------

figure(3)
subplot(2,2,1);
plot (x3,y4,'.');

subplot(2,2,2);
plot (x3,y3,'.');

subplot(2,2,3);
plot (x4,x4,'.');

subplot(2,2,4);
plot (y4,y3,'.');


% create menu-window on mouseclick
select_datapoints(gcf);
   
   
return

