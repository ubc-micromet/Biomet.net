function y = dlmread(fileName)

fileNameOut = 'c:\junk1.prn';
fid=fopen(fileName,'rt');
x=fread(fid,[1 inf],'uchar');
fclose(fid);
ind=find(x==',');
x(ind)=' ';
fid=fopen('c:\junk1.prn','wt');
fwrite(fid,x,'uchar');
fclose(fid);
y = load(fileNameOut);
dos(['del  ' fileNameOut]);
