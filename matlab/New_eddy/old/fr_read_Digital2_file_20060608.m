function [EngUnits,Header] = fr_read_Digital2_file(fileName)
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
        Header.hhourStartTime = fread(fid,[1,1],'float64');
        Header.hhourEndTime = fread(fid,[1,1],'float64');
        Header.instrumentDescription = setstr(fread(fid,[1,30],'char'));
        Header.Poly = NaN * ones(Header.NumOfChans,2);
        for i=1:Header.NumOfChans
            Header.Poly(i,1) = fread(fid,[1,1],'float32');
            Header.Poly(i,2) = fread(fid,[1,1],'float32');
        end
        fseek(fid,Header.Size,'bof');
        EngUnits = fread(fid,[Header.NumOfChans Inf],'int16')';
        fclose(fid);
        for i=1:Header.NumOfChans
           EngUnits(:,i) = polyval(Header.Poly(i,:),EngUnits(:,i));
        end
    end
