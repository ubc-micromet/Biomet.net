% testing new csv files vs. csv files created by Andreas Christen
% Written for matlab 2018

% create paths
newCSV_path = 'P:\Micromet_web\www\webdata\resources\csv\';
oldCSV_path = 'P:\Micromet_web\www\webdata\resources\csv_epicc\';

% Identify files
d_new = dir([newCSV_path '*.csv']);
FileNames_new = {d_new.name}';

d_old = dir([oldCSV_path '*.csv']);
FileNames_old = {d_old.name}';

[c,iNew,iOld] = intersect(FileNames_new,FileNames_old);

fig = 0;
for i = 1:length(iNew)
    
    % New csv files
    % Identify column headers since not being identified properly in
    % readtable
    Data = fileread([newCSV_path FileNames_new{iNew(i)}]);
    DataC = strsplit(Data, '\n');
    Headers = strsplit(char(DataC{1}),',');
    Headers = Headers(1:end-1);
    Headers = regexprep(Headers, {' ','(',')','[',']','-'}, '_');
    Headers = strrep(Headers, '.', '_');
    
    % Load data
    newData = readtable([newCSV_path FileNames_new{iNew(i)}],'Delimiter',',','HeaderLines',1);
    newData.Properties.VariableNames = Headers;
    
    % Old csv files
    % Identify column headers since not being identified properly in
    % readtable
    Data = fileread([oldCSV_path FileNames_old{iOld(i)}]);
    DataC = strsplit(Data, '\n');
    Headers = strsplit(char(DataC{1}),',');
    Headers = Headers(1:end);
    Headers = regexprep(Headers, {' ','(',')','[',']','-'}, '_');
    Headers = strrep(Headers, '.', '_');
    
    % Load data
    oldData = readtable([oldCSV_path FileNames_old{iOld(i)}],'Delimiter',',','HeaderLines',1);
    oldData.Properties.VariableNames = Headers;
    
    [c,in,io] = intersect(newData.Properties.VariableNames,oldData.Properties.VariableNames,'stable');
    
    for j = in(2):in(end)
        
        % For some files readtable does not recognize the data as numeric, in
        % that case force to numeric
        if ~isnumeric(table2array(oldData(:,io(j))))
            var = [];
            for ii = 1:size(oldData(:,io(j)),1)
                var = [var, str2double(table2array(oldData(ii,io(j))))];
            end
            
            oldData(:,io(j)) = [];
            oldData(:,io(j)) = table(var');
            oldData.Properties.VariableNames = Headers;
        end
        
        fig = fig+1;
        figure(fig)
        subplot(2,1,1)
        plot(datetime(table2array(newData(:,1))),table2array(newData(:,in(j))),'o-')
        hold on
        plot(datetime(table2array(oldData(:,1))),table2array(oldData(:,io(j))),'o-')
        legend('New web plot','Old web plot','Location', 'Best'); legend boxoff
        title(regexprep(newData.Properties.VariableNames(j),'_',' '))
        
        [c,inew,iold] = intersect(datetime(table2array(newData(:,1))),datetime(table2array(oldData(:,1))));
        
        subplot(2,1,2)
        plot(table2array(oldData(iold,io(j))),table2array(newData(inew,in(j))),'.')
        ylabel('New web plot'); xlabel('Old web plot')
        title(regexprep(newData.Properties.VariableNames(j),'_',' '))
    end
end

% Exploration into WD issue (i = 22);
% ind_exl = newData.Wind_Direction_Cup_Anemometer__5_00m_ < 0.001 | newData.Wind_Direction_Cup_Anemometer__5_00m_ > 359.999;
% newData.Wind_Direction_Cup_Anemometer__5_00m_(ind_exl) = NaN;
% [c,inew,iold] = intersect(datetime(table2array(newData(:,1))),datetime(table2array(oldData(:,1))));
% 
% figure
% plot(oldData.Time__PST_(iold), oldData.Wind_Direction_Cup_Anemometer__5_00m_(iold))
% hold on
% plot(newData.Time__PST_(inew), newData.Wind_Direction_Cup_Anemometer__5_00m_(inew))
% legend('old','new')
% 
% figure
% plot(oldData.Wind_Direction_Cup_Anemometer__5_00m_(iold), newData.Wind_Direction_Cup_Anemometer__5_00m_(inew),'.')
% 

% calculating average wind vector
% for i=1:length(s)
%     if ~s(i).isdir && ~strcmpi(s(i).name,'clean_tv') && ~strcmpi(s(i).name,'timevector')
%         % for all items that are not folder or are time vectors, do the
%         % averaging
%         x=read_bor(fullfile(folder5min,s(i).name));
%         [y,cnt] = fastavg(x,6);
%         if strcmpi(s(i).name,'met_raintips_tot')
%             % special case -> for tipping bucket don't average, total
%             % instead.
%             y = y.*cnt;
%         elseif strcmpi(s(i).name,'MET_Young_WS_WVc1')
%             % Since vectors, need to calculate vector average for WS and WD
%             y = vector_avg(s,folder5min);
%         elseif strcmpi(s(i).name,'MET_Young_WS_WVc2')
%             % Since vectors, need to calculate vector average for WS and WD
%             [~,y] = vector_avg(s,folder5min);
%         end
%         foo = save_bor(fullfile(folder30min,s(i).name),1,y);
%         k = k+1;
%         %fprintf('%02d: %s\n',k,s(i).name);
%     end
% end
% fprintf('Converted %d 5-minute files into 30-minute files.\n', k);

