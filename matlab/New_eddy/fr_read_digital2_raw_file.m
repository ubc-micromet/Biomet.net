function [EngUnits,Header] = fr_read_digital2_raw_file(fileName)
%
% (c) Zoran Nesic               File created:      Mar 27, 2009
%                               Last modification: Mar 27, 2009
%
% Revisions:
%
VB2MatlabDateOffset = 693960;
    fid = fopen(fileName,'rb');
    if fid < 3
        EngUnits = NaN;
        Header = NaN;
    else
        fseek(fid,0,1);
    %disp(['File length: ' num2str(ftell(fid))])
        fseek(fid,0,-1);
        Header.Version = setstr(fread(fid,[1,7],'char'));
        Header.Size = fread(fid,[1,1],'int16') * 1000;
        Header.NumOfChans = fread(fid,[1,1],'int16');
        Header.SampleFreq = fread(fid,[1,1],'float32');
        Header.hhourStartTime = fread(fid,[1,1],'float64')+VB2MatlabDateOffset;
        Header.hhourEndTime = fread(fid,[1,1],'float64')+VB2MatlabDateOffset;
        Header.instrumentDescription = setstr(fread(fid,[1,30],'char'));
        Header.Poly = NaN * ones(Header.NumOfChans,2);
        for i=1:Header.NumOfChans
            Header.Poly(i,1) = fread(fid,[1,1],'float32');
            Header.Poly(i,2) = fread(fid,[1,1],'float32');
        end
        fseek(fid,Header.Size,'bof');
        s = fscanf(fid,'%200s');
        indData = strfind(s,'DATA');
        fseek(fid,Header.Size+indData(1)-1,'bof');
        dataFormat = 'DATA';
        for i=1:Header.NumOfChans-1
            dataFormat = [dataFormat '%f\t'];
        end
        dataFormat = [dataFormat '%f\n'];
        %EngUnits = fscanf(fid,'DATA%f\t%f\t%d\t%d\t%d\t%d\t%f\t%f\t%f\t%f\t%f\r');
        EngUnits = fscanf(fid,dataFormat);
        EngUnits = reshape(EngUnits,[Header.NumOfChans floor(size(EngUnits,1)/Header.NumOfChans) ])';
        fclose(fid);
    end
