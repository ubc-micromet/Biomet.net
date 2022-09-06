function x=dlmread1(fileName)

dlm = ',';
fid = fopen(fileName,'rt');
if fid < 3
   error 'File does not exist!'
end

lin = fgets(fid);
row = 0;
while ~isempty (lin) & ~isequal(lin,-1)
   row = row + 1;
   lin = fgets(fid);
end
x = zeros(row,1);
fseek(fid,0,-1);
row = 0;
lin = fgets(fid);
while ~isempty (lin) & ~isequal(lin,-1)
   row = row + 1;
   ind = find(lin == dlm);
   if ~isempty(ind)
      ind = [0 ind];
      for i=2:length(ind);
         x(row,i-1) = str2num(lin(ind(i-1)+1:ind(i)-1));
      end
   end
   lin = fgets(fid);
end

fclose(fid);
row
   