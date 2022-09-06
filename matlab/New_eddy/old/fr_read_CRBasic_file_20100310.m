function EngUnits = fr_read_CRBasic_file(fileName,paramDef)
% fr_read_CRBasic_file(fileName, paramDef) - load (CR1000/5000) data
%
% Inputs:
%   fileName    -       name of the ASCII file with data
%   parmDef     -       [numOfJunkColumns numOfDataColumns]
% Outputs:
%   EngUnits    -       matrix with numOfDataColumns of columns 
%
% Example:
%   fr_read_MPB1_file('D:\Mat_Data\MET-DATA\070215\MPB1_30min.20070215',[0,145]);
%   
% (c) Zoran Nesic           File created:           xxx   , 2004
%                           Last modification:      May  1, 2007

% Revisions (last one first)
%
% May 1, 2007
%   - Created a more generic function for reading CRBasic files using
%   fr_read_MPBx_file as the starting point.
% Jan 15, 2007
%   - Introduced parmDef parameter to make the function generic.  This
%   parameter will be set by the ini file.
%

% load everything as a big char array
fid=fopen(fileName,'r');
xx=char(fread(fid,inf,'uchar'))';
fclose(fid);

%find all '-1.#IND'
strIN = '-1.#IND';
ind=findstr(xx,strIN);
if ~isempty(ind)

    %create a matrix of indexes ind21 that point to where the replacement values
    % should go
    x=[0:length(strIN)-1];
    ind1=x(ones(length(ind),1),:);
    ind2=ind(ones(length(strIN),1),:)';
    ind21=ind1+ind2;

    % create a replacement string of the same length as the strIN 
    % (Manual procedure - count the characters!)
    strOUT = '    NaN';
    xx(ind21)=strOUT(ones(length(ind),1),:);

end

%find all '-1.QNAN'
strIN = '-1.#QNAN';
ind=findstr(xx,strIN);
if ~isempty(ind)

    %create a matrix of indexes ind21 that point to where the replacement values
    % should go
    x=[0:length(strIN)-1];
    ind1=x(ones(length(ind),1),:);
    ind2=ind(ones(length(strIN),1),:)';
    ind21=ind1+ind2;

    % create a replacement string of the same length as the strIN 
    % (Manual procedure - count the characters!)
    strOUT = '    NaN';
    xx(ind21)=strOUT(ones(length(ind),1),:);

end

strIN = '"NAN"';
ind=findstr(xx,strIN);
if ~isempty(ind)

    %create a matrix of indexes ind21 that point to where the replacement values
    % should go
    x=[0:length(strIN)-1];
    ind1=x(ones(length(ind),1),:);
    ind2=ind(ones(length(strIN),1),:)';
    ind21=ind1+ind2;

    % create a replacement string of the same length as the strIN 
    % (Manual procedure - count the characters!)
    strOUT = '  NaN';
    xx(ind21)=strOUT(ones(length(ind),1),:);

end

% store the new data into a temp file
tempFileName = 'c:\temp.junk';
fid = fopen(tempFileName,'w');
fwrite(fid,xx,'uchar');
%fprintf(fid,'%s',xx);
fclose(fid);

% reload the temp file using the textread
%formatStr = '%q %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
numOfChannels = sum(paramDef);
formatStr = '';
outputPar = '';
outputData = '';
for i = 1:numOfChannels
    if i==1
        formatStr = '%q ';
    else
        formatStr = [formatStr '%f '];
    end
    if i <= paramDef(1)
        outputPar = [outputPar 'junk,'];
    else
            outputPar =  [outputPar  'y' num2str(i-paramDef(1)) ','];
            outputData = [outputData 'y' num2str(i-paramDef(1)) ','];
    end
end    
outputPar = outputPar(1:end-1);
outputData = outputData(1:end-1);
% formatStr = '%q %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
% remove 4 header lines and use assume "," is used as a delimiter
%[junk,junk,junk,junk,co2,h2o,Pair,Idiag,u,v,w,Ts,Sdiag,tc1,tc2,tc3,tc4] = ...
%                textread(tempFileName,formatStr,'delimiter',',','headerlines',4);
%EngUnits = xx;
runString1 = sprintf('[%s] = textread(tempFileName,formatStr,%cdelimiter%c,%c,%c,%cheaderlines%c,4);',outputPar,39,39,39,39,39,39);
runString2 = sprintf('[EngUnits] = [%s];',outputData);
eval(runString1)
eval(runString2)
%EngUnits = [co2,h2o,Pair,Idiag,u,v,w,Ts,Sdiag,tc1,tc2,tc3,tc4];

    