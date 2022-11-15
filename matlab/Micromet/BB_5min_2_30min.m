function k = BB_5min_2_30min(yearX,siteID)
% k = BB_5min_2_30min(yearX,siteID) - convert 5-minute BB database data into 30-min database
%
% Zoran Nesic               File created:       Oct 20, 2019
%                           Last modification:  Oct 20, 2019
%

% Revisions (newest first)
% December 5, 2019 (Sara K)
%   - Added vector averaging for wind speed and direction


% create paths
pthDbase = db_pth_root;
folder5min = fullfile(pthDbase,num2str(yearX),siteID,'Met\5min');
folder30min = fullfile(pthDbase,num2str(yearX),siteID,'Met');

% load the 5-min time vectors convert it to 30-min time vector and save
tv_5min = read_bor(fullfile(folder5min,'clean_tv'),8);
tv_30min = tv_5min(6:6:end);
% due to some legacy issues, two identical time vector are stored.
foo = save_bor(fullfile(folder30min,'clean_tv'),8,tv_30min);
foo = save_bor(fullfile(folder30min,'TimeVector'),8,tv_30min);

% for the rest of the conversions, cycle through all other files in the
% 5min folder, average 6 points to get 30min averages and store the results
% with the same names into the 30 minute folder
s = dir(folder5min);
fprintf('Processing folder: %s.  %d files and folder found.\n',folder5min,length(s));
k = 0;
for i=1:length(s)
    if ~s(i).isdir && ~strcmpi(s(i).name,'clean_tv') && ~strcmpi(s(i).name,'timevector')
        % for all items that are not folder or are time vectors, do the
        % averaging
        x=read_bor(fullfile(folder5min,s(i).name));
        [y,cnt] = fastavg(x,6);
        if strcmpi(s(i).name,'met_raintips_tot')
            % special case -> for tipping bucket don't average, total
            % instead.
            y = y.*cnt;
        elseif strcmpi(s(i).name,'MET_Young_WS_WVc1')
            % Since vectors, need to calculate vector average for WS and WD
            y = vector_avg(s,folder5min);
        elseif strcmpi(s(i).name,'MET_Young_WS_WVc2')
            % Since vectors, need to calculate vector average for WS and WD
            [~,y] = vector_avg(s,folder5min);
        end
        foo = save_bor(fullfile(folder30min,s(i).name),1,y);
        k = k+1;
        %fprintf('%02d: %s\n',k,s(i).name);
    end
end
fprintf('Converted %d 5-minute files into 30-minute files.\n', k);
return
