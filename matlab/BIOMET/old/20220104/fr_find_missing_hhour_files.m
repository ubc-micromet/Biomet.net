function [flist_sfile,flist_lgfile,flist_chsfile,flist_chlfile] = fr_find_missing_hhour_files(siteID,year);

% -checks for missing short/long files for which HF data exists
%   called from 'run_hhour_file_search' which checks for missing files
%   for all sites for the current year and e-mails the logfile to the
%   db_admins and tech staff.

% file created: September 28, 2007          last modified: Oct 10/2007
% created by :  Nick

% Revisions:
%   October 10, 2007
%       -Nick changed the long file path to check on
%       \\Fluxnet02\HFREQ-siteID\met-data\hhour

switch upper(siteID)
    case 'CR', pth_short = '\\paoa001\Sites\cr\hhour\';  pth_HF = '\\Fluxnet02\HFREQ_CR\met-data\data\'; 
        fileExt_sh = 's.hc.mat'; fileExt_lg = '.hc.mat'; fileExt_chs = 's.hc_ch.mat'; fileExt_chl = '.hc_ch.mat';
        hf_sonmin = 2.5e5; hf_limin = 1e6; fileExt_li = '.DC2'; fileExt_son = '.DC1';
    case 'PA', pth_short = '\\paoa001\Sites\paoa\hhour\';  pth_HF = '\\Fluxnet02\HFREQ_OA\met-data\data\'; 
        fileExt_sh = 's.hp.mat'; fileExt_lg = '.hp.mat'; fileExt_chs = 's.hp_ch.mat'; fileExt_chl = '.hp_ch.mat';
        hf_sonmin = 900; hf_limin = 1e6; fileExt_li = '.DP2'; fileExt_son = '.GP2';
    case 'BS', pth_short = '\\paoa001\Sites\PAOB\hhour\';  pth_HF = '\\Fluxnet02\HFREQ_BS\met-data\data\'; 
        fileExt_sh = 's.hb.mat'; fileExt_lg = '.hb.mat'; fileExt_chs = 's.hb_ch.mat' ; fileExt_chl = '.hb_ch.mat' ;
        hf_sonmin = 900; hf_limin = 1e6; fileExt_li = '.DB2'; fileExt_son = '.GB2';
    case 'YF', pth_short = ['\\PAOA001\Sites\' siteID '\hhour\' ]; pth_HF = '\\Fluxnet02\HFREQ_YF\met-data\data\';
        fileExt_sh = 's.hy.mat'; fileExt_lg = '.hy.mat'; fileExt_chs = 's.hy_ch.mat'; fileExt_chl = '.hy_ch.mat';
        hf_sonmin = 2e5; hf_limin = 2e5; fileExt_li = '.DY5'; fileExt_son = '.DY3';
    case 'OY', pth_short = ['\\PAOA001\Sites\' siteID '\hhour\' ]; pth_HF = '\\Fluxnet02\HFREQ_OY\met-data\data\';
        fileExt_sh = 's.hOY.mat'; fileExt_lg = '.hOY.mat';
        hf_sonmin = 5e5; fileExt_son = '.DO3';
    case 'HJP02', pth_short = ['\\PAOA001\Sites\' siteID '\hhour\' ]; pth_HF = '\\Fluxnet02\HFREQ_HJP02\met-data\data\';
         fileExt_sh = 's.hHJP02.mat'; fileExt_lg = '.hHJP02.mat';
         hf_sonmin = 2e5; hf_licmin = 2e5; fileExt_li = '.DH5'; fileExt_son = '.DH4';
end
fileExt_dcom = '.bin'; dcom_min = 1e6;
%pth_long = fullfile(biomet_path(year,siteID),'hhour_database');
pth_long = [ '\\Fluxnet02\HFREQ_' upper(siteID) '\met-data\hhour\'];
tv       = read_bor(fullfile(biomet_path(year,siteID),'Climate\Clean\clean_tv'),8);

% open a new log file
flog = fopen('biomet_missing_hhour_report.log','a');
fprintf(flog,'======================== .MAT files search results for %s %s ==========================  \n',siteID,num2str(year));
disp(sprintf('======================== .MAT files search results for %s %s ========================== ',siteID,num2str(year)));

% first check for missing hhour files on PAOA001 (short) and 
%   on Annex001 (long)

dv_now = datevec(now);
if dv_now(1) == year
    ind_check = find(tv<now);
    tv = tv(ind_check);
    tv       = tv(12:48:end); % 
else
    tv       = tv(12:48:end); % shorten to 365 days, that's all we need
end
flist = [];
for i=1:length(tv)
    fn = FR_Datetofilename(tv(i));
    fn = {fn(1:6)};
    flist = [ flist; fn ];
end

flist = unique(flist);
flist_ecl = flist;
flist_ecs = flist;
flist_chs = flist;
flist_chl = flist;

% generate a list of filenames for the entire year and check
% against what exists in those directories

for j=1:length(flist)  
    flist_ecs(j) = cellstr([ char(flist(j)) fileExt_sh ]);
    flist_ecl(j) = cellstr([ char(flist(j)) fileExt_lg ]);
    if exist('fileExt_chs')
      flist_chs(j) = cellstr([ char(flist(j)) fileExt_chs ]);
      flist_chl(j) = cellstr([ char(flist(j)) fileExt_chl ]);
    end
end

% flist = [flist_ch; flist_ecs; flist_ecl];

flist_pc = dir(fullfile(pth_short,['*' fileExt_sh ]));
flist_pc = {flist_pc.name};
disp('....Compiling list of missing short files...');
flist_yr = intersect(flist_ecs,flist_pc);
flist_sfile = setdiff(flist_ecs,flist_yr);

flist_pc = dir(fullfile(pth_long,['*' fileExt_lg ]));
flist_pc = {flist_pc.name};
disp('....Compiling list of missing long files...');
flist_yr = intersect(flist_ecl,flist_pc);
flist_lgfile = setdiff(flist_ecl,flist_yr);

% take the remaining days with missing short and/or long hhour files
% and look for HF data on \\Fluxnet02\

%flist_sfile = flist_sfile(:);
flist_lgfile = flist_lgfile(:);
%flist_chk = [flist_sfile; flist_lgfile];
flist_chk = flist_lgfile;
for k=1:length(flist_chk)
    fn = char(flist_chk{k});
    flist_chk(k) = cellstr(fn(1:6));
end
flist_chk = unique(flist_chk);

% check HF file sizes against the minimums expected for normal operation
ind_HF = [];
disp('....Checking for HF data...');
for j=1:length(flist_chk) 
    ind_li   = [];
    ind_son  = [];
    ind_dcom = [];
    if isdir([pth_HF char(flist_chk(j))])
        if exist('fileExt_li')
           flist_li =  dir(fullfile(pth_HF,char(flist_chk(j)),['*' fileExt_li]));
        end
        if exist('fileExt_son')
           flist_son = dir(fullfile(pth_HF,char(flist_chk(j)),['*' fileExt_son]));
        end
        flist_dcom = dir(fullfile(pth_HF,char(flist_chk(j)),['*' fileExt_dcom]));
        if exist('flist_li')
           flist_li = [flist_li.bytes];
           ind_li = find(flist_li >= hf_limin);
        end
        if exist('flist_son')
           flist_son = [flist_son.bytes];
           ind_son = find(flist_son >= hf_sonmin);
        end
        if exist('flist_dcom')
           flist_dcom = [flist_dcom.bytes];
           ind_dcom = find(flist_dcom >= dcom_min);
        end
        if ~isempty(ind_li) | ~isempty(ind_son) | ~isempty(ind_dcom)
            ind_HF = [ ind_HF j ];
        end
    else
        continue
    end
end
flist_chk = flist_chk(ind_HF);

if exist('fileExt_chs')
    flist_pc = dir(fullfile(pth_short,['*' fileExt_chs ]));
    flist_pc = {flist_pc.name};
    disp('....Compiling list of missing chamber files...');
    flist_yr = intersect(flist_chs,flist_pc);
    flist_chsfile = setdiff(flist_chs,flist_yr); 
end

if exist('fileExt_chl')
    flist_pc = dir(fullfile(pth_long,['*' fileExt_chl ]));
    flist_pc = {flist_pc.name};
    flist_yr = intersect(flist_chl,flist_pc);
    flist_chlfile = setdiff(flist_chl,flist_yr);   
end

fprintf(flog,'Date: %s\n',datestr(now));
fprintf(flog,'%s\n','  ');
if ~isempty(flist_sfile)
    fprintf(flog,'The following short files are missing in %s  >> \n',pth_short);
    fprintf(flog,'%s\n','  ');
    flist_sfile = flist_sfile(:);
    for i=1:length(flist_sfile)
        fprintf(flog,'%s\n',char(flist_sfile(i)));
    end
else
    fprintf(flog,'No short files are missing in %s\n',pth_short);
end
fprintf(flog,'----------------------------------------------------------------------------------\n');
if ~isempty(flist_lgfile)
    fprintf(flog,'The following long files are missing in %s >> \n',pth_long);
    fprintf(flog,'%s\n','  ');
    flist_lgfile = flist_lgfile(:);
    for i=1:length(flist_lgfile)
        fprintf(flog,'%s\n',char(flist_lgfile(i)));
    end
else
    fprintf(flog,'No long files are missing in %s\n',pth_long);
end
if ~isempty(flist_chk)
    fprintf(flog,'---------------------------------------------------------------------------------- \n');
    fprintf(flog,'%s\n','  ');
    fprintf(flog,'HF data exists (so run recalcs for) the following dates with missing .mat files >> ');
    fprintf(flog, '%s\n','  ');
    flist_chk = flist_chk(:);
    for i=1:length(flist_chk)
        fprintf(flog,'%s\n',char(flist_chk(i)));
    end
end

if exist('fileExt_chs')
    fprintf(flog,'---------------------------------------------------------------------------------- \n');
    fprintf(flog,'%s\n','  ');
    if ~isempty(flist_chsfile)
        fprintf(flog,'The following chamber short files are missing in %s  >> \n',pth_short);
        fprintf(flog, '%s\n','  ');
        flist_chsfile = flist_chsfile(:);
        for i=1:length(flist_chsfile)
           fprintf(flog,'%s\n',char(flist_chsfile(i)));
        end
    else
        fprintf(flog,'No chamber files are missing in %s\n',pth_short);
    end
else
    flist_chsfile = [];
end

if exist('fileExt_chl')
    fprintf(flog,'---------------------------------------------------------------------------------- \n');
    fprintf(flog, '%s\n','  ');
    if ~isempty(flist_chlfile)
        fprintf(flog,'The following chamber long files are missing in %s  >> \n',pth_long);
        fprintf(flog, '%s\n','  ');
        flist_chlfile = flist_chlfile(:);
        varargout(:,4) = flist_chlfile;
        for i=1:length(flist_chlfile)
           fprintf(flog,'%s\n',char(flist_chlfile(i)));
        end
    else
        fprintf(flog,'No chamber files are missing in %s\n',pth_long);
    end
else
    flist_chlfile = [];
end
fprintf(flog,'======================================================================================== \n');
disp(sprintf('========================================================================================'));
fclose(flog);

