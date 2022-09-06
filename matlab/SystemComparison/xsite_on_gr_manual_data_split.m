function xsite_on_gr_manual_data_split

pth = 'D:\kai_data\Projects_data\XSITE\Experiments\ON_GR\CARD_DUMP\20050808\Split';
pth_out = 'D:\kai_data\Projects_data\XSITE\Experiments\ON_GR\CARD_DUMP\20050808\formated';
lst = dir(pth);

t_start = datenum(2005,8,1,22,0,0);

% for i = 165:length(lst)
for i = 148:164
    if ~lst(i).isdir
        tst = char(textread(fullfile(pth,lst(i).name),'%q',1,'headerlines',4));
        YY = str2num(tst(1:4));
        MM = str2num(tst(6:7));
        DD = str2num(tst(9:10));
        hh = str2num(tst(12:13));
        mm = str2num(tst(15:15));
                
        x = csvread(fullfile(pth,lst(i).name),4,1);
        
        file_no = str2num(lst(i).name(end-2:end));
        dv = datevec(datenum(YY,MM,DD,hh,mm,0));
        fileName1 = sprintf('ts_data_%4i_%02i_%02i_%02i%02i.dat',dv(1),dv(2),dv(3),dv(4),dv(5));
        fileName2 = sprintf('ts_data_%4i_%02i_%02i_%02i%02i.dat',dv(1),dv(2),dv(3),dv(4),dv(5)+30);
        
        [n,m] = size(x);
        x1 = [-999*ones(36000+4,2) [-999.*ones(4,m);x(1:36000,:)]];
        x2 = [-999*ones(36000+4,2) [-999.*ones(4,m);x(36001:72000,:)]];
        
        csvwrite(fullfile(pth_out,fileName1),x1);
        csvwrite(fullfile(pth_out,fileName2),x2);
    end
end
