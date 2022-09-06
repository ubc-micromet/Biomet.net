function[dataOut] = hhr_profile_e(t,s,k);
% Program to calculate half hour averages of profile data
%  - to be run after program calc_profile.m which finds 1 min averages of
%	profile data
%
%  Input:  t = matrix of times
%          s = matrix of values to be averaged
%          k = min values to include
%
%  Output: dataOut = matrix with first column equal to end of half hour and next columns
%    eg for CO2 profile :
%        [timeSer(PST) level1(30cm or 1m or 4m) level2(12 m) level3(27 m) level4(42.74 m);
%
%	Elyn Humphreys					Oct 9, 1998
%
N = size(s,2)
t_new = t;
s_new = s;

for i =1:N
   ind = find(t(:,i) <=datenum('09-Aug-1998 21:00:00')  | t(:,i) >= datenum('24-Aug-1998 01:00:00'));
   t_new(ind,i) = NaN;
   s_new(ind,i) = NaN;
end

for i=1:N
   ind = find(s_new(:,i)  < k);
   [s_new(:,i)] = clean(s_new(:,i), 2, ind);
end

X = round((datenum('24-Aug-1998 01:00:00')-datenum('09-Aug-1998 21:00:00')).*48);
dataOut = zeros(X,5);
for i =1:X
   m = datenum('09-Aug-1998 21:00:00')+i.*(1/48);
   n = datenum('09-Aug-1998 21:00:00')+(i+1).*(1/48);
   dataOut(i,1) = n;
   for j=1:N
      tmp = find(t_new(:,j) >= m & t_new(:,j) <n);
      ind = find(~isnan(s_new(tmp,j)));
      dataOut(i,1+j) = mean(s_new(tmp(ind),j));
      end
 end
