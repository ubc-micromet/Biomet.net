function stats = oy_read_rawstats(pth,years,ind)
%************************************************************
%
%
% Reads in oy flux stats 
%
%E.Humphreys     Sept 5, 2000
%************************************************************
N = 61; 

stats = zeros(length(ind),N);
file_num = [1:N];
for i = 1:N
   c = sprintf('[pth %sOY_Flux.%d%s]',39,file_num(i)+4,39);
   fileName = eval(c);
   tmp = read_bor(fileName,[],[],years,ind);
   stats(:,i) = tmp; 
end   

