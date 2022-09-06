function fr_plot_raw(dateIn,SiteID,pth)

if ~exist('SiteID')
    SiteID = FR_current_siteID;
 end
 
Eddy_HF_data = fr_read_raw(dateIn,SiteID);
 
[meansSr,statsSr,angles] = fr_rotatn( ...
   [mean(Eddy_HF_data(:,1:3))],cov(Eddy_HF_data));

%[Eddy_HF_data] = fr_rotatn_hf(Eddy_HF_data,angles);

u = Eddy_HF_data(:,1);
v = Eddy_HF_data(:,2);
w = Eddy_HF_data(:,3);
T = Eddy_HF_data(:,4);
C = Eddy_HF_data(:,5);
H = Eddy_HF_data(:,6);

tv = (1:length(w)) / 20.83; % in Hz

left = 0.13;
bottom = 0.11;
width = 0.775;			% width of plots
height = (1-2*bottom)/5;			% height of plots

h_figure = figure;
subplot('Position', [left bottom+(4*height) width height])
h1=gca;
plot(tv,w);
axis([1 1800 mean(w)-3.5*std(w) mean(w)+3.5*std(w)]);
set(h1,'XTickLabel','');
ylabel('w (m/s)');

% Plot title now so it is on top of the first subplot
FileName_p = fr_datetoFilename(dateIn);
yy = str2num(FileName_p(1:2));
if yy > 50
   yy = 1900 + yy;
else
   yy = 2000 + yy;
end

title([FileName_p ' - ' datestr(datenum(...
   yy,...
   str2num(FileName_p(3:4)),...
   str2num(FileName_p(5:6)),...
   str2num(FileName_p(7:8))/96*24- FR_get_offsetGMT(SiteID)./24,0,0) )]);

figure(h_figure);
subplot('Position', [left bottom+(3*height) width height])
h1=gca;
plot(tv,u);
axis([1 1800 mean(u)-3.5*std(u) mean(u)+3.5*std(u)]);
set(h1,'XTickLabel','YAxisLocation','right');
ylabel('u (m/s)');

figure(h_figure);
subplot('Position', [left bottom+(2*height) width height])
h1=gca;
plot(tv,T);
axis([1 1800 mean(T)-3.5*std(T) mean(T)+3.5*std(T)]);
set(h1,'XTickLabel','');
ylabel('T (^oC)');

figure(h_figure);
subplot('Position', [left bottom+(1*height) width height])
h1=gca;
plot(tv,C);
axis([1 1800 mean(C)-3.5*std(C) mean(C)+3.5*std(C)]);
set(h1,'XTickLabel','','YAxisLocation','right');
ylabel('\chi_C (ppm)');

figure(h_figure);
subplot('Position', [left bottom+(0*height) width height])
plot(tv,H);
axis([1 1800 mean(H)-3.5*std(H) mean(H)+3.5*std(H)]);
xlabel('t (s)');
ylabel('\chi_H (ppm)');

max_win = [1 34 1024 657]; % This is the size of a maximized window on annex002
set(gcf,'Position',max_win);
