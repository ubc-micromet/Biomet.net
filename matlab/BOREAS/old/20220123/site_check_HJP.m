function site_check_HJP

if (get(gco,'Value')==get(gco,'Max'))
    h1 = findobj(gcf,'tag','HJP02TraceCD');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','HJP02TraceEC');
    set(h1,'Value',1);
else
    h1 = findobj(gcf,'tag','HJP02TraceCD');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','HJP02TraceEC');
    set(h1,'Value',0);
end