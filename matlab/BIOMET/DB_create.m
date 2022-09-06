function [DB_len] = DB_create(pth,fileNamePrefix,startDateNum,stopDateNum,perHour,maxChannels)
%
%
% (c) Zoran Nesic           File created:       Apr 13, 1998
%                           Last modification:  Jan 26, 2000
%

%
% Revisions:
%
% Jan 26, 2000
%   - removed siteFlag variable (hasn't been used anyway)
%

% ---------------------------------
% check the path and create
% the full file name prefix
%
if pth(end) ~= '\'
    pth = [pth '\'];
end
if exist(pth,'dir')~= 7
    error 'Bad path!'
end
FileNameMain = [pth fileNamePrefix];


DB_len = round((stopDateNum - startDateNum)* 24*perHour) + 1;   % calc. number of records
TimeVector = linspace(startDateNum,stopDateNum,DB_len);         % create the time vector

if 1==2
    junk = '-' * ones(length(TimeVector),1);                    % create the date and time
    DateS = [datestr(TimeVector,5) junk datestr(TimeVector,7) junk datestr(TimeVector,10)];
    TimeS = datestr(TimeVector,13);                             % string
else
    DateS = setstr(zeros(DB_len,10));
    TimeS = setstr(zeros(DB_len,8));
end

ZeroFile = zeros(DB_len,1);                                     % create a full size zero array
FlagLen  = ceil(maxChannels/8);                                 % bytes needed to store 1 bit per channel
Flag1    = setstr(zeros(DB_len,FlagLen));                       % create a full size flag1 file
Flag2    = setstr(zeros(DB_len,10));                            % create a full size flag2 file

%
% Create new files
%
fid = fopen([FileNameMain '_tv'],'w');                          % create time vector file
file_err_chk(fid)                                               % check if file opened properly
x = fwrite(fid,TimeVector,'float64');                           % save TimeVector
fclose(fid);

fid = fopen([FileNameMain '_dt'],'w');                          % create decimal time file
file_err_chk(fid)                                               % check if file opened properly
x = fwrite(fid,TimeVector-TimeVector(1),'float32');             % save decimal time
fclose(fid);

fid = fopen([FileNameMain '_d'],'w');                           % create date string file
file_err_chk(fid)                                               % check if file opened properly
x = fwrite(fid,DateS,'uchar');                                  % save date string
fclose(fid);

fid = fopen([FileNameMain '_t'],'w');                           % create time string file
file_err_chk(fid)                                               % check if file opened properly
x = fwrite(fid,TimeS,'uchar');                                  % save time string
fclose(fid);

fid = fopen([FileNameMain '_f1'],'w');                          % create flag1 file
file_err_chk(fid)                                               % check if file opened properly
x = fwrite(fid,Flag1,'uchar');                                  % save flag1
fclose(fid);

fid = fopen([FileNameMain '_f2'],'w');                          % create flag2 file
file_err_chk(fid)                                               % check if file opened properly
x = fwrite(fid,Flag2,'uchar');                                  % save flag2
fclose(fid);

%---------------------------------------
% create all data files

for i =1:maxChannels
    fid = fopen([FileNameMain '.' num2str(i)],'w');             % create data file
    file_err_chk(fid)                                           % check if file opened properly
    x = fwrite(fid,ZeroFile,'float32');                         % save data file
    fclose(fid);
end



%===============================================================
% LOCAL FUNCTIONS
%===============================================================
function x = file_err_chk(fid)
    if fid == -1
        error 'File opening error'
    end
