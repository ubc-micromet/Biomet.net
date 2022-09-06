function view_selected_sites(fig)
% view_selected_sites.m is run as a callback from view_sites
% Input: 
%   fig - figure handle for the view_site menu figure
%

Selection.SitePlots = get_gui_string(fig,'lboxPlots');
Selection.SiteNames = get_gui_string(fig,'lboxSites');
[junk,Selection.Diagnostics] = get_gui_string(fig,'chkDiagnostics');
Selection.Year = datevec(now);
Selection.Year = Selection.Year(1);
Selection.DateRange = get_gui_string(fig,'popDate');
switch Selection.DateRange
    case 'Last 7 days',
        Selection.DateRange = floor(now)-6:floor(now);
        Selection.DOY = Selection.DateRange - datenum(Selection.Year,1,0);
    case 'Last 14 days',
        Selection.DateRange = floor(now)-13:floor(now);
        Selection.DOY = Selection.DateRange - datenum(Selection.Year,1,0);
    case 'Last 30 days', 
        Selection.DateRange = floor(now)-30:floor(now);        
        Selection.DOY = Selection.DateRange - datenum(Selection.Year,1,0);
    otherwise,
        [tvDateFrom,tvDateTo] = local_extract_dates(Selection.DateRange);
        if isempty(tvDateFrom)
            return
        end
        Selection.Year = datevec(tvDateFrom);
        Selection.Year = Selection.Year(1);
        Selection.DOY = [tvDateFrom:tvDateTo] - datenum(Selection.Year,1,0);
end


for i = 1:length(Selection.SiteNames)
        try;
            %view_one_site(ind,year,SiteID,select);
            view_one_site(Selection.DOY,Selection.Year,deblank(Selection.SiteNames(i,:)),Selection.SitePlots,Selection.Diagnostics);
        end
end

return

function [sString,indSelection] = get_gui_string (hObject,tagValue)

hNew = findobj(hObject,'tag',tagValue);        % get the handle to Site listbox
indSelection = get(hNew,'value');
sString = get(hNew,'String');
if indSelection > 0
    sString = char(sString(indSelection));
else
    sString = [];
end
return

function [tvDateFrom,tvDateTo] = local_extract_dates(dateRange);
    strDateFrom = dateRange(findstr(dateRange,'From:')+6:findstr(dateRange,'To:')-2);
    strDateTo   = dateRange(findstr(dateRange,'To:'  )+4:end);
    tvDateFrom = local_str_to_tv(strDateFrom);
    tvDateTo   = local_str_to_tv(strDateTo);
    
    
function tvOut = local_str_to_tv(strIn)    
    indSlash = find(strIn == '/');
	if isempty(indSlash)
        tvOut = [];
        return
	end
	xYear = str2num(strIn(1:indSlash(1)-1));
	if length(indSlash) == 1
          xDOY  = str2num(strIn(indSlash(1)+1:end));
          tvOut = datenum(xYear,1,xDOY);          
      else
          tvOut = datenum(...
                            xYear,...
                            str2num(strIn(indSlash(1)+1:indSlash(2)-1)),...
                            str2num(strIn(indSlash(2)+1:end)));
	end               



