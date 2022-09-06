% Script to extract noon temperatures for Dave (OA site)
pth = biomet_path(2001,'pa','cl');
x = read_bor(fullfile(pth,'bonet_new\bntn.24'));
tv = read_bor(fullfile(pth,'bonet_new\bntn1_tv'),8)-6/24;
ind = find( tv < datenum(2001,4,1));
x = x(ind);
tv = tv(ind);
ind1 = 36:48:length(x);
plot(tv(ind1),x(ind1))
datetick
[datestr(tv(ind1))  num2str(x(ind1))]
