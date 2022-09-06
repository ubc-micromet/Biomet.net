% Script giving examples for  the use of the 
% subplot_position and subplot_label functions. 
% Also read the help for functions subplot, 
% subplot_position and subplot_label!

% kai* Dec 02, 2003

%-------------------------------------------------------------
% Read temperature for four sites and plot it on four panels
%-------------------------------------------------------------
T_BS = read_bor([biomet_path(2002,'bs','clean\secondstage') 'air_temperature_main']);
T_CR = read_bor([biomet_path(2002,'cr','clean\secondstage') 'air_temperature_main']);
T_JP = read_bor([biomet_path(2002,'jp','clean\secondstage') 'air_temperature_main']);
T_PA = read_bor([biomet_path(2002,'pa','clean\secondstage') 'air_temperature_main']);
tv   = read_bor([biomet_path(2002,'pa','clean\secondstage') 'clean_tv'],8);
doy = convert_tv(tv,'nod');

%-------------------------------------------------------------
% Simple approach - just use default axis scaling
% PROBLEM: The axis might be scaled differently
%-------------------------------------------------------------
% This figure command is only neccessary if the figure is
% supposed to have a certain aspect ratio
figure('Position',[100 100 500 500]);  

h1 = subplot('Position',subplot_position(2,2,1));
plot(doy,T_BS);
subplot_label(gca,2,2,1);

h2 = subplot('Position',subplot_position(2,2,2));
plot(doy,T_CR);
subplot_label(gca,2,2,2);

h3 = subplot('Position',subplot_position(2,2,3));
plot(doy,T_JP);
subplot_label(gca,2,2,3);

h4 = subplot('Position',subplot_position(2,2,4));
plot(doy,T_PA);
subplot_label(gca,2,2,4);

%-------------------------------------------------------------
% More complete approach - use preset axis scaling
%-------------------------------------------------------------
% This figure command is only neccessary if the figure is
% supposed to have a certain aspect ratio
tck_doy = [1 91 182 274 365]; % tri-monthly ticks
tck_ta  = [-30:15:45]; 

subplot_label(h1,2,2,1,tck_doy,tck_ta,1);
subplot_label(h2,2,2,2,tck_doy,tck_ta,1);
subplot_label(h3,2,2,3,tck_doy,tck_ta,1);
subplot_label(h4,2,2,4,tck_doy,tck_ta,1);

%-------------------------------------------------------------
% Add a single set of axis labels for good measure
%-------------------------------------------------------------
axes('Position',subplot_position(1,1,1),'Visible','off')
text(0.5,-0.05,'DOY','HorizontalA','center','VerticalA','top'); 
text(-0.05,0.5,'T_{air} (^oC)','HorizontalA','center','VerticalA','bottom','Rotation',90);

return
