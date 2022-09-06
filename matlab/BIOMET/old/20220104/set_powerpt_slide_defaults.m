% Positioning and sizeing of Matlab figures
% 
% 1) PPT slides
% 
% In PPT choose On-screen presentation, paper size will 
% be 24cm wide and 18 cm high. 
%
% In Matlab EMF files are produced. For these, paper properties do not
% matter. The file is simply imported and placed at the center of the page.
% The goal here is therefore to produce a figure that being placed that way
% does not need to be moved or resized when imported into PPT from an EMF
% file.
%
% To achieve this the aspect ratio of the figure and the position of the
% axis within the figure need to be set. In Matlab all positions are set as
% a four-element vector 
% [lower-left-corner-x lower-left-corner-y width height]
%
% The aspect ratio of the figure needs to be the same as that of the
% On-screen presentation.

pos_screen = get(0,'ScreenSize');
% This would be the screen size but then the 
% menu bar and botton on the figure are pushed beyond the screen limit.
% Therefore we here create a figure of a height of 650 pixels (empirical
% limit for kai*'s laptop with windows tool bar always visible) that is
% nicely centered on the sreen.
height = 650;
width = round(height .* pos_screen(3)/pos_screen(4));
pos_fig = [round((pos_screen(3)-width)/2) 40 width height]; 
set(0,'DefaultFigurePosition',pos_fig);
% There is a bug in Matlab that prevents it from having figure positions
% bigger than 696 on kai*'s laptop, so figures exported through
% print -dmeta will need to be resized in PPT

% In the default Biomet presentation the top 2.75cm are reserved for the
% title bar. A similar amount of space should be left for the tick and axis
% labels. Here default sizes are set to values needed for PPT On-screen
% presentations
set(0,'DefaultAxesFontSize',22) 
set(0,'DefaultAxesFontName','Arial')
set(0,'DefaultAxesLineWidth', 1.5)
set(0,'DefaultAxesTickLength',[0.01 0.02])
set(0,'DefaultAxesColor','none')
set(0,'DefaultTextFontSize',22)
set(0,'DefaultTextFontName','Arial')
set(0,'DefaultLineLineWidth', 0.5)

% Default for AxesPosition: [0.1300    0.1100    0.7750    0.8150]
% The lower margin needs to be moved up just a bit and then the upper 
% margin needs to be reduce by 2.74/18:
set(0,'DefaultAxesPosition',[0.1300    0.1300    0.74    0.7950-((0.7950+0.1300)*2.75/18)]);

pos = get(0,'DefaultAxesPosition');
