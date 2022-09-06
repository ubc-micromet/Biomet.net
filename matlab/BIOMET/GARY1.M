%******************************************************************************
%
% this scrip will create a data file for Gary Hodges
%
% Written by Zoran Nesic, July 14, 1995
%******************************************************************************
dirs = str2mat( 'd:\cd-rom\data\meaes'...            
                 );

dirSpan = [ 3 ];

fileNames = str2mat(    'meaes.13',...
                        'meaes.14',...
                        'meaes.16'...
                        );
flagFiles = str2mat(    'meaes_f1'...
                        );
                        
flagSize = [ 7 ];                   

[M junk] = size(fileNames);
tmp = read_bor( [ deblank( dirs(1,:) )  '\' deblank(fileNames(1,:)) ] );
N = length(tmp);
clear tmp 
output1 = zeros(N,M);                        
dateStr = read_bor( 'd:\cd-rom\data\hfubc\hfubc_d', 4 );
timeStr = read_bor( 'd:\cd-rom\data\hfubc\hfubc_t', 5 );
timeDec = read_bor( 'd:\cd-rom\data\hfubc\hfubc_dt', 1 );
k = 1
flags = read_bor( [ deblank( dirs(k,:) )  '\' deblank(flagFiles(k,:)) ],2, flagSize(k) );
flagInd = find( flags(:,1) == 0 );
a9999 = 9999*ones(size(flagInd));
for i = 1: M
    if i > dirSpan(k)
        k = k + 1;
        flags = read_bor( [ deblank( dirs(k,:) )  '\' deblank(flagFiles(k,:)) ],2, flagSize(k) );
        flagInd = find( flags(:,1) == 0 );
        a9999 = 9999*ones(size(flagInd));
    end
    [i k]
    output1(:,i) = read_bor( [ deblank( dirs(k,:) )  '\' deblank(fileNames(i,:)) ] );
    output1(flagInd,i) = a9999;             % missing data
end

%==============================================================================
% print 1994 year only
%

offset = 153*48+2+201*48;
endOffset = offset + 5*48 - 1;
ToPrint = offset:endOffset;
formatX = '%s %4.0f %5.0f %5.0f'; 
for i = 1:M
    formatX = [formatX ' %8.4e'];
end
formatX = [formatX '\x00d\n'];

dateStr1 = dateStr(ToPrint-1,[9:10 1:2 4:5]);
timeNum1 =  str2num(timeStr(ToPrint-1,[ 1:2 4:5]));
timeNum2 = str2num(timeStr(ToPrint,[ 1:2 4:5]));
output2 = output1(ToPrint,:);
ind = find(timeNum2 == 0);
timeNum2(ind,:) = 2400*ones(size(ind));

fid = fopen('out2','w');
for row=1:length(ToPrint)
    fprintf(fid,formatX,dateStr1(row,:),fix(timeDec(offset -1 + row-1)-152),timeNum1(row,:),timeNum2(row,:),output2(row,:));
end
fclose(fid);
                                                                 
