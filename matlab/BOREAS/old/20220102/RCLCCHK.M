function x = rclcchk(NewIndex,NewData,ch_num)
if exist('ch_num')~=1 | isempty(ch_num)
    ch_num = 5:88;
end
figure(1)
pth = 'r:\paoa\paoa\';
zoom on
t = read_bor([pth 'paoa_dt']) - 0.25;
t = t(NewIndex);
for i=ch_num
    c = sprintf('x=read_bor(%s%spaoa_%d.2_2%s);',39,pth,i,39);
    eval(c);
    x = x(NewIndex);
    c = sprintf('plot(t,[NewData(2:2:length(NewData),%d) x])',i);
    eval(c);
    title(sprintf('Plotting channel %d',i));
    grid on
    pause
end
x=0;
