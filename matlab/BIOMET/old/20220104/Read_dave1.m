function all_dave1 = read_dave1(pth,years,ind)
%************************************************************
%
%
% Reads in interception data 
%
%E.Humphreys     Nov 1, 1998
%************************************************************
N = 17; 
pth = [pth 'dave\'];

all_dave1 = zeros(length(ind),N);
file_num = [1:N];
for i = 1:N
   c = sprintf('[pth %sdave1.%d%s]',39,file_num(i),39);
   fileName = eval(c);
   tmp = read_bor(fileName,[],[],years,ind);
   all_dave1(:,i) = tmp; 
end   

%See dave_read_me.txt for data allocations