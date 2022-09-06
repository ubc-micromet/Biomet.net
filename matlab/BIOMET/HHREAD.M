function x = hhread(FileName, chan_name, index, Port, Page, Chan1, Chan2)

%   function x = hhread(FileName, chan_name, index, Port, Page, Chan1, Chan2)
%
%   For the given chan_name (see below), row index, Port, Page, channel numbers Chan1 
%   (for arrays) and Chan2 (for matrices), this function returns requested values from
%   the BOREAS hhour.bin file. The full file path is given in: FileName.
%      
%
% The file structure of HHour.bin:
%
% TYPE HHourStatType
%    date                                    AS STRING * 10
%    time                                    AS STRING * 10
%    NumOfChannels(1 TO MaxNumOfPorts)       AS INTEGER
%    NumOfLines(1 TO MaxNumOfPorts)          AS LONG
%    Rotation(1 TO MaxNumOfPorts)            AS STRING * 1
%    TimeDelay(1 TO MaxNumOfPorts)           AS INTEGER
%    avg(1 TO MaxNumOfPorts, 1 TO 2, 1 TO MaxNumOfChannels) AS SINGLE   
%    cov(1 TO MaxNumOfPorts, 1 TO 2, 1 TO MaxNumOfChannels, 1 TO MaxNumOfChannels) AS SINGLE
%    corr(1 TO MaxNumOfPorts)                AS SINGLE
%    Sensible(1 TO MaxNumOfPorts)            AS SINGLE
%    LatentLICOR(1 TO MaxNumOfPorts)         AS SINGLE
%    LatentKrypton(1 TO MaxNumOfPorts)       AS SINGLE
%    BowenRatioLICOR(1 TO MaxNumOfPorts)     AS SINGLE
%    BowenRatioKrypton(1 TO MaxNumOfPorts)   AS SINGLE
%    WaterUseEff(1 TO MaxNumOfPorts)         AS SINGLE
%    Ustar(1 TO MaxNumOfPorts)               AS SINGLE
%    Penergy(1 TO MaxNumOfPorts)             AS SINGLE
% END TYPE ' HHourStatType
%

%
% struct = [size(date) size(time) size(flag) size(ch1) size(ch2) ... size(chN)]
%

struct = [ 10 10 2*2 2*4 2*1 2*2 2*2*10*4 2*2*10*10*4   2*4 2*4 2*4 2*4 2*4 2*4 2*4 2*4 2*4] ;
types  = str2mat( 'char', 'char', 'short', 'long', 'char', 'short', 'float', 'float', 'float', 'float', 'float');
types  = str2mat( types, 'float', 'float', 'float', 'float', 'float', 'float');
types_len=[  1       1        2        4       1      2    4    4     4      4        4       4       4       4       4       4      4   ];

nargs = nargin;
if nargs < 7 
    Chan2 = 1;
end
if nargs < 6
    Chan1 = 1;
end
if nargs < 5
    Page = 1;
end
if nargs < 4
    Port = 1;
end

% Define the constants
MaxPorts = 2;
MaxChans = 10;
MaxPage = 2;

% define a matrix of names

Names = str2mat('latentlicor', 'latentkrypton', 'bowenratiolicor', 'bowenratiokrypton','wateruseeff','ustar','penergy');
Names = [str2mat(Names(1,:),'date','time','numofchannels','numoflines','rotation','timedelay','avg','cov','corr','sensible') ; Names ];
Names(1,:) = [];

%
% Find index for chan_name
%
chan_name = deblank(lower(chan_name));
[nn,nm] = size(Names);


tmp = [1;2] ;
flag = 0;
for  i = 1:nn
    tmp = str2mat(deblank(Names(i,:)), chan_name);
    if all(tmp(1,:) == tmp(2,:))
        flag = i;
        break;
    end
end

%
% If chan_name doesn't exist call 'error'
%
if flag == 0
    error('Wrong channel name');
end

% Else open the file
fid = fopen(FileName,'r');
if fid == -1
    error 'File does not exist!'
end

% Find file and record sizes
fseek(fid,0,1);
FileLength = ftell(fid);
RecLen = sum(struct);
NumOfRec = FileLength/RecLen;

if nargs < 3
    index = [ 1:NumOfRec ];
elseif index == []
    index = [ 1:NumOfRec ];        
elseif min(index) < 0 | max(index) > NumOfRec
    error 'Index is too big or too small'   
end

data_len = length(index);

% the output data matrix 

if flag == 1 | flag == 2 
    x = zeros(data_len, 10);
    rep = 10;                               % the number of consecutive readings
else
    x = zeros(data_len,1);
    rep = 1;                                % the number of consecutive readings
end

if flag == 1
    seek_num = 0;
else
    tmp = cumsum(struct);
    seek_num = tmp(flag-1) + mat_off( flag, types_len(flag), Port, Page, Chan1, Chan2, MaxPorts, MaxPage, MaxChans );   
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
if any(flag == [1 2 5])
    x = setstr(x);
end
