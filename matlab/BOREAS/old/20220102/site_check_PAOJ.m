function site_check_PAOJ

if (get(gco,'Value')==get(gco,'Max'))
    h1 = findobj(gcf,'tag','PAOJTraceCD');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOJTraceCE');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOJTraceCP');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOJTraceEC');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOJTraceCC');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOJTraceCh');
    set(h1,'Value',1);
else
    h1 = findobj(gcf,'tag','PAOJTraceCD');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','PAOJTraceCE');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','PAOJTraceCP');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','PAOJTraceEC');
    set(h1,'Value',0);  
    h1 = findobj(gcf,'tag','PAOJTraceCC');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','PAOJTraceCh');
    set(h1,'Value',0); 
end