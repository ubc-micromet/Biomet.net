function db_hhour_copy(yearRange)

% Revisions:
% Jul 9, 2020 (Pat)
%   - Added LGR1_UPPER site
% Apr 24, 2020 (Zoran)
%   - Removed decomissioned sites PA, BS
% Apr 22, 2020 (Zoran)
%   - had to fix: lastTime = datenum(char(x{end,1})); 
%     It had regular brackets instead of curly ones (textscan returns cell
%     arrays)
% Jan 17, 2020 (Zoran)
%   - Replaced all appearances of "Now" with "now" to solve case
%   sensitivity issue with the newer versions of Matlab
%   - replaced textread with textscan for the same reason
% Nov 14, 2019 (Zoran)
%   - added parameter yearRange so that a specific year(s) can be copied
% Jul 14, 2018 (Zoran)
%   - added LGR2 site
% Jan 15, 2018 (Pat/Zoran)
%   - added LGR1 site
% Jan 26, 2017 (Zoran)
% 	- removed hard coded path to HFREQ data to the default path db_HFREQ_root
% Jan 19, 2016
%   - removed HP09 from site site
% April 27, 2015
%   - new server for HF data: biomet01
% Jan 21, 2014
%   -copying for the previous year turned off. Only the current year copied
%   from now on.
% Jan 6, 2013 (Zoran)
%   - Added a catch statement when reading lastTime.
% Nov 23, 2011
%	- added HP11 (Nick)
% July 8, 2011
%  - stop doing the previous year on every run.
%  - added HDF11, new eddy file copy for PA and BS
% October 26, 2010
%   -added copy for MPB4, HP09
% May 17, 2010
%   -added copy for MPB1, MPB2, MPB3
% Dec 5, 2008
%   -added copy for HJP94
% Oct 17, 2008
%   -added xcopy of ACS .mat files from CR to Annex001 (Nick)
% Jan 7, 2008
%   -removed hard coding of database path ( 'y:\' ) so that it is now
%       assigned by a call to db_pth_root (Nick)
% July 3, 2007 
%   -revised test for doing update to now-lastTime >= 1-1/24 to stop the update
%       of the log file from moving 1 hour each day! (Nick)

try
	%x = textread('D:\met-data\log\last_run_of_hhour_copy.log','%s','whitespace','\b\t');
    fid1=fopen('D:\met-data\log\last_run_of_hhour_copy.log');
    x = textscan(fid1,'%s','whitespace','\b\t');
    fclose(fid1);
	lastTime = datenum(char(x{end,1}));
catch %#ok<*CTCH>
    lastTime = datenum(2000,1,1);
end

if ~exist('yearRange','var') | isempty(yearRange) %#ok<*OR2>
	dateVec = datevec(now);
    yearRange= dateVec(1)-1:dateVec(1);
else
    dateVec = yearRange;
end

%if now - lastTime > 1
if now - lastTime >= 1-1/24  % July 3, 2007: Nick changed

	for YearX = yearRange
    %for YearX = dateVec(1) % stop doing the previous year on every run, Nick July 8, 2011
        strYear = num2str(YearX);
        
        pth_db = db_pth_root; % Jan 7, 2008: Nick added
 
                
        % LGR1 
        pthHH_db = [pth_db strYear '\LGR1\hhour_database'];
        cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log'];
        dos(cmdStr);fprintf('%s\n',cmdStr);
        cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log'];
        dos(cmdStr);fprintf('%s\n',cmdStr); 
        cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_LGR1\met-data\hhour\' strYear(3:4) '????.hLGR1.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
        [junk,junk]=dos(cmdStr);fprintf('%s\n',cmdStr); 
        
        % LGR1_upper
        pthHH_db = [pth_db strYear '\LGR1_UPPER\hhour_database'];
        cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log'];
        dos(cmdStr);fprintf('%s\n',cmdStr);
        cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log'];
        dos(cmdStr);fprintf('%s\n',cmdStr); 
        cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_LGR1_UPPER\met-data\hhour\' strYear(3:4) '????.hSonicCal.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
        [junk,junk]=dos(cmdStr);fprintf('%s\n',cmdStr);
        
        % LGR2 
        pthHH_db = [pth_db strYear '\LGR2\hhour_database'];
        cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log'];
        dos(cmdStr);fprintf('%s\n',cmdStr); 
        cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log'];
        dos(cmdStr);fprintf('%s\n',cmdStr); 
        cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_LGR2\met-data\hhour\' strYear(3:4) '????.hLGR2.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
        [junk,junk]=dos(cmdStr);fprintf('%s\n',cmdStr); 
        
%         % BS
%         pthHH_db = [pth_db strYear '\bs\hhour_database']; % Jan 7, 2008: parsing of all paths now uses pth_db instead of hard-coded ('y:\') 
%         cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log'];
%         dos(cmdStr);fprintf('%s\n',cmdStr); 
%         cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log'];
%         dos(cmdStr);fprintf('%s\n',cmdStr); 
%         cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_BS\met-data\hhour\' strYear(3:4) '????.hb.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         [junk,junk]=dos(cmdStr);fprintf('%s\n',cmdStr); 
%         cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_BS\met-data\hhour\' strYear(3:4) '????.hb_ch.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         [junk,junk]=dos(cmdStr);fprintf('%s\n',cmdStr); fprintf('%s\n',cmdStr); %#ok<*ASGLU>
%         % for new eddy files
%         cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_BS\met-data\hhour\' strYear(3:4) '????.hBS.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         [junk,junk]=dos(cmdStr);fprintf('%s\n',cmdStr); 
        
        % CR 
%         pthHH_db = [pth_db strYear '\cr\hhour_database'];
%         cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['xcopy \\fluxnet02\HFREQ_CR\met-data\hhour\' strYear(3:4) '????.hc.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)
%         cmdStr = ['xcopy \\fluxnet02\HFREQ_CR\met-data\hhour\' strYear(3:4) '????s.hc_ch.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)
%         cmdStr = ['xcopy \\Fluxnet02\HFREQ_CR\MET-DATA\acs-dc\MET-DATA\hhour\' strYear(3:4) '*.ACS_Flux_CR16.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)
        
        
        % HDF11 (CR clearcut site)
        %pthHH_db = [pth_db strYear '\HDF11\hhour_database'];
        %cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log']
        %dos(cmdStr)
        %cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log']
        %dos(cmdStr)
        %cmdStr = ['xcopy \\biomet01\HFREQ_HDF11\met-data\hhour\' strYear(3:4) '????.hHDF11.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
        %dos(cmdStr)
        %cmdStr = ['xcopy \\biomet01\HFREQ_HDF11\met-data\hhour\' strYear(3:4) '????.TallTowerSonic.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
        %dos(cmdStr)
%         cmdStr = ['xcopy \\fluxnet02\HFREQ_HDF11\met-data\hhour\' strYear(3:4) '????s.hc_ch.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)
%        cmdStr = ['xcopy \\Fluxnet02\HFREQ_HDF11\MET-DATA\acs-dc\MET-DATA\hhour\' strYear(3:4) '*.ACS_Flux_CR16.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
 %       dos(cmdStr)
        
        % HJP02
%         pthHH_db = [pth_db strYear '\hjp02\hhour_database'];
%         cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['xcopy \\fluxnet02\HFREQ_HJP02\met-data\hhour\' strYear(3:4) '????.hHJP02.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)
        
        % HJP75
%         pthHH_db = [pth_db strYear '\hjp75\hhour_database'];
%         cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['xcopy \\fluxnet02\HFREQ_HJP75\met-data\hhour\' strYear(3:4) '????.hHJP75.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)
                
        % HJP94
%         pthHH_db = [pth_db strYear '\hjp94\hhour_database'];
%         cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['xcopy \\fluxnet02\HFREQ_HJP94\met-data\hhour\' strYear(3:4) '????.hHJP94.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)
        
        
        % OY
%         pthHH_db = [pth_db strYear '\oy\hhour_database'];
%         cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['xcopy \\fluxnet02\HFREQ_OY\met-data\hhour\' strYear(3:4) '????.hoy.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)
        
%         % PA 
%         pthHH_db = [pth_db strYear '\pa\hhour_database'];
%         cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log'];
%         dos(cmdStr);fprintf('%s\n',cmdStr); 
%         cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log'];
%         dos(cmdStr);fprintf('%s\n',cmdStr); 
%         cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_PA\met-data\hhour\' strYear(3:4) '????.hp.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         [junk,junk]=dos(cmdStr);fprintf('%s\n',cmdStr); fprintf('%s\n',cmdStr); %#ok<*NASGU>
%         cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_PA\met-data\hhour\' strYear(3:4) '????.hp_ch.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         [junk,junk]=dos(cmdStr);fprintf('%s\n',cmdStr); 
%         % for new eddy files
%         cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_PA\met-data\hhour\' strYear(3:4) '????.hPA.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         [junk,junk]=dos(cmdStr);fprintf('%s\n',cmdStr); 
        
        
        % YF
        pthHH_db = [pth_db strYear '\yf\hhour_database'];
        cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log'];
        dos(cmdStr);fprintf('%s\n',cmdStr); 
        cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log'];
        dos(cmdStr);fprintf('%s\n',cmdStr); 
        cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_YF\met-data\hhour\' strYear(3:4) '????.hy.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
        [junk,junk]=dos(cmdStr);fprintf('%s\n',cmdStr); 
        cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_YF\met-data\hhour\' strYear(3:4) '????.hy_ch.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
        [junk,junk]=dos(cmdStr);fprintf('%s\n',cmdStr); 
        
        % MPB1
        pthHH_db = [pth_db strYear '\mpb1\hhour_database'];
        cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log'];
        dos(cmdStr);fprintf('%s\n',cmdStr); 
        cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log'];
        dos(cmdStr);fprintf('%s\n',cmdStr); 
        cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_MPB1\met-data\hhour\' strYear(3:4) '????.hMPB1.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
        [junk,junk]=dos(cmdStr);fprintf('%s\n',cmdStr); 
        
        % MPB2
%         pthHH_db = [pth_db strYear '\mpb2\hhour_database'];
%         cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['xcopy \\fluxnet02\HFREQ_MPB2\met-data\hhour\' strYear(3:4) '????.hMPB2.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)
        
        % MPB3
%         pthHH_db = [pth_db strYear '\mpb3\hhour_database'];
%         cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['xcopy \\fluxnet02\HFREQ_MPB3\met-data\hhour\' strYear(3:4) '????.hMPB3.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)
        
        % MPB4
%         pthHH_db = [pth_db strYear '\mpb4\hhour_database'];
%         cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['xcopy \\fluxnet02\HFREQ_MPB4\met-data\hhour\' strYear(3:4) '????.hMPB4.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)
        
        % HP09
%         pthHH_db = [pth_db strYear '\hp09\hhour_database'];
%         cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['xcopy \\biomet01\HFREQ_HP09\met-data\hhour\' strYear(3:4) '????.hHP09.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)
        
%         % HP11
%         pthHH_db = [pth_db strYear '\hp11\hhour_database'];
%         cmdStr = ['echo ========================================================================================      >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['echo ' datestr(now) ' >' '> ' pthHH_db '\hhour_copy.log']
%         dos(cmdStr)
%         cmdStr = ['xcopy ' db_HFREQ_root 'HFREQ_HP11\met-data\hhour\' strYear(3:4) '????.hHP11.mat ' pthHH_db '  /D /F /Y >' '> ' pthHH_db '\hhour_copy.log' ];
%         dos(cmdStr)

                
	end
	fid = fopen('D:\met-data\log\last_run_of_hhour_copy.log','wt');
	fprintf(fid,'%s',datestr(now));
	fclose(fid);
end