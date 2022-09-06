function [x,TotalSamples,NN] = read_raw(FileName,NumOfChannels, MaxNumOfSamplesToPlot)

c = sprintf('fid = fopen(%s%s%s,%sr%s);',39,FileName,39,39,39);
eval(c);
if fid < 3
    return
end
status = fseek(fid,0,'eof');
TotalSamples  = ftell(fid)/2/NumOfChannels;
NN = min(MaxNumOfSamplesToPlot,TotalSamples);
status = fseek(fid,-NN*NumOfChannels*2,'eof');
x = fread(fid,[NumOfChannels,NN],'int16');
fclose(fid);

