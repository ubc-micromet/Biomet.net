function view_selected_sites(fig)
% view_selected_sites.m is run as a callback from view_sites
% Input: 
%   fig - figure handle for the view_site menu figure
%


    h = findobj(fig,'tag','PopupMenu1');        % get the Year pop-up menu
    k=get(h,'String');                          % read the string matrix
    s=k(get(h,'value'),:);                      % extract the Year string (cell array)
    year = str2num(s{:});                       % convert it to number

    h = findobj(fig,'style','Radiobutton','value',3);   % get the radio-button handle
    switch get(h,'tag')                                 % select DOYs to plot 
        case 'Radiobutton1'                             % 7 days
%            [today_DOY today_year]= fr_get_doy(now,0);
            today_DOY = now - datenum(year,1,0);
            today_DOY = floor(today_DOY);
            ind=today_DOY-6:today_DOY;
        case 'Radiobutton2'                             % 14 days
            today_DOY = now - datenum(year,1,0);
            today_DOY = floor(today_DOY);
            ind=today_DOY-13:today_DOY;
        case 'Radiobutton3'                             % 30 days
            today_DOY = now - datenum(year,1,0);
            today_DOY = floor(today_DOY);
            ind = today_DOY-29:today_DOY;
        case 'Radiobutton4'                             % user selected DOYs
            ind = str2num(get(findobj(fig,'tag','fromDOY'),'string')): ...
                  str2num(get(findobj(fig,'tag','toDOY')  ,'string'));
        otherwise
            error Wrong DOY selection
    end
    
    %process diagnostics only selection
    h_diag = findobj(fig,'Tag','CheckboxDiag');
    select = get(h_diag,'Value');
    
    %---------------
    % process sites
    %---------------
    h = findobj(fig,'Style','checkbox');        % find handles for all check boxes
    h = h(end:-1:1);                            % reorder them
    x = get(h,'Value');                         % get their values
 %   x = cat(1,x{:});                            % convert to string matrix
    y = get(h,'Value');                         % get their values, Shawn changed x to y
    
    x = y([1 6 9 12 15 18 25 32]);						% added by Shawn: filter out category check boxes
    x = cat(1,x{:});  								% convert to string matrix
    
    SiteNames = str2mat('CR','OY','YF','HJP02','HJP75','PA','BS','JP');  
    for i = 1:length(SiteNames)
        if x(i) > 0
            stringOld = get(h(i),'string');
            backgroundColor = get(h(i),'background');
            set(h(i),'background',[0.9 0 0]...
                    ,'String',[stringOld]...
                );
            %%%%%
            SiteID = deblank(SiteNames(i,:));
            fr_set_site(SiteID,'network');
            %%%%%%
            switch SiteID % added by Shawn: parse selected sub categories
            case 'OY'
               Tcat=y([7 8]);
               Tcat=cat(1,Tcat{:});
            case 'YF'
               Tcat=y([10 11]);
               Tcat=cat(1,Tcat{:});
            case 'HJP02'
               Tcat=y([13 14]);
               Tcat=cat(1,Tcat{:});
            case 'HJP75'
               Tcat=y([16 17]);
               Tcat=cat(1,Tcat{:});
            case 'CR'
               Tcat=y([2 3 4 5]);
               Tcat=cat(1,Tcat{:});            
            case 'PA'
               Tcat=y([19 20 21 22 23 24]);
               Tcat=cat(1,Tcat{:});    
            case 'BS'
               Tcat=y([26 27 28 29 30 31]);
               Tcat=cat(1,Tcat{:});
            case 'JP'
               Tcat=y([33 34 35 36 37 38]);
               Tcat=cat(1,Tcat{:});
         	end 
            try;
                %view_one_site(ind,year,SiteID,select);
                view_one_site(ind,year,SiteID,Tcat,select);
            end
            set(h(i),'background',backgroundColor...
                    ,'String',stringOld...
                );
        end
    end

    close_all_Fig_but_200       