function gui_Browse_Folder(pathIn)
%  gui_Browse_Folder - browse UBC database folder
%
% This function is used to browse a Biomet database folder
%
% Inputs:
%  siteID   - pathIn
%
%
% Zoran Nesic                   File created:       May 26, 2023
%                               Last modifications: May 26, 2023

% Revisions:
%

    % Find a time vector first
    if exist(fullfile(pathIn,'clean_tv'),'file')
        fileNameTv = 'clean_tv';
    elseif exist(fullfile(pathIn,'Time_Vector'),'file')
        fileNameTv = 'Time_Vector';
    end

    tv = read_bor(fullfile(pathIn,fileNameTv),8);
    % % Create time vector (do not assume that it exists, assume 30min data)
    % tv = fr_round_time(datenum(yearX,1,1,0,30,0):1/48:datenum(yearX+1,1,1));
    tv_dt = datetime(tv,'convertfrom','datenum');


    fig = [];

    % find all the files in the current folder
    s_all = dir(pathIn);                    % find all files in the old folder
    if isempty(s_all) 
        error ('0 files found in %s. Program stopped.',filePath_old);
    end
    % Remove all values that are not propare data files
    cntTmp = 0;
    for cntS = 1:length(s_all)
        currentFile = fullfile(pathIn,s_all(cntS).name);
        if ~exist(currentFile,'dir') ...
            && ~contains(currentFile,'Time_vector')...
            && ~contains(currentFile,'clean_tv')
            cntTmp = cntTmp+1;
            if cntTmp == 1
                tmp = s_all(cntS);
            else
                tmp(cntTmp) = s_all(cntS);
            end
        end
    end
    s_all = tmp;
    
    while 1==1
        %---------------------
        % Data plotting
        %---------------------
        if isempty(fig)
            % Create figure
            fig = uifigure;
            UserData.cnt = 0;
            UserData.next=0;
            set(fig,'UserData',UserData);
            ah = axes(fig); %#ok<LAXES>
            hExitButton = uibutton(fig,'push',...
                'Text','Exit',...
                'Position',[20, 60, 100, 40],...
                'ButtonPushedFcn', @(hExitButton,event) exitButtonPushed(hExitButton,fig)); %#ok<NASGU>
            hNextButton = uibutton(fig,'push',...
                'Text','>>',...
                'Position',[70, 184, 50, 40],...
                'ButtonPushedFcn', @(hNextButton,event) nextButtonPushed(hNextButton,fig)); %#ok<NASGU>
            hPreviousButton = uibutton(fig,'push',...
                'Text','<<',...
                'Position',[20, 184,50, 40],...
                'ButtonPushedFcn', @(hPreviousButton,event) previousButtonPushed(hPreviousButton,fig)); %#ok<NASGU>
            hDropDown = uidropdown(fig,...
                    'Editable','on',...
                    'Position',[550,450,800,25],...
                    'Items',{s_all(:).name},...
                    'ItemsData',1:length(s_all),...
                    'Value',s_all(1).name,'ValueChangedFcn',@(hDropDown,event) optionSelected(hDropDown,fig)); 

        else
            % every time drop down is used the UserData.cnt goes to -1
            % which in turn causes the same plot to be replotted
            % but with different view (Time Plot or 1:1)
            % default is to advance to the next plot(cnt = 0)
            UserData.next=0;
            set(fig,'UserData',UserData);
        end
        
        %currentFile = fullfile(pathIn,s_all(cntFiles).name);            
        currentFile = fullfile(pathIn,char(hDropDown.Items(hDropDown.Value)));
        x_new = read_bor(currentFile);

        plot(ah,tv_dt,x_new,'color','#0072BD','marker','o','linestyle','none')
        grid(ah,'on');
        zoom(ah,'on');
%             title(ah,s_all(cntFiles).name,'interpreter','none');
        while UserData.next==0
            % loop here until user request re-plot by changing the
            % plot type or by clicking on the "Next" button 
            UserData = get(fig,'UserData');
            drawnow
        end
        switch UserData.next
            case -1
                itemNext = hDropDown.Value - 1;
                if itemNext <= 0 
                    itemNext = 1;
                end
                hDropDown.Value = itemNext;
            case 1
                itemNext = hDropDown.Value + 1;
                if itemNext > length(s_all) 
                    itemNext = length(s_all);
                end
                hDropDown.Value = itemNext ;              
            case 2
                % if the button that was pressed was "Exit"                    
                fprintf('User stopped program. Exiting...\n');
                close(fig)
                return
            case 3
                % Just plot the selected trace
        end

    end
end

% Ymax limit changed
function hMaxChanged(hYmax,fig)
    oldLim = ylim;
    ylim([oldLim(1) hYmax.value])
end


% Create ValueChangedFcn callback
function optionSelected(hDropDown,fig)
    val = hDropDown.Value; %#ok<NASGU>
    UserData = get(fig,'UserData');
    % if only the type of plot changed
    % return the file counter back by one so the program
    % plots the same plot again (cnt=-1)
    UserData.next = 3;
    set(fig,'UserData',UserData)
end

% Create the function for the ButtonPushedFcn callback
function nextButtonPushed(btn,fig) %#ok<INUSL>
    UserData = get(fig,'UserData');
    UserData.next = 1;
    set(fig,'UserData',UserData);
end

% Create the function for the ButtonPushedFcn callback
function previousButtonPushed(btn,fig) %#ok<INUSL>
    UserData = get(fig,'UserData');
    UserData.next = -1;
    set(fig,'UserData',UserData);
end

% Create the function for the ExitButtonPushedFcn callback
function exitButtonPushed(btn,fig) %#ok<INUSL>
    UserData = get(fig,'UserData');
    UserData.next = 2;
    set(fig,'UserData',UserData);
end