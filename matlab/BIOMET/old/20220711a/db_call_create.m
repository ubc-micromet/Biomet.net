siteFlag = 'PA';
pth = 'r:\paoa\newdata\bonet_new\';
fileNamePrefix = 'bntn3';
st = datenum(1996,1,1,0,0,0);
ed = datenum(1999,1,1,-0.5,0,0);
perHour = 2;
maxChannels = 16;
DB_len = DB_create(siteFlag,pth,fileNamePrefix,st,ed,perHour,maxChannels);
