function site_check_OY

if (get(gco,'Value')==get(gco,'Max'))
    h1 = findobj(gcf,'tag','OYTraceCD');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','OYTraceEC');
    set(h1,'Value',1);
else
    h1 = findobj(gcf,'tag','OYTraceCD');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','OYTraceEC');
    set(h1,'Value',0);
end