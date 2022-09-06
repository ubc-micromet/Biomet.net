function run_transfer_and_recalc_Shell_Quest(year,siteId,no_days_back);

% downloads and unzips 7zip archive files from the past N days from the Shell FTP server
% that have not already been downloaded. Keeps track using a progress list
% .mat file

processProgressListPath = ['D:\recalcs\ShellQuest\' siteId '\ubc_flux\FTP_winscp\' siteId '_' num2str(year) '_ZipFilesTransferred.mat'];

if exist(processProgressListPath,'file')
    load(processProgressListPath,'filesProcessProgressList');
else
    filesProcessProgressList = [];
end

% build a list of files that could be downloaded and check against the list

N=no_days_back; % see if any files still remain to be downloaded from the past 20 days

lstfn = [];
for i=1:N
    timstr = FR_Datetofilename(now-(i-1));
    timstr = [ '20' timstr(1:6) ];
    fntmp = [ 'ShellQuest_' timstr '.7z' ];
    lstfn = [ lstfn; fntmp ];
end
lstfn=cellstr(lstfn);

filesToDownload = [];
for k=1:N
 j = findFileInProgressList(lstfn(k),filesProcessProgressList);
  % if it doesn't exist add a new value
  if j > length(filesProcessProgressList)
        filesToDownload = [filesToDownload; lstfn(k)];
  end
end

base_dir = 'D:\recalcs\ShellQuest\';
pth_raw = fullfile(base_dir,siteId,'raw');
pth_zip = fullfile(pth_raw,'zip');
pth_data = fullfile(base_dir,siteId,'met-data\data');

% Extracts and archives Shell Quest data files, and removes zip file if successful

for i=1:length(filesToDownload)
        fnstr = char(filesToDownload(i));
        % get the daily zip file from the Shell FTP server
		ftpCmdStr = ['winscp_ShellQuest  ' fnstr ' ' pth_zip '\' ];
		disp(ftpCmdStr);
		dos(ftpCmdStr);
        
        % extract the .csv file to the zip folder
        dosCmdStr = ['unzip_Shell  ' fullfile(pth_zip,fnstr) ' ' pth_zip ];
        disp(dosCmdStr);
        dos(dosCmdStr);
        
        % split the .csv file into hhour HF files stored in
        % met-data\data\yymmdd
        dailyFileName = fullfile(pth_zip,[fnstr(1:end-3) '.csv']);
        ErrorStatus = ShellFileSplit(dailyFileName,pth_data);
        filesProcessProgressList = [ filesProcessProgressList; fnstr ]; % transferred so add it to the Progress List
        if ~ErrorStatus % if file split successful, delete the .csv file and keep the zip
            delcmd=[ 'del ' dailyFileName ];
            disp(delcmd);
            dos(delcmd); % delete the .csv file
            date_HF(i,1:6)=fnstr(14:end-3); % record the HF folder name (yymmdd) for the flux calc
        end
end

if ~exist('date_HF','var')
    disp('...No files found...exiting.');
    return % no dates to process
else
    date_HF = cellstr(date_HF);
    filesProcessProgressList=cellstr(filesProcessProgressList);
    save(processProgressListPath,'filesProcessProgressList');

    % run the flux calculations on the days just extracted
    pth_old = path;
    fr_set_site(siteId,'n');
    [dataPth,hhourPth,databasePth,csiPth] = FR_get_local_path;
    pth_calc = fullfile(base_dir,siteId);
    if exist('date_HF','var')
        calc_date = [];
        for i=1:length(date_HF)
            if length(char(date_HF{i}))==6
                yymmdd = (char(date_HF{i}));
                yy = yymmdd(1:2);
                yyyy = str2num(['20' yy]);
                mm = str2num(yymmdd(3:4));
                dd = str2num(yymmdd(5:6));
                calc_date = [calc_date; datenum(yyyy,mm,dd)];
            end
        end
        calc_date=sort(calc_date);
        recalc_create_for_mpb(siteId,year,pth_calc);
        recalc_configure_for_mpb(pth_calc);
        new_calc_and_save(calc_date(1):calc_date(end),siteId);
        path(pth_old);
    end
end

function ind = findFileInProgressList(fileName,filesProcessProgressList);

ind = [];
for j = 1:length(filesProcessProgressList)
  if strcmp(fileName,filesProcessProgressList(j))
   ind = j;
   break
   end %  if strcmp(fileName,filesProcessProgressList(j).Name)
end % for j = 1:length(filesProcessProgressList)
if isempty(ind)
   ind = length(filesProcessProgressList)+1;
end 