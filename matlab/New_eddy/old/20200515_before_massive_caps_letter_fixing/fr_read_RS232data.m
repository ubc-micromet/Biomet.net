function [x_data, x_header] = fr_read_RS232data(fileName)

fid = fopen(fileName,'rb');
if fid < 3
    x_data = NaN;
    x_header = NaN;
else
    fseek(fid,0,1);
%disp(['File length: ' num2str(ftell(fid))])
    fseek(fid,0,-1);
    x_header.Version = setstr(fread(fid,[1,7],'char'));
    x_header.Size = fread(fid,[1,1],'int16') * 1000;
    x_header.NumOfChans = fread(fid,[1,1],'int16');
    x_header.SampleFreq = fread(fid,[1,1],'float32');
    x_header.hhourStartTime = fread(fid,[1,1],'float64');
    x_header.hhourEndTime = fread(fid,[1,1],'float64');
    x_header.instrumentDescription = setstr(fread(fid,[1,30],'char'));
    x_header.Poly = NaN * ones(x_header.NumOfChans,2);
    for i=1:x_header.NumOfChans
        x_header.Poly(i,1) = fread(fid,[1,1],'float32');
        x_header.Poly(i,2) = fread(fid,[1,1],'float32');
    end
    fseek(fid,x_header.Size,'bof');
    x_data = fread(fid,[x_header.NumOfChans Inf],'int16')';
    fclose(fid);
    for i=1:x_header.NumOfChans
       x_data(:,i) = polyval(x_header.Poly(i,:),x_data(:,i));
    end
end
