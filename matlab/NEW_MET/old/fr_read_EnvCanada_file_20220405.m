function [dataOut,dataIn,Header] = fr_read_EnvCanada_file(fileName)
% [dataOut,dataIn,Header] = fr_read_EnvCanada_file(fileName)
% 
% Inputs:
%   fileName            - Environment Canada Monthly data file in ASCII/csv format
%
% Outputs:
%     dataOut           - Selecte output variables
%           .tv        time
%           .Tair      deg C
%           .DewPoint  deg C
%           .RH        [%]
%           .WindDir   degrees
%           .WindSpeed m/s
%           .Pbar      Pa
%
%     dataIn    -  Original file output structure
%     Header    -  File header info
%
%
% (c) Zoran Nesic                   File created:       Jan 17, 2020
%                                   Last modification:  Jan 17, 2020
%

% Revisions (last one first):
%
% Mar 2, 2020 (Zoran)
%	- removed the buffer size parameter from textscan to conform with Matlab 2014-> syntax
%

fid = fopen(fileName);
if fid > 0
    % read the first two lines in the file (each line is one cell)
    headerLine = textscan(fid,'%q',1,'headerlines',0,'Delimiter','\n','whitespace','\b\t');%,'BufSize',20000);
    %headerLine = fgetl(fid);
    fclose(fid);
    headerLine = char(headerLine{1}); 
    % go through the header and find the column names and the number of
    % variables
    %indComma = find(headerLine==',');
    indQuote = find(headerLine=='"');

    for i = 1:2:length(indQuote)-1
        %Header.variableNames(i) = headerLine(st+1:indComma(i)-1);
        tmp = headerLine(indQuote(i)+1:indQuote(i+1)-1);
        % filter the characters that cannot be part of var name
        %tmp = tmp(find(tmp>33 & tmp<122)); %#ok<*FNDSB>
        %tmp(find(tmp=='(' |tmp==')' | tmp=='/' | tmp=='%')) = '_'; 
        %Header.variableNames{st} = tmp(find(tmp>33 & tmp<122));
        Header.variableNames{(i+1)/2} = tmp;
    end
end
Header.numOfVars = length(Header.variableNames);
% at this point the number and the names of variables are extracted
% next: create the format string 
formatStr = '%f%f%s%d%s%d%d%d%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%s';

fid = fopen(fileName);
if fid > 0
    % read the first two lines in the file (each line is one cell)
    dataIn = textscan(fid,formatStr,'headerlines',1,'Delimiter',',','MultipleDelimsAsOne',0,'whitespace','"\t"'); %,'BufSize',20000);
    %headerLine = fgetl(fid);
    fclose(fid);
end

% This a patch: each string contains a quote (") at the end of it. Search and
% replace.
indStr = find(formatStr=='s');
for i=1:length(indStr)
    varNum = indStr(i)/2;
    for j = 1: length(dataIn{varNum})
        tmpStr = char(dataIn{varNum}(j));
        dataIn{varNum}(j) = {tmpStr(1:end-1)};
    end
end

% Extract the traces
TimeVector = datenum(dataIn{5});% time
Tair = dataIn{10};              % deg
DewPoint = dataIn{12};          % deg
RH = dataIn{14};                % [%]
WindDir = dataIn{16}*10;        % deg
WindSpeed = dataIn{18}/3.6;     % k/h -> m/s
Pbar = dataIn{22}*1000;       % pressure in Pa
for i=1:length(TimeVector)
    dataOut(i).TimeVector = TimeVector(i); %#ok<*AGROW>
    dataOut(i).Tair = Tair(i);
    dataOut(i).DewPoint = DewPoint(i);
    dataOut(i).RH = RH(i);
    dataOut(i).WindDir = WindDir(i);
    dataOut(i).WindSpeed = WindSpeed(i);
    dataOut(i).Pbar = Pbar(i);
end

    


