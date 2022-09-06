function x = autoimg(image1, map1)
% function x = autoimg(image1, map1)
%
%   This function plots a *.bmp image (image1) with its map (map1)
% on the high resolution screen (1024x768). The figure is full screen wide
% and a bit more than half (5/7) screen high. This function is used as a part
% of a digitizer toolbox made for BIOMET group at UBC.
%
% Inputs:
%       image1:         image obtained by loadbmp.m function
%       map1:           color map obtained by loadbmp.m function
%
% Outputs:
%       x:              axis handle
%
%
% Comment:
%           This function plots a *.bmp image (image1) with its map (map1)
%       on the high resolution screen (1024x768). The figure is full screen wide
%       and a bit more than half (5/7) screen high. This function is used as a part
%       of a digitizer toolbox made for BIOMET group at UBC.
%
%
% (c) 1995, Zoran Nesic
%
image(image1);
colormap(map1);
x = axis('image');
set(gcf,'position',[10 1000 1000 500]);

