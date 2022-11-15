% testing 5-min vs 30-min data files
% create paths
yearX = 2018;
siteID = 'BB';
pthDbase = db_pth_root;
folder5min = fullfile(pthDbase,num2str(yearX),siteID,'Met\5min');
folder30min = fullfile(pthDbase,num2str(yearX),siteID,'Met');

tv_5min = read_bor(fullfile(folder5min,'clean_tv'),8)-datenum(yearX,1,0);
tv_30min = read_bor(fullfile(folder30min,'clean_tv'),8)-datenum(yearX,1,0);

s = dir(folder5min);
fprintf('Processing folder: %s.  %d files and folder found.\n\n',folder5min,length(s));
k = 0;
ind1 = [];%NaN*zeros(length(tv_5min),1);
k=0;
for i=1:12:length(tv_5min);
    k = k+1;
    ind1(k)= i;
    k = k+1;
    ind1(k)= i+1;
    k = k+1;
    ind1(k)= i+2;
    k = k+1;
    ind1(k)= i+3;
    k = k+1;
    ind1(k)= i+4;
    k = k+1;
    ind1(k)= i+5;
end
for i=1:length(s)
    if ~s(i).isdir && ~strcmpi(s(i).name,'clean_tv') && ~strcmpi(s(i).name,'timevector')
        % for all items that are not folder or are time vectors, do the
        % averaging
        y_5min=read_bor(fullfile(folder5min,s(i).name)); 
        y_30min=read_bor(fullfile(folder30min,s(i).name));
        figure(1)
        clf
        plot(tv_5min,y_5min,'-og',tv_5min(ind1),y_5min(ind1),'ob',tv_30min,y_30min,'-or')
        title(s(i).name,'Interpreter', 'none');
        
        pause
    end
end