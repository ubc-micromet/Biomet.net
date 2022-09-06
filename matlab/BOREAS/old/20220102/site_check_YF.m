function site_check_YF

if (get(gco,'Value')==get(gco,'Max'))
    h1 = findobj(gcf,'tag','YFTraceCD');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','YFTraceEC');
    set(h1,'Value',1);
else
    h1 = findobj(gcf,'tag','YFTraceCD');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','YFTraceEC');
    set(h1,'Value',0);
end