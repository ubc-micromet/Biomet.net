function [ PointCounter, x_data, y_data, cb_plot] = dl_point( PointCounter, x_data, y_data, cb_plot, cb)
% function [ PointCounter, x_data, y_data, cb_plot] = dl_point( PointCounter, x_data, y_data, cb_plot, cb)
%
%
% Inputs:
%           PointCounter:       The number of points taken (without the new one)
%           x_data:             x-coordinats of all PointCounter points
%           y_data:             y-coordinats of all PointCounter points
%           cb:                 vector of the text handles
%           cb_plot             the handle of the OLD line (cb_plot = plot(x_data, y_data)
%
% Outputs:
%           PointCounter:       The number of points taken (including the new one)
%           x_data:             x-coordinats of all PointCounter points 
%           y_data:             y-coordinats of all PointCounter points
%           cb_plot             the handle of the NEW line (cb_plot = plot(x_data, y_data)
%
%
%
% Comment:
%          This function deletes the last point from the [x_data y_data] arrays
%       and  refreshes the plot of that line (handle = cb_plot ). 
%       It is a part of digitizer toolbox created for BIOMET group at UBC.
%
% (c) 1995, Zoran Nesic
%
% 
%
%
if PointCounter > 0
    PointCounter = PointCounter - 1;
    if PointCounter < 1
        x_data = [];
        y_data = [];
        set(cb(1), 'string',sprintf('x = %9.2f', 0)); 
        set(cb(2), 'string',sprintf('y = %9.2f', 0)); 
        set(cb(3), 'string',sprintf('n = %7.3d', PointCounter)); 
    else
        x_data = x_data(1:PointCounter);
        y_data = y_data(1:PointCounter);
        set(cb(1), 'string',sprintf('x = %9.2f', x_data(PointCounter))); 
        set(cb(2), 'string',sprintf('y = %9.2f', y_data(PointCounter))); 
        set(cb(3), 'string',sprintf('n = %7.3d', PointCounter)); 
    end
    echo off;
    hold on;
    if exist('cb_plot') == 1
        if cb_plot ~= []
            close(cb_plot);
        end
    end 
    cb_plot = plot(x_data,y_data,'r');
    hold off;
    echo on;
end

