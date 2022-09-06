function [pthHF, fnHF] = MPB_FTP_transfer(siteId,loggerSN,mofFTPsite,defaultIncomingPath,ftpFolderName,usrnm,pswd);

% May 21, 2010
%   - added username/password functionality (Nick)


%mofFTPsite = 'ftp.for.gov.bc.ca';
%mofFTPsite = 'paoa003.agsci.ubc.ca';

currentSite = siteId;
currentSiteLoggerID = loggerSN;
[pthHF, fnHF]=downloadOneSite(mofFTPsite,currentSite,currentSiteLoggerID,ftpFolderName,defaultIncomingPath,usrnm,pswd);

%currentSite = 'MPB2';
%currentSiteLoggerID = 1111;
%downloadOneSite(mofFTPsite,currentSite,currentSiteLoggerID,ftpFolderName,defaultIncomingPath);

% currentSite = 'MPB2';
% currentSiteLoggerID = 6377;
% downloadOneSite(mofFTPsite,currentSite,currentSiteLoggerID,ftpFolderName,defaultIncomingPath);
	 
	 
% Core function for downloading of one MPB site at a time
function [pthHF, fnHF]=downloadOneSite(mofFTPsite,currentSite,currentSiteLoggerID,ftpFolderName,defaultIncomingPath,usrnm,pswd)

folderName = datestr(now,30);

if isempty(usrnm) & isempty(pswd)
   mpb_ftp = ftp(mofFTPsite); % open FTP server
else
   mpb_ftp = ftp(mofFTPsite,usrnm,pswd); % ftp server with username and password access
end

try
    cd(mpb_ftp, '/' );
    %cd(mpb_ftp,fullfile(ftpFolderName,currentSite));
    cd(mpb_ftp,[ftpFolderName '/' currentSite]);
    %
    % for testing at UBC
    % cd(mpb_ftp,['./biomet/mpb_test/' currentSite]);

    try
        cd(defaultIncomingPath);
        mkdir(folderName);
        cd(folderName);
        pthHF = pwd;
    end
    
    %cd (fullfile(defaultIncomingPath,currentSite,folderName))
    %s=dir(mpb_ftp,[ '.' ]);

    lst = dir(mpb_ftp,[num2str(currentSiteLoggerID) '.*.dat']);
    lst_HFfn = {lst.name}';
    ftperr = 0;
    for i=1:length(lst_HFfn)
        %mget(mpb_ftp,[num2str(currentSiteLoggerID) '.flux_30m.*']);
        try
            disp( '---------------------------------------------')
            disp(['transferring ' char(lst_HFfn{i}) ' ...'])
            disp( '---------------------------------------------')
            mget(mpb_ftp,char(lst_HFfn{i})); % transfer file
        catch
            ftperr = 1;
            disp( '---------------------------------------------')
            disp(['FTP transfer failed for ' char(lst_HFfn{i})])
            disp( '---------------------------------------------')
            fnHF = [];
        end
        if ~ftperr
            oldfn = char(lst_HFfn{i});
            newfn = [oldfn(1:end-4) '.' folderName];
            rename(mpb_ftp,oldfn,newfn); 
            if ~isempty(strfind(newfn,'RawHF'))
                pthHF = fullfile(defaultIncomingPath,folderName);
                fnHF = oldfn;
            end
        end
        ftperr=0;
    end
    
catch
    % error in ftp transfer or no data to start with
    disp( '-------------------')
    disp(['No new ' currentSite ' data!'])
    disp( '-------------------')
    pthHF = pwd;
    fnHF = [];
end

%
close(mpb_ftp)