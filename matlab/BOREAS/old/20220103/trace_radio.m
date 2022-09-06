function trace_radio

h = findobj(gcf,'style','radiobutton');
set(h,'value',0)
set(gco,'value',3)
if strcmp(get(gco,'tag'),'Radiobutton4')
    h1 = findobj(gcf,'string','from:');
    set(h1,'visible','on');
    h1 = findobj(gcf,'string','to:');
    set(h1,'visible','on');
    h1 = findobj(gcf,'tag','fromDOY');
    set(h1,'visible','on');
    h1 = findobj(gcf,'tag','toDOY');
    set(h1,'visible','on');
else
    h1 = findobj(gcf,'string','from:');
    set(h1,'visible','off');
    h1 = findobj(gcf,'string','to:');
    set(h1,'visible','off');
    h1 = findobj(gcf,'tag','fromDOY');
    set(h1,'visible','off');
    h1 = findobj(gcf,'tag','toDOY');
    set(h1,'visible','off');
end