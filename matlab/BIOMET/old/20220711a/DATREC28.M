% script datrec28.m
%
% Inputs:
%       none
%
% Outputs:
%       image1:     bitmap image
%       map1:       its color map
%
%
% Comment:
%       This is an example script that shows a way how to use the digitizer toolbox made
%       for the BIOMET group at UBC. The script clears the memory, loads a bitmap image and
%       calls the main script of the digitizer toolbox (dig_tool)
%
%
% (c) 1995, Zoran Nesic
%
%
clear;
[image1,map1]=loadbmp('nbal28');
%tic;
f1 = figure;
autoimg(image1, map1);
dig_tool


