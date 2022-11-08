yearX = 2019 ;
traceName = 'MET_Barom_Press_kPa_Avg';
siteID = 'BB2';
switch siteID
    case 'BB'
        pth=biomet_path(yearX,siteID,'Met/5min');
    case 'BB2'
        pth=biomet_path(yearX,siteID,'Met');
end
tv=read_bor(fullfile(pth,'clean_tv'),8,[],yearX);

s = dir(pth);
for i=1:length(s)
    if ~s(i).isdir && ~strcmpi(s(i).name,'clean_tv') && ~strcmpi(s(i).name,'timevector')
        % for all items that are not folder or are time vectors, do the
        % plotting
        x=read_bor(fullfile(pth,s(i).name),[],[],yearX);
        nanTrace = ones(size(x))*nanmean(x);
        figure(3);
        indnan = isnan(x);
        indzero = x==0;
        plot(tv         -datenum(yearX,1,0),x,...
             tv(indnan) -datenum(yearX,1,0),nanTrace(indnan),'or',...
             tv(indzero)-datenum(yearX,1,0),x(indzero),'og')
         ax = axis;
         axis([floor([datenum(2019,11,13) now+1]-datenum(2019,1,0)) ax(3:4)]);
        title(sprintf('%d/%d  %s',i,length(s),s(i).name),'Interpreter', 'none')
        xlabel(yearX)
        pause
    end
end