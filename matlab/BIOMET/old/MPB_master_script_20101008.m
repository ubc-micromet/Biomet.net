function MPB_master_script(sites);
%% MPB master script: ftp transfer, flux calc, archive, and clean

% file created: Feb 19, 2010
% created by: Nick, Zoran and Mat

dv = datevec(now);
arg_default('sites',{'MPB1' 'MPB2' 'MPB3' 'MPB4'});
arg_default('years',unique(dv(1)));

%---------------------------------------------------------------
% Schematic of data flow from MoFR to UBC and processing at UBC
%---------------------------------------------------------------

% BCMoFR FTP server
%        |
%        | (1) FTP transfer
%        |
% Fluxnet02 (cal lab PC)
%        |
%        | (2. LoggerNet/cardconvert)
%        | (3. ascii--binary conversion)
%        |
% Fluxnet02 \met-data\data\yymmdd --------> backup to Dom's data PC
%        |                                   (E:\data_dump\siteId
%        |  (4. daily flux calculation:          |
%        |      new_calc_and_save                | (burn DVD)
%        |                                   archive
% Fluxnet02 \met-data\hhour-------->|
%        |                          |(5a. db_hhour copy called from db_update_all)
%        |                          |
%        |                       archive on Annex001 \yyyy\siteId\hhour_database
%        |                                     
%        | (5b. extract traces: db_update_hhour_database called from db_update_all
%        |
% Annex001 \yyyy\siteId\Flux\
%        |
%        | (5c. cleaning: first, second, third stages
%        |   fr_automated_cleaning called from db_update_all
%        |
% Annex001 \yyyy\siteId\Flux\clean
% Annex001 \yyyy\siteId\Flux\clean\secondstage
% Annex001 \yyyy\siteId\Flux\clean\thirdstage

% path to MPB sites to sites data folders
%pth_MPB = 'D:\Nick\matlab\db_functions\MPB\MPB_sites\';

pth_MPB = 'I:\';

% FTP setup (old MoFR)
% mofFTPsite = 'ftp.for.gov.bc.ca';
% ftpFolderName = '/RNI/external/outgoing/UBC/';

%New FTP site data is uploaded to

mofFTPsite = 'annex001.landfood.ubc.ca';
ftpFolderName = '/Public/MPB_Sites/';
usrnm = 'Rebecca';
pswd = 'unbcubc';

%FTP testing setup
% mofFTPsite = 'paoa003.agsci.ubc.ca';
% defaultIncomingPath = 'D:\Nick\matlab\db_functions\MPB\FTP_data\';
% ftpFolderName = '/BIOMET/mpb_test';

% main loop
for i=1:length(sites)
    siteId = sites{i};
    fr_set_site(siteId,'n');
    c = fr_get_init(siteId,now); 
    defaultIncomingPath = ['I:\' char(sites{i}) '\raw\'];

	%------------------------------------------------------------------------
	% 1. FTP transfer from BCMoFR FTP server in Prince George
	% -Fluxnet02 to serve as the entry point  (NICK will rework ZORAN's
	% code)
	%------------------------------------------------------------------------

	% Zoran's ftp script retooled to generate a progressList.mat file for each site
	% Takes as input 
	%                   -siteId, 
	%                   -c.ECloggerSN (set in the init_all file

	% -checks to make sure files with the expected logger SN are in the FTP directory for
	% specified MPB site

	% copy files to UBC

	% removes files from MoFR if ftp transfer was successful, and notifies users
	% that the transfer was successful/unsuccessful and whether extra files exist 
	% which were not copied over
    
    switch siteId
        case 'MPB1'
           nCR5000=1;
        case 'MPB2'
           nCR5000=1;
        case 'MPB3'
           nCR5000=1;
        case 'MPB4'
           nCR5000=1;
    end
    pth_data = fullfile(pth_MPB,siteId,'\met-data\data\');
    curdir = pwd;
    [pthHF,fnHF] = MPB_FTP_transfer(siteId,c.Instrument(nCR5000).SerNum,mofFTPsite,defaultIncomingPath,ftpFolderName,usrnm,pswd);
    cd(curdir);
    
    fnHF = dir(fullfile(pthHF,[num2str(c.Instrument(nCR5000).SerNum) '.RawHF.dat']));
    %if fnHF.bytes < 1.9e9
    if fnHF.bytes < 1.0e9
      disp(['**** FTP transfer for ' siteId ' may have been interupted *****' ]);
      disp(['****        Rerun FTP transfer for ' siteId '           *****' ]);
    else   
      disp(['**** FTP transfer of HF data complete for ' siteId ' *****' ]);
      disp(['****        Run CardConvert for ' siteId '           *****' ]);
    end
      
    
end % main loop