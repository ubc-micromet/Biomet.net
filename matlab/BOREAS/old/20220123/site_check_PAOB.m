function site_check_PAOB

if (get(gco,'Value')==get(gco,'Max'))
    h1 = findobj(gcf,'tag','PAOBTraceCD');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOBTraceCE');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOBTraceCP');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOBTraceEC');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOBTraceCC');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOBTraceCh');
    set(h1,'Value',1);
else
    h1 = findobj(gcf,'tag','PAOBTraceCD');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','PAOBTraceCE');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','PAOBTraceCP');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','PAOBTraceEC');
    set(h1,'Value',0);  
    h1 = findobj(gcf,'tag','PAOBTraceCC');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','PAOBTraceCh');
    set(h1,'Value',0); 
end