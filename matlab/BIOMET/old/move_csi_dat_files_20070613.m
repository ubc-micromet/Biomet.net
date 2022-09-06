function [fnames] = move_csi_dat_files(year,siteID,pth_csi);

% moves CSI datelogger .dat files into an 'old' directory
% with today's year and DOY appended to the filename

% (c) Nick Grant, 2007              File created:       June 11, 2007
%                                   Last modification:  June 11, 2007

% Revisions:
%
%

if pth_csi(end) ~= '\'
    pth_csi = [pth_csi '\'];
end

pth_csi_old = [pth_csi 'old\'];
lst_mh = dir(fullfile(pth_csi,'*.dat'));
fnames = {lst_mh.name}';
doy = floor(datenum(now) - datenum(year,1,0) - 8/24);
disp(['==================================== Moving CSI .DAT files for ' siteID ' ====================================']);
for i=1:length(fnames)
    fn = char(fnames{i});
    fn = [fn(1:end-4) '_' num2str(year) num2str(doy) '.DAT' ];
    cmd_str = ['move ' fullfile(pth_csi,fnames{i}) ' ' fullfile(pth_csi_old,fn) ];
    dos(cmd_str);
   % disp(cmd_str);
end
    