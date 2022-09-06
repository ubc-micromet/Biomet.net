function [fnames] = renam_csi_dat_files(pth_csi);

% moves .DAT files into an \old directory after appending DOY and 
% possibly a, b, c... etc. if there have been previous files moved
% on the same day

% (c) Nick Grant
% file created:                 June 13, 2007
% last revision:                Oct  8, 2009

% revision history
% Oct 8, 2009
%   - Nick started a new version for waterQ logger
% Oct 10, 2008 (zoran)
%   - added file suffix checking for \old folder too so the new suffix
%     would be unique for csi_net and csi_net\old folder
%   - made zero padding simpler by using built in functionallity of
%   - removed year and SiteID as input parameters.
%   num2str.
% Feb 7, 2008
%   -added zeros to pad single and double digit DOYs (Nick)
% July 12, 2007
%       -put the move statement inside a "try" "catch"

if pth_csi(end) ~= '\'
    pth_csi = [pth_csi '\'];
end

pth_csi_old = [pth_csi 'old\'];
lst_mh = dir(fullfile(pth_csi,'*.dat'));
fnames = {lst_mh.name}';
year = datevec(now);
year = year(1);
doy = floor(datenum(now) - datenum(year,1,0) - 8/24);

disp(['==================================== Renaming CSI .DAT files in ' pth_csi ' ====================================']);
for i=1:length(fnames)
    fn = char(fnames{i});
    fn = [fn(1:end-4) '.' num2str(year) num2str(doy,'%03d') ];
    if ~exist(fullfile(pth_csi,fn))
        cmd_str = ['move ' fullfile(pth_csi,fnames{i}) ' ' fullfile(pth_csi_old,fn) ];
    else
        k=97;
        while exist(fullfile(pth_csi,fn)) & (k>=97 & k<=122) ...
                | exist(fullfile(pth_csi_old,fn)) & (k>=97 & k<=122) % check for existing filenames with suffixes between a and z
            if k==97                                         % (ASCII97 to ASCII122)
               fn = [ fn char(k) ];
           else
               fn = [ fn(1:end-1) char(k) ];
           end
            k=k+1; 
        end
        cmd_str = ['move ' fullfile(pth_csi,fnames{i}) ' ' fullfile(pth_csi_old,fn) ];
    end
    disp(cmd_str);
    try
        dos(cmd_str);
    catch
        disp(lasterr);
        return
    end
end
    