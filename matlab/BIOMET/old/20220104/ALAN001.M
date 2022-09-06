function d = exp_pa(filename,channs,pth,ind)
% file alan003.m
%
%   Data transfer to AES Saskatoon, AESMET & BONET data logger.
%
%
% (c) Zoran Nesic           File created:       Mar 27, 1997
%                           Last modification:  Mar 27, 1997
%

%channs = [1 2 3 4 5 6 7 10 11 12 50:53];       % channels to export
%pth = 'r:\paoa\newdata\aesmet\met.';           % path
%filename = 'd:\aesmet';                        % output file name

N = length(channs);                             % the number of channels

%
% get first column and remove non-existant data
%
i = 1;
c = sprintf('tmp = read_bor(%s%s%s%s);',39,pth,num2str(channs(i)),39);
eval(c);

st = 1;                                     % index of the first data point
ed = length(tmp);                           % index of the latest data point

tmp = tmp(st:ed);
ind = find(tmp ~=0);
nn = length(ind);
d = zeros(nn,N);
d(:,i) = tmp(ind);
fprintf('\nThe number of input columns: %d\n',N);
fprintf('Column number: ');
for i=2:N
    c = sprintf('tmp = read_bor(%s%s%s%s);',39,pth,num2str(channs(i)),39);
    eval(c);
    tmp = tmp(st:ed);
    d(:,i) = tmp(ind);
    fprintf([num2str(i) ' ']);
end
%ind = find(d(:,1) ~= 0);
%d = d(ind,:);
fprintf('\n\n');
c = [];
for i = 1:N
    c = [c '%6.4f,'];
end
c = [c(1:length(c)-1) '\x0d\x0a'];
%fid = fopen('d:\junk','w');
%fprintf(fid,c,d');
%fclose(fid);
chunks = 1;
stp = ceil(length(d)/chunks);
fprintf('\nThe number of output files: %d\n',chunks);
fprintf('Output-file number: ');
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