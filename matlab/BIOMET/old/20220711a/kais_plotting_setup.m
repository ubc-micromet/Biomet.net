colordef white

pick = 16;
max_win = [1 34  899 657]; % This is the aspect ration that I use for figures

% Figure
set(0,'DefaultFigurePosition',max_win);

%	Axes (font, size line etc.)
set(0,'DefaultAxesFontSize',pick) 
set(0,'DefaultAxesFontName','Arial')
set(0,'DefaultAxesLineWidth', 1.5)
set(0,'DefaultAxesTickLength',[0.01 0.02])
set(0,'DefaultAxesColor','none')

%	text font
set(0,'DefaultTextFontSize',pick) %11
set(0,'DefaultTextFontName','Arial')

%	lines
set(0,'DefaultLineLineWidth', 0.5)
