function [dataOut,dataIn,Header] = fr_read_EnvCanada_file(fileName,targetVarsIn,targetVarsOut,PbarMult)
% [dataOut,dataIn,Header] = fr_read_EnvCanada_file(fileName)
% 
% Inputs:
%   fileName            - Environment Canada Monthly data file in ASCII/csv format
%   targetVarsIn        - Env Canada var names (see defaults in the program, create your own if needed)
%   targetVarsOut       - Desired output var names (see defaults in the program, create your own if needed)
%   PbarMult            - conversion factor for air Pressure. Default is 1000 so the units of Pbar are Pa)
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
%                                   Last modification:  Apr  2, 2022
%

% Revisions (last one first):
%
% Apr 2, 2022 (Zoran)
%   - Made file more generic so it has a better chance to adapt to EC file format changes.
%     Added targetVarsIn and targetVarsOut parameters.
% Mar 2, 2020 (Zoran)
%	- removed the buffer size parameter from textscan to conform with Matlab 2014-> syntax
%

targetVarsInDefault = {'Temp (','Dew Point Temp (',...
                    'Rel Hum (','Precip. Amount (',...
                    'Wind Spd (km/h)','Wind Dir (',...
                    'Stn Press (kPa)'};
targetVarsOutDefault = {'Tair','DewPoint',...
                    'RH','Precip',...
                    'WindSpeed','WindDir',...
                    'Pbar'};
arg_default('targetVarsIn',targetVarsInDefault);
arg_default('targetVarsOut',targetVarsOutDefault);
arg_default('PbarMult',1000);

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
else
    fprintf('\n*** File %s could not be opened!\n',fileName);
    dataOut=[];
    dataIn=[];
    Header=[];
    return
end
Header.numOfVars = length(Header.variableNames);
% at this point the number and the names of variables are extracted
% next: create the format string 
formatStr=[];
for kkk=1:Header.numOfVars
    formatStr=[formatStr '%q'];
end

% Load the file with each column being an array of cell strings
fid = fopen(fileName);
if fid > 0
    % read the first two lines in the file (each line is one cell)
    dataIn = textscan(fid,formatStr,'headerlines',1,'Delimiter',',','MultipleDelimsAsOne',1,'whitespace','\t'); %,'BufSize',20000);
    %headerLine = fgetl(fid);
    fclose(fid);
end

           

% find time vector column number
varInd = find(startsWith(Header.variableNames,"Date/Time"));
TimeVector = datenum(dataIn{varInd});%#ok<*FNDSB> % time

% now loop through all targetVarsIn and extract targetVarsOut
for cntVars = 1:length(targetVarsIn)
    varIn = char(targetVarsIn{cntVars});
    varOut = char(targetVarsOut{cntVars});
    varInd = find(startsWith(Header.variableNames,varIn)); %#ok<*EFIND>
    if ~isempty(varInd)
        tmpData.(varOut) = str2double(dataIn{varInd});
        if strcmp(varOut,'Pbar')
            tmpData.(varOut) = tmpData.(varOut) * PbarMult;
        end
    end
end

% create the output structure
fieldNames = fieldnames(tmpData);
nFields = length(fieldNames);
for cntRow=1:length(TimeVector)
    dataOut(cntRow).TimeVector = TimeVector(cntRow); %#ok<*AGROW>
    for cntFields = 1:nFields
        currentFieldName = char(fieldNames{cntFields});
        dataOut(cntRow).(currentFieldName) = tmpData.(currentFieldName)(cntRow);
    end
end

    


