function zoom_together(fig,axesFlag,setupFlag)
%
% File: zoom_together.m
%
% Inputs:
%
%   fig         -   figure handle
%
%   axisFlag    -   'x'    - align x-axes
%                   'y'    - align y-axes (default)
%                   'both' - align both axes
%
%   setupFlag   -   'on'   - installs zoom_together with the given "fig" and "axesFlag"
%                   'off'  - removes  zoom_together and keeps "zoom on"
%                   'clear'- removes  zoom_together and sets "zoom off"
%
% Notes: 
%       This program is used to align axes in the same figure after a zoom operation is 
%       executed on one of the subplots. It is initialized (with default parameters) 
%       by setting the "setupFlag" option "on":
%           zoom_together([],[],'on')
%       It can be turned off by executing: 
%           zoom_together([],[],'off')     -> this will still keep normal zoom on
%           zoom_together([],[],'clear')   -> this will remove zoom completly
%       Flag "axisFlag" is used to choose which axes (x,y or both) are going to be aligned.
%       If a plot has one of the tags: "md", "image" or "colorbar" associated with it
%       it will perform in a bit different way (see the program).
%
% 
% See also: plot_CDMD.m
%
% (c) Zoran Nesic       File created:       Sep 11, 1998
%                       Last modification:  Oct  2, 1998

% Revisions:
%
% Oct 2, 1998
%   - added comments
%   - defined what happens when parameter "fig" is missing or empty
%   - added "set(0,'currentfigure',fig)" to make sure that the requested figure is current
%     Of course, the above changes to fig and currentfigure do not matter because the zoom
%     operation can only be performed on the current figure, but I am going to leave it in
%     for "educational purposes".
%   - changed the entire program so it provides (de)initialization options as well as a
%     choice of axes affected by the alignment.
%   - reduced the number of decimal places for MD legend down to 1
%

if exist('fig') ~= 1 | isempty(fig)             % deal with missing/empty fig
    fig = gcf;
end
if exist('axesFlag') ~= 1 | isempty(axesFlag)   % deal with missing/empty fig
    axesFlag = 'both';
end
if exist('setupFlag')                           % (de)initialization
    switch lower(setupFlag)
        case 'on',            
            zoom on;                            % initialize zoom  
            allAxes = findobj(get(fig,'Children'),'flat','type','axes');
            for i=1:length(allAxes)
                set(fig,'currentaxes',allAxes(i))
                zoom(1);
            end     
            setupStatementOn  = sprintf('set(fig,''WindowButtonDownFcn'',''zoom down;zoom_together(gcf,''''%s'''')'')',axesFlag);
            eval(setupStatementOn);
        case 'off',
            setupStatementOff = sprintf('set(fig,''WindowButtonDownFcn'',''zoom down'')',axesFlag);
            eval(setupStatementOff);
        case 'clear', 
            zoom off;
            set(fig,'WindowButtonDownFcn','');
        otherwise,
    end
    return                                      % if "setupFlag" option is used return to the main program
end

set(0,'currentfigure',fig)                      % make "fig" current figure
ax = axis;                                      % get current axis
tag = get(gca,'tag');                           % get tags (used in plot_CDMD.m)
switch lower(tag)
    case 'md'   ,scanAx = ax(3:4);mdAx=ax(1:2); % get MD and scan axes
    case 'image',scanAx = ax(3:4);dbAx=ax(1:2); % get scan axis and data box axes
    case 'cd',cdAx = ax(1:2);dbAx=ax(1:2);      % get CD and data box axes
    case 'colorbar', return                     % no special effects when zooming in a colorbar
    otherwise,   
        switch lower(axesFlag)                  % choose the axes affected by the adjustment
            case 'y', ax = ax(3:4);             
            case 'x', ax = ax(1:2);
            case 'both',ax = ax;
            otherwise, ax = ax;                  % default is both
        end
end

if ~isempty(ax)
    allAxes = findobj(get(fig,'Children'),'flat','type','axes');
    for i=1:length(allAxes)
        set(fig,'currentaxes',allAxes(i));
        tagx = get(gca,'tag');
        axx = axis;
        switch lower(tagx)
            case 'md',if exist('scanAx')==1
                            axx(3:4) = scanAx;
                            axis(axx);
                            xticks = linspace(min(axx(1:2)),max(axx(1:2)),3);
                            set(gca,'xtick',xticks);
                            set(gca,'xticklabel',num2str(xticks','%3.1f'));
                            end
            case 'colorbar';
            case 'image',if exist('scanAx')==1
                            axx(3:4) = scanAx;
                            end
                         if exist('dbAx')==1
                            axx(1:2)=dbAx;
                            end
                         axis(axx);
            case 'cd',   if exist('dbAx')==1
                            axx(1:2)=dbAx;
                            l = size(get(gca,'ytick'),2);                       % get the number of ticks
                            yticks = linspace(min(axx(3:4)),max(axx(3:4)),l);   % create new ticks
                            set(gca,'ytick',yticks);                            % set ticks
                            set(gca,'yticklabel',num2str(yticks','%3.1f'));     % set tick labels
                            end
                         axis(axx);
            otherwise, 
                switch lower(axesFlag)
                    case 'y',       axx(3:4)= ax;axis(axx);
                    case 'x',       axx(1:2)= ax;axis(axx);
                    case 'both',    axx     = ax;axis(axx);
                    otherwise,       axx(3:4)= ax;axis(axx);
                end
        end    
    end
end
                
