function d = exp_pa(pth,channs,ind,filename,chunks)
% file exp_pa.m
%
%   Data transfer to AES Saskatoon - data loggers.
%
%
% (c) Zoran Nesic           File created:       Mar 27, 1997
%                           Last modification:  Apr  8, 1998
%

%
% Revisions:
%   Apr 8, 1998
%       - modifications to make the program work for year 1998 and later
%         (used new Matlab 5.x date/time functions)

badDataFlag = 1e38;
Offset1996 = datenum(1996,1,1,0,0,0);               % data base start

if nargin < 4
    error 'More input parameters needed'
end
if exist('chunks') ~=1
    chunks = 1;
end


decDOY = read_bor([pth '_dt'])+1;           % GMT dec DOY
totalLength = length(decDOY);
decDOY = decDOY(ind);
timeVector = decDOY + Offset1996;
[DOY,yearX]= fr_get_doy(timeVector);
DOY = floor(DOY);

timeX = round( ((decDOY - floor(decDOY))*24 + 0.001) * 100 ) /100;

additionalColumns = 3;

%
% get flag column and remove non-existant data
%
flagPth = [pth '_f1'];                      % flag file name
fid = fopen(flagPth,'r');
fseek(fid,0,1);
flagNum = ftell(fid)/totalLength;           % find the number of flag bytes
fclose(fid);
flag = read_bor(flagPth,2,flagNum);         % get flag file
flag = flag(ind,:);


N = length(channs);                         % the number of channels

st = min(ind);
ed = max(ind);

nn = length(ind);
d = zeros(nn,N+additionalColumns);

d(:,1:additionalColumns) = [yearX DOY timeX];

fprintf('\nThe number of input columns: %d\n',N);
fprintf('Column number: ');
for i=1:N
    c = sprintf('tmp = read_bor(%s%s.%s%s);',39,pth,num2str(channs(i)),39);
    eval(c);
    tmp = tmp(ind);
    f1 = find(get_flag(flag,channs(i))==0);
    tmp(f1) = badDataFlag * ones(size(f1));
    d(:,i+additionalColumns) = tmp;
    fprintf([num2str(i) ' ']);
end

fprintf('\n\n');
c = ['%d %d %5.2f '];
for i = 1:N
    c = [c '%13.4e '];
end
c = [c(1:length(c)-1) '\x0d\x0a'];

stp = ceil(length(d)/chunks);
fprintf('\nThe number of output files: %d\n',chunks);
fprintf('Output-file number: ');
for i=1:chunks
    fprintf('%s ',num2str(i));
    comm = sprintf('fid = fopen(%s%s%s%s%s,%sw%s);',39,filename,'.',num2str(i),39,39,39);
    eval(comm);
    fprintf(fid,'File path: %s\x0d\x0a',pth);
    fprintf(fid,'Column definitions: 1 to 3: Year, DOY, TIME \x0d\x0a');
    fprintf(fid,'Data columns 4 and up are data logger channels: ');
    fprintf(fid,'%d ',channs);
    fprintf(fid,' \x0d\x0a\x0d\x0a');
    if i < chunks
        fprintf( fid, c, d((i-1)*stp+1:i*stp,:)' );
    else
        fprintf( fid, c, d((i-1)*stp+1:length(d),:)' );
    end
    fclose(fid);
end

fprintf('\n');
if nargout == 0
    clear d
end
    