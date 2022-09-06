% file joe001.m
%
%   Data transfer to AES Saskatoon, BONET data logger.
%
%
% (c) Zoran Nesic           File created:       Jan 10, 1997
%                           Last modification:  Jan 10, 1997
%
N = 50;                 % the number of channels
st = 5506;              % index of the first data point
ed = 17907;             % index of the latest data point
pth = 'r:\paoa\newdata\bonet\bnt.';
filename = 'd:\joe';    % output file name
%
% get first column and remove non-existant data
%
i = 1;
c = sprintf('tmp = read_bor(%s%s%s%s);',39,pth,num2str(i),39);
eval(c);
tmp = tmp(st:ed);
ind = find(tmp ~=0);
nn = length(ind);
d = zeros(nn,N);
d(:,i) = tmp(ind);
for i=2:N
    c = sprintf('tmp = read_bor(%s%s%s%s);',39,pth,num2str(i),39);
    eval(c);
    tmp = tmp(st:ed);
    d(:,i) = tmp(ind);
    fprintf([num2str(i) ' ']);
end
%ind = find(d(:,1) ~= 0);
%d = d(ind,:);

c = [];
for i = 1:N
    c = [c '%6.4f,'];
end
c = [c(1:length(c)-1) '\x0d\x0a'];
%fid = fopen('d:\junk','w');
%fprintf(fid,c,d');
%fclose(fid);
chunks = 10;
stp = ceil(length(d)/chunks);
for i=1:chunks
    fprintf('%s ',num2str(i));
    comm = sprintf('fid = fopen(%s%s%s%s%s,%sw%s);',39,filename,'.',num2str(i),39,39,39);
    eval(comm);
    if i < chunks
        fprintf( fid, c, d((i-1)*stp+1:i*stp,:)' );
    else
        fprintf( fid, c, d((i-1)*stp+1:length(d),:)' );
    end
    fclose(fid);
end
fprintf('\n');
