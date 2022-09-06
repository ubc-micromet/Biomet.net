
function [date_HF,N] = CRBasic_file_rename_mpb(siteId,pth_mpb)
%
% CRBasic_file_rename - renames ascii data from any CRBasic Campbell Sci.
% data logger from table format to yymmddqq.fileNameExtension format. 
% Original filenames are lost.
%
% Inputs:
%   pth_asci   - folder with all the ascii data (it can have multiple days, file names don't matter)
%   pth_data   - root directory where all the daily data file folders are to be
%                 kept
%[
% Outputs:
%   N           - the number of files processed
%   date_HF     - cellstr array of dates for which HF files were processed
%
% (c) Zoran Nesic           File created:       Jul 10, 2004
%                           Last modification:  March 9, 2010

% Revisions
% March 9, 2010
%   -added cellstr array of dates for which HF data was converted (Nick)
% May 3, 2007
%   -modified for batch processing--the program now creates the daily data
%    folders based on the datestamp read from the ascii files (Nick)
% Apr 27, 2007
%   - Started with the MPB1_file_rename.m program and made it a generic
%   CRBasic program

pth_ascii = fullfile(pth_mpb,siteId,'raw\ascii');
pth_data  = fullfile(pth_mpb,siteId,'met-data\data');

switch siteId
        case 'MPB1'
           nCR5000=1;
           extHF  = 'dMPB11';
        case 'MPB2'
           nCR5000=1;
           extHF  = 'dMPB21';
        case 'MPB3'
           nCR5000=1;
           extHF  = 'dMPB31';
        case 'MPB4'
           nCR5000=1;
           extHF  = 'dMPB41';
        case 'HP09'
           nCR5000=1;
           extHF  = 'dHP091';
        case 'HP11'
           nCR5000=1;
           extHF  = 'dHP111';
end

% if ~exist('fileNameExtension') | isempty(fileNameExtension)
%     error 'Missing input parameter: fileNameExtension'
% end
% if ~exist('pth_asci') | isempty(pth_asci)
%     error 'Missing input parameter: ascii file location'
% end
% if ~exist('pth_data') | isempty(pth_data)
%     error 'Missing input parameter: location for daily HF files'
% end


% if pth_data(end)~= '\'
%     pth_data = [ pth_data '\' ];
% end
% 
% if pth_ascii(end)~= '\'
%     pth_asci = [ pth_ascii '\' ];
% end

x = dir(pth_ascii);
N = 0;
for k = 1:length(x)
    if x(k).isdir ~= 1
        N = N+1;
        fileNameOld = fullfile(pth_ascii,x(k).name);
        formatStr = '%q %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s';
        % remove 4 header lines and use assume "," is used as a delimiter
        [date_stamp,junk,junk,junk,co2,h2o,Pair,Idiag,u,v,w,Ts,Sdiag,tc1,tc2,tc3] = ...
                                    textread(fileNameOld,formatStr,1,'delimiter',',','headerlines',4);
        date_stamp=char(date_stamp(end));
        yy = str2num(date_stamp(1:4));
        mm = str2num(date_stamp(6:7));
        dd = str2num(date_stamp(9:10));
        hh = datenum(date_stamp(12:end-2));
        tv = fr_round_hhour(datenum(yy,mm,dd)+(hh-floor(hh))+0.0001,2);
        date_str = [ date_stamp(3:4) date_stamp(6:7) date_stamp(9:10) ];
        date_HF(k,1:6)=date_str;
        pth_daily = [ pth_data '\' date_str ];
        if ~exist(pth_daily)
            mkdir(pth_data,date_str);
        end
        fileNameNew = fullfile(pth_data,[date_str '\' fr_DateToFileName(tv) '.' extHF]); 
        DOScommand = ['move ' fileNameOld '  ' fileNameNew];
        disp(sprintf('%s\n',DOScommand));
        dos(DOScommand);
    end
end
date_HF = unique(cellstr(date_HF));
