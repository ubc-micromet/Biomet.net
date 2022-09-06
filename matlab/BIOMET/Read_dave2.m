function all_dave2 = read_dave2(pth,years,ind)
%************************************************************
%
%
% Reads in interception data 
%
%E.Humphreys     Nov 1, 1998
%Revisions, Nov 23, 2000 - brought indexing up to date
%************************************************************
N = 26; 
pth = [pth 'dave\'];

all_dave2 = zeros(length(ind),N);
file_num = [1:N];
for i = 1:N
   c = sprintf('[pth %sdave2.%d%s]',39,file_num(i),39);
   fileName = eval(c);
   tmp = read_bor(fileName,[],[],years,ind);
   all_dave2(:,i) = tmp; 
end   


%See dave_read_me.txt for data allocations