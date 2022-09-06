function [EngUnits,Header] = fr_read_Digital2_file(fileName)
%
% (c) Zoran Nesic               File created:       ~2002
%                               Last modification: June 28, 2009
%
% Revisions:
%   June 28, 2009 (Zoran)
%      - Bug fixes for reshaping when reading raw data
%      - Got program to handle properly LI7000 raw data files
%        in particular "DATA" keyword.
%   June 23, 2009 (Zoran)
%      - Made this function universal.  It can now read both
%        binary files and raw data files collected by UBC_GII.
%        It uses the first letter in the extension to figure out
%        if the file type is RAW (raw: *.b*, binary: anything else)
%   June 8, 2006 (Zoran)
%       - added conversion of VisualBasic time vector to Matlab time vector
%
VB2MatlabDateOffset = 693960;

% Decide on the file type (RAW or Binary) based on the first
% letter of the file name extension. If "B" then it's RAW.
indDot = find(fileName=='.');
if indDot > 0
    if upper(fileName(indDot(end)+1)) == 'B'
        fileType = 2;   % RAW
    else
        fileType = 1;   % BINARY
    end
end

    fid = fopen(fileName,'rb');
    if fid < 3
        EngUnits = NaN;
        Header = NaN;
    else
        fseek(fid,0,1);
    %disp(['File length: ' num2str(ftell(fid))])
        fseek(fid,0,-1);
        Header.Version = fread(fid,[1,7],'*char');
        Header.Size = fread(fid,[1,1],'int16') * 1000;
        Header.NumOfChans = fread(fid,[1,1],'int16');
        Header.SampleFreq = fread(fid,[1,1],'float32');
        Header.hhourStartTime = fread(fid,[1,1],'float64')+VB2MatlabDateOffset;
        Header.hhourEndTime = fread(fid,[1,1],'float64')+VB2MatlabDateOffset;
        Header.instrumentDescription = fread(fid,[1,30],'*char');
        Header.Poly = NaN * ones(Header.NumOfChans,2);
        for i=1:Header.NumOfChans
            Header.Poly(i,1) = fread(fid,[1,1],'float32');
            Header.Poly(i,2) = fread(fid,[1,1],'float32');
        end
        fseek(fid,Header.Size,'bof');
        if fileType == 1
            % It's a binary data file 
            EngUnits = fread(fid,[Header.NumOfChans Inf],'int16')';
            fclose(fid);
            for i=1:Header.NumOfChans
               EngUnits(:,i) = polyval(Header.Poly(i,:),EngUnits(:,i));
            end
        else
            % It's raw data file.
            % First load one line to see if the first line is complete
            % (raw data collection often creates incomplete first and/or last
            % lines)
            firstLine=fgetl(fid);
            % see if the first line has all the data in
            % first create a regular expression that catches all numbers
            % with or without decimal point
            patternNum = '(\w*[.]\w*)|\w*\S*';
            % then find all numbers
            firstLineNumbers = regexp(firstLine, patternNum, 'match');
            numRead = length(firstLineNumbers);
            if ~isempty(firstLineNumbers) && strcmp(firstLineNumbers(1),'DATA')
                instrumentTypeLI7000 = 1;
            else
                instrumentTypeLI7000 = 0;
            end
            % test if the first line is complete
            % add an extra channel if data comes from LI-7000 
            % to compensate for the reserved work DATA that it uses to
            % start a line            
            if numRead + instrumentTypeLI7000 == Header.NumOfChans
                % if the line complete rewind to the beginning of the first
                % line again (you are going to need it).  Otherwise line will
                % be ignored.
                fseek(fid,Header.Size,'bof');
            end
            if instrumentTypeLI7000 == 1
                % for LI7000 data use a special format that takes care of
                % the "DATA" keyword
                % first create proper format string:
                frmStr = 'DATA';
                for i = 1:Header.NumOfChans
                    frmStr = [frmStr ' %f'];
                end
                frmStr = [frmStr '\n'];
            else
                % for all other cases use a simple format string
                frmStr = '%f';
            end

            % read all numbers in a vector
            EngUnits = fscanf(fid,frmStr);
            
            % reshape the vector into the matrix and ignore incomplete last
            % line (function floor rounds the number of rows)
            %EngUnits = reshape(EngUnits,Header.NumOfChans,floor(length(EngUnits)/Header.NumOfChans))';
            L = floor(length(EngUnits)/Header.NumOfChans);
            EngUnits = reshape(EngUnits(1:Header.NumOfChans*L),Header.NumOfChans,L)';
            fclose(fid);
        end
    end
