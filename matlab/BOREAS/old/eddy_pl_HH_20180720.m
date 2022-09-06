function [] = eddy_pl_HH(ind, year, SiteID, select)
%
% Revisions
%
%  July 10, 2018 (Zoran)
%   - created file based on eddy_pl_LGR2
%

colordef 'white'
st = datenum(year,1,min(ind));                         % first day of measurements
ed = datenum(year,1,max(ind));                         % last day of measurements (approx.)
startDate   = datenum(min(year),1,1);     
currentDate = datenum(year,1,ind(1));
days        = ind(end)-ind(1)+1;
GMTshift = 8/24; 

if nargin < 3
    select = 0;
end

pth = ['\\PAOA001\SITES\' SiteID '\hhour\'];


%load in fluxes
switch upper(SiteID)
    case 'HH'
        [pthc] = biomet_path(year,'HH','cl');
        pth = '\\PAOA001\SITES\HH\hhour\';
        ext         = '.hHH.mat';
%         GMTshift = -c.gmt_to_local;
        fileName = fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','\clean_tv');
        tv       = read_bor(fileName,8);                       % get time vector from the data base

        tv  = tv - GMTshift;                                   % convert decimal time to
                                                       % decimal DOY local time

        ind   = find( tv >= st & tv <= (ed +1));                    % extract the requested period
        tv    = tv(ind);
%         
%          nMainEddy = 1;

         % Load diagnostic climate data        
         Batt_logger_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','Batt_Volt_99_99_Min'),[],[],year,ind);
         
         Ptemp_logger = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','PTemp_2_1'),[],[],year,ind);
         HMP_RH = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','RH_19_3_Avg'),[],[],year,ind);
         HMP_T = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','TA_2_1_Avg'),[],[],year,ind);


    otherwise
        error 'Wrong SiteID'
end

     
%figures

%reset time vector to doy
tv   = tv - startDate + 1;
st   = st - startDate + 1;
ed   = ed - startDate + 1;

fig = 0;



%-----------------------------------------------
% HMP Air Temp 
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,HMP_T);
ylabel( 'T \circC')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'HMP_{T}'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% HMP RH
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,HMP_RH);
ylabel( '%')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'HMP_{RH}'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%------------------------------------------
if select == 1 %diagnostics only
    childn = get(0,'children');
    childn = sort(childn);
    N = length(childn);
    for i=childn(:)';
        if i < 200 
            figure(i);
%            if i ~= childn(N-1)
                pause;
%            end
        end
    end
    return
end
%-----------------------------------------------




childn = get(0,'children');
childn = sort(childn);
N = length(childn);
for i=childn(:)';
    if i < 200 
        figure(i);
%        if i ~= childn(N-1)                
            pause;    
%        end
    end
end  

function set_figure_name(SiteID)
     title_string = get(get(gca,'title'),'string');
     set(gcf,'Name',[ SiteID ': ' char(title_string(2))],'number','off')
