% file alan002.m
%
%   Data transfer to AES Saskatoon, EDDY correlation system.
%
%
% (c) Zoran Nesic           File created:       Feb 17, 1997
%                           Last modification:  Feb 17, 1997
%


%
% 
%
%
%
%
%
%

channs = [81 82 27 44];                     % channels to export
additionalColumns = 3;                      % additional columns to append (year DOY time)
%channs = str2mat('dt','81','82','27');
N = length(channs);                         % the number of channels
pth = 'h:\\zoran\\paoa\\paoa_%d.2_2';
flagPth = 'h:\zoran\paoa\paoa_f1';
timePth = 'h:\zoran\paoa\paoa_dt';

filename = 'd:\alan002';                    % output file name

%
% get flag column and remove non-existant data
%

flag = read_bor(flagPth,2,11);              % get flag file

st = 1;                                     % index of the first data point
ed = length(flag);                          % index of the latest data point

flag = flag(st:ed,:);                       % get the time interval
flag = get_flag(flag,81);                   % get the flag for H
ind = find(flag == 1);                      % find existing data

%
% load decimal time and convert it to DOY
% find year
%
t = read_bor(timePth)+1;
t = t(ind);
tx = t;
indx = find(t>=367);
tx(indx) = tx(indx) - 366;
DOY = floor(tx);
timeX = round( ((tx - DOY)*24 + 0.001) * 100 ) /100;
y = 1996 * ones( size(tx) );
y(indx) = 1997 * ones( size(indx) );


i = 1;
c = sprintf(['tmp = read_bor(%s' pth '%s);'],39,channs(i),39);
eval(c);
tmp = tmp(st:ed);
nn = length(ind);
d = zeros(nn,N+additionalColumns);
d(:,i+additionalColumns) = tmp(ind);
fprintf('\nThe number of input columns: %d\n',N);
fprintf('Column number: ');
for i=2:N
%    c = sprintf('tmp = read_bor(%s%s%s%s);',39,pth,num2str(channs(i)),39);
    c = sprintf(['tmp = read_bor(%s' pth '%s);'],39,channs(i),39);
    eval(c);
    tmp = tmp(st:ed);
    d(:,i+additionalColumns) = tmp(ind);
    fprintf([num2str(i) ' ']);
end
d(:,1:additionalColumns) = [y DOY timeX];
%ind = find(d(:,1) ~= 0);
%d = d(ind,:);
fprintf('\n\n');
c = [];
for i = 1:N+additionalColumns
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
