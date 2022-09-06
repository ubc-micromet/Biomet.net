function [EngUnits,Header] = fr_read_AB_WPL_file(fileName);

fid = fopen(fileName,'r');
rawdata = fread(fid,inf,'int16');
fclose(fid);

totn = length(rawdata); % Grand total length of file (i.e. index of last record of the last field)

% Note: Index of data points start with 10 (i.e. first data point of first variable has index
% 10 (because first 9 fields belong to the header); the second variable start
% with index 11 and so on. The last index of last variable (i.e. Irga_T) is
% equal to totn; that of P is totn-1 and so on until the last index of
% first variable (u) is totn-8.
EngUnits = reshape(rawdata(10:end),9,(totn-9)./9)';

% u, v, w, Ts, s_c, s_v, P
EngUnits(:,1) = EngUnits(:,1)*.01;
EngUnits(:,2) = EngUnits(:,2)*.01;
EngUnits(:,3) = EngUnits(:,3)*.01;
EngUnits(:,4) = EngUnits(:,4)*.01;
EngUnits(:,5) = EngUnits(:,6)*.1;
EngUnits(:,6) = EngUnits(:,7)*.004;
EngUnits(:,7) = 60.+EngUnits(:,8)*.0184;
 
n = length(EngUnits(:,1)); % Number of data records in the file (normally 36000 at 20 Hz with no missing data)

Header = 'u, v, w, Ts, s_c, s_v, P,??,??';

return