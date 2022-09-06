function x = callog(FileName, flag, index, Port, Chan, Page)
%
%
%
%flag  TYPE CalType
%  1      dateS                                                           AS STRING * 10
%  2      timeS                                                           AS STRING * 8
%  3      ActivePorts(1 TO MaxNumOfPorts)                                 AS INTEGER
%  4      NumOfStages(1 TO MaxNumOfPorts)                                 AS INTEGER
%  5      CalPointsToAverage(1 TO MaxNumOfPorts)                          AS INTEGER
%  6      CalibrationTimes(1 TO MaxNumOfPorts, 1 TO MaxCalStages)         AS INTEGER
%  7      ZeroCal(1 TO MaxNumOfPorts, 1 TO MaxNumOfChannels, 1 TO 2)      AS SINGLE
%  8      SpanCal(1 TO MaxNumOfPorts, 1 TO MaxNumOfChannels, 1 TO 2)      AS SINGLE
%  9      CheckZero(1 TO MaxNumOfPorts, 1 TO MaxNumOfChannels, 1 TO 2)    AS SINGLE
%  10     CheckSpan(1 TO MaxNumOfPorts, 1 TO MaxNumOfChannels, 1 TO 2)    AS SINGLE
%      END TYPE 'CalType
%
%
% (c) Zoran Nesic               File created:       Aug 3, 1996
%                               Last modification:  Aug 4, 1996
%

% Define the constants

MaxPorts = 2;
MaxChans = 10;
MaxStages = 10;
MaxPage = 2;

if flag ==1 | flag ==2
    if nargin < 2
        error 'Not enough input parameters!'
    end
    Port = 1;
    Chan = 1;
    Page = 1;
elseif flag >=3 & flag <= 5
    if nargin < 4
        error 'Not enough input parameters!'
    elseif Port > MaxPorts        
        error 'The number of ports is too big!'
    end
    Chan = 1;
    Page = 1;
elseif flag == 6
    if nargin < 4
        error 'Not enough input parameters!'
    elseif Port > MaxPorts        
        error 'The number of ports is too big!'
    elseif Chan > MaxStages
        error 'The number of stages is too big!'
    end
    Page = 1;
elseif flag >=7 & flag <= 10
    if nargin < 6
        error 'Not enough input parameters!'
    elseif Port > MaxPorts        
        error 'The number of ports is too big!'
    elseif Chan > MaxChans
        error 'The number of chans is too big!'
    elseif Page > MaxPage
        error 'The number of page is too big!'
    end
end
        
%
% struct = [size(date) size(time) size(flag) size(ch1) size(ch2) ... size(chN)]
%

struct = [ 10   8  2*2  2*2 2*2  2*10*2 2*10*2*4 2*10*2*4  2*10*2*4 2*10*2*4 ] ;
types  = str2mat( 'char', 'char', 'short', 'short', 'short', 'short', 'float', 'float', 'float', 'float');
types_len=[  1   1   2    2   2    2     4     4        4      4   ];

% Open the file
fid = fopen(FileName,'r');
if fid == -1
    error 'File does not exist!'
end

% Find file and record sizes
fseek(fid,0,1);
FileLength = ftell(fid);
RecLen = sum(struct);
NumOfRec = FileLength/RecLen;

if index == []
    index = [ 1:NumOfRec ];
elseif index == []
    index = [ 1:NumOfRec ];        
elseif min(index) < 0 | max(index) > NumOfRec
    error 'Index is too big or too small'   
end

data_len = length(index);

% the output data matrix 

if flag == 1
    x = zeros(data_len, 10);
    rep = 10;                               % the number of consecutive readings
elseif flag == 2     
    x = zeros(data_len, 8);
    rep = 8;                               % the number of consecutive readings
else
    x = zeros(data_len,1);
    rep = 1;                                % the number of consecutive readings
end

tmp = cumsum(struct);
if flag == 1
    seek_num = 0;
elseif flag ==2
    seek_num = tmp(1);    
else
    seek_num = tmp(flag-1) + (Port + (Chan-1)*MaxPorts + (Page-1)*MaxPorts*MaxChans - 1) * types_len(flag) ;
end


% read the data
typ = deblank(types(flag,:));                          % data type
for i = 1:data_len
    fseek(fid,seek_num + RecLen * (index(i) - 1),-1);                   
    x(i,:) = fread( fid, rep, typ)';
end

fclose(fid);

%
% Check if x is a string and, if it is, switch it to Matlab string format
%
if any(flag == [1 2])
    x = setstr(x);
end


