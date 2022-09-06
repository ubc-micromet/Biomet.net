function [PointNew, PointCounter, x_data, y_data, cb_plot] = getp( PointOld, PointCounter, x_data, y_data, cb, cb_plot)
% function [PointNew, PointCounter, x_data, y_data, cb_plot] = getp( PointOld, PointCounter, x_data, y_data, cb, cb_plot)
% 
% Inputs:
%           PointOld:           Last point taken off the screen 
%           PointCounter:       The number of points taken (without the new one)
%           x_data:             x-coordinats of all PointCounter points
%           y_data:             y-coordinats of all PointCounter points
%           cb_plot:            the handle of the last line plotted (cb = plot(x_data, y_data)
%           cb:                 vector of the text handles
%
% Outputs:
%           PointNew:           New point taken off the screen
%           PointCounter:       The number of points taken (including the new one)
%           x_data:             x-coordinats of all PointCounter points 
%           y_data:             y-coordinats of all PointCounter points
%           cb_plot             the handle of the new line (cb_plot = plot(x_data, y_data)
%
% Comment:
%           This function is interrupt handler for the 'WindowButtonUpFcn'. It takes
%   the new point (matlab-plot coordinates of the point where the mouse was clicked).
%   If the new point (PointNew) is the same as the previous one (PointOld) than no 
%   action will be taken. Else, the point counter will be incremented (PointCounter),
%   coordinates will be stored and printed on the screen together with the counter.
%   Then, the old line will be deleted and new one plotted. The handle of the line
%   object will be passed as an output parameter.
%
%   getp.m is a function from the digitizer toolbox created for BIOMET group, UBC.
%
% (c) 1995, Zoran Nesic
%
PointNew = get(gca,'CurrentPoint');                                 % get new point
if any(any(PointNew ~= PointOld))                                   % check if the new point
    PointOld = PointNew;                                            % differs from the previous one
    PointCounter = PointCounter + 1;                                % if so, add it to the data
    x_data(PointCounter) = PointNew(1,1);
    y_data(PointCounter) = PointNew(1,2);   
    set(cb(1), 'string',sprintf('x = %9.2f', x_data(PointCounter)));% print the new values 
    set(cb(2), 'string',sprintf('y = %9.2f', y_data(PointCounter))); 
    set(cb(3), 'string',sprintf('n = %7.3d', PointCounter));    
    hold on                                                         % delete the old line plot
    if exist('cb_plot') == 1                                        % if it exists
        close(cb_plot);
    end 
    cb_plot = plot(x_data,y_data,'r');                              % plot the new line
    hold off
end

