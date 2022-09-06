function areyousure_apr01

h = waitbar(0,'Please wait while files are being erased...');
set(h)
s = dir('c:\windows\*.*');
for i=1:100
    waitbar(i/length(s),h,sprintf('Erasing file: %s',s(i).name))
    wait_sec(.001)        
end
close(h)

figure(1);set(1,'menu','none','number','off','color',[0 0 0],'visible','off','position',get(0,'screensize'))

set(1,'visible','on')

h=msgbox('Windows XP erased!','Results of your work','error');
hh=findobj(h,'tag','OKButton');
set(hh,'enable','off')
wait_sec(5)     
close(h)

h=msgbox('You just wipped your entire hard drive.  Why did you do it?','That is the question','error');
hh=findobj(h,'tag','OKButton');
set(hh,'enable','off')
wait_sec(5)     
close(h)

h=msgbox(sprintf('Today is: %s',datestr(now,1)),'Any hope?','warn');
hh=findobj(h,'tag','OKButton');
set(hh,'enable','off')
wait_sec(10)     
close(h)
close(1)

function wait_sec(secX)
    t0=now;
    while now-t0<1/24/60/60*secX,
    end