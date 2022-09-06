function [x,TotalSamples,SamplesRead] = FR_read_raw_data(FileName,NumOfChannels, SamplesToRead,rd_flag)
% 
% [x,TotalSamples,SamplesRead] = FR_read_raw_data(FileName,NumOfChannels, SamplesToRead,rd_flag)
%
%   This function reads data from raw data files created by the eddy correlation
%   programs (UBC_GillR2 and UBC_DAQbook). 
%   If an error happens while reading files the program will return:
%         x = [],TotalSamples = 0, SamplesRead = 0;
%
%   Inputs:
%       FileName            - file name (including the path) of the raw data file
%       NumOfChannels       - number of channels in the file
%       SamplesToRead       - number of samples to read (if greater than the num. of
%                             samples in the file read the entire file)
%       rd_flag             - if SamplesToRead less than the num. of samples
%                             in the file then:
%                             rd_flag = 0,    read SamplesToRead from the beginning of the file
%                             rd_flag = 1,    read SamplesToRead from the end of the file (default)
%                                   
%
%
% (c) Nesic Zoran           File created:       Oct 17, 1997
%                           Last modification:  May 16, 1998
%
% Revisions:
%
%   May 16, 1998
%       -   added err_hnd procedure and testing of all file IO flags. Tryed to
%           correct the bug that caused Matlab to read/use bad data.
%       -   added line:
%               [junk,SamplesRead] = size(x); 
%           just to make sure that SamplesRead is equal to the actual number of
%           samples read not the requested one.
%       -   if an error happens while reading files the program will return:
%               x = [],TotalSamples = 0, SamplesRead = 0;

ni = nargin;
if  ni < 2
    error 'Too few input parameters!'
end

c = sprintf('fid = fopen(%s%s%s,%sr%s);',39,FileName,39,39,39);
eval(c);
if fid < 3
    [x,TotalSamples,SamplesRead] = err_hnd;    
    return
end

status          = fseek(fid,0,'eof');               % find the end of file
if status == -1
    [x,TotalSamples,SamplesRead] = err_hnd;    
    disp(ferror(fid));
    return
end

status          = ftell(fid);
if status == -1
    [x,TotalSamples,SamplesRead] = err_hnd;    
    disp(ferror(fid));
    return
end
TotalSamples    = ftell(fid) / 2 / NumOfChannels;   % calculate total number of samples

if exist('SamplesToRead') == 0                      % if SamplesToRead not given
    SamplesToRead = TotalSamples;                   % default is TotalSamples
end

if exist('rd_flag') == 0                            % decide whether to read from start or end
    rd_flag = 1;                                    % default is read from the end of file
end

if SamplesToRead < TotalSamples                     % if partial read requested
    SamplesRead = SamplesToRead;
else
    SamplesRead = TotalSamples;                     % read everything
end

if rd_flag == 1                                     % check the rd_flag
    status = fseek(fid, ...
              -SamplesRead*NumOfChannels*2,'eof');  % rewind for SamplesRead samples
else
    status = fseek(fid,0,'bof');                    % rewind to beginning of the file
end
if status == -1
    [x,TotalSamples,SamplesRead] = err_hnd;    
    disp(ferror(fid));
    return
end

x = fread(fid,[NumOfChannels,SamplesRead],'int16');
[junk,SamplesRead] = size(x);                        % get SamplesRead

fclose(fid);



%===============================================
function [x,TotalSamples,SamplesRead] = err_hnd
x = [];
TotalSamples = 0;
SamplesRead  = 0;
