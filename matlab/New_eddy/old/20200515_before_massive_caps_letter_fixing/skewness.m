function [Sk] = skewness(x,flag);
%skewness(x,flag) where flag == 2 if bias is to be removed
%if x is a matric, output kurtosis statistic for each column

% E. Humphreys April 2003


if nargin < 2;
   flag = 1;
end

[m,n] = size(x);

switch flag
case 1
   for i = 1:n;
      Sk(i) = sum((x(:,i)-mean(x(:,i))).^3)./(length(x(:,i)).*(std(x(:,i))).^3);
   end   
case 2
   for i = 1:n;        
      Sk = sum((x(:,i)-mean(x(:,i))).^3)./((length(x(:,i))-1).*(std(x(:,i))).^3); %remove bias
   end      
end