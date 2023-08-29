figure(33);
tic
ind=1:length(t_fit);
for cnt1=65:130
    ind1=ind(cnt1:end);
    x = t_fit(ind1);
    y = c_fit(ind1);
    p=polyfit(x,y,2);
    if p(1)<0 
        fprintf('%d  %8.4f dcdt = %8.4f \n',cnt1,p(1),(2*p(1)*x(1)+p(2))/3600);
        plot(t_fit,c_fit,'.',x,y,x,polyval(p,x));
        break
%     else
%         fprintf('%d\n',cnt1);
%         plot(x,y)
    end
%    pause
end
toc