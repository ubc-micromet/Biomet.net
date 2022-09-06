function site_check_HJP75

if (get(gco,'Value')==get(gco,'Max'))
    h1 = findobj(gcf,'tag','HJP75TraceCD');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','HJP75TraceCE');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','HJP75TraceEC');
    set(h1,'Value',1);
else
    h1 = findobj(gcf,'tag','HJP75TraceCD');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','HJP75TraceCE');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','HJP75TraceEC');
    set(h1,'Value',0);
end