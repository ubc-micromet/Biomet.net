function lines = countNumberLines(fileName)


fid = fopen(fileName, 'rt');

if fid<0
  error(['Can''t open file for reading (' fileName ')'])
end

i = 0;

while(~feof(fid))
  fgetl(fid);
  i = i+1;
end

fclose(fid);

lines = i;