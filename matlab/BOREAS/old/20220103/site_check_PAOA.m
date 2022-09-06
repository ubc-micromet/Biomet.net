function site_check_PAOA

if (get(gco,'Value')==get(gco,'Max'))
    h1 = findobj(gcf,'tag','PAOATraceCD');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOATraceCE');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOATraceCP');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOATraceEC');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOATraceCC');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','PAOATraceCh');
    set(h1,'Value',1);
else
    h1 = findobj(gcf,'tag','PAOATraceCD');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','PAOATraceCE');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','PAOATraceCP');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','PAOATraceEC');
    set(h1,'Value',0);  
    h1 = findobj(gcf,'tag','PAOATraceCC');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','PAOATraceCh');
    set(h1,'Value',0); 
end