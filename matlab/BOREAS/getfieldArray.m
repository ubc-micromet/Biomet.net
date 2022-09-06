function x = getfieldArray(Stats,fieldFormat)

n = length(fieldFormat);
c = [];
for i=1:2:n
   c = [c '''' fieldFormat{i} '''' ];
   if i+1 <= n
      c = [c  fieldFormat(i)];
   end
end
c = ['tmp = getfield(Stats(1),' c ');'];
try;
   eval(c);   
   M = length(tmp);
catch
   M = 1;
end

L = length(Stats);
x = NaN * zeros(L,M);
n = length(fieldFormat);
c = [];
for i=1:2:n
   c = [c '''' fieldFormat{i} '''' ];
   if i+1 <= n
      c = [c  fieldFormat(i)];
   end
end
c = ['x(i,1:M) = transpose(getfield(Stats(i),' c '));'];
for i = 1:L
   try;
      eval(c);   
   catch
      disp('err')
   end
end