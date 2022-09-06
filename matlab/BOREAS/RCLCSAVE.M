%
% rclcsave.m
%
%
%
%
%
% (c) Zoran Nesic               File created:       Feb  6, 1997
%                               Last modification:  Sep 12, 1998
%
load c:\cd-rom\boreas_97_recalc\fixed
pthIn = 'c:\cd-rom\paoa\paoa_';
pthOut = 'c:\cd-rom\paoa1\paoa_';
N = length(NewIndex);
PageInd =  [1:2:N*2]-1;
for i=5:88
    for j = 1:2
        c = sprintf('x = read_bor(%s%s%d.%d_%d%s);',39,pthIn,i,j,2,39);
        %disp(c)
        eval(c)
        x(NewIndex) = NewData(PageInd+j,i);
        c = sprintf('save_bor(%s%s%d.%d_%d%s,1,x);',39,pthOut,i,j,2,39);
        %disp(c)
        eval(c)
    end
    fprintf('%d\r',i);
end
