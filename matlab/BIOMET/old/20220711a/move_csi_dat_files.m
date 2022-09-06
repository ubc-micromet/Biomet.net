function [fnames] = move_csi_dat_files(year,siteID,pth_csi);

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
    fn = [fn(1:end-4) '.' num2str(year) num2str(doy) ];
    if ~exist(fullfile(pth_csi,fn))
        cmd_str = ['move ' fullfile(pth_csi,fnames{i}) ' ' fullfile(pth_csi,fn) ];
    else
        k=97;
        while exist(fullfile(pth_csi,fn)) & (k>=97 & k<=122) % check for existing filenames with suffixes between a and z
            if k==97                                         % (ASCII97 to ASCII122)
               fn = [ fn char(k) ];
           else
               fn = [ fn(1:end-1) char(k) ];
           end
            k=k+1; 
        end
        cmd_str = ['move ' fullfile(pth_csi,fnames{i}) ' ' fullfile(pth_csi,fn) ];
    end
    disp(cmd_str);
    dos(cmd_str);
end
    