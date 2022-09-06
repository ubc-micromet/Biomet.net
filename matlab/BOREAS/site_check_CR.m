function site_check_CR

%h = findobj(gcf,'style','checkbox');
%set(h,'value',0)
%set(gco,'value',3)

if (get(gco,'Value')==get(gco,'Max'))
    h1 = findobj(gcf,'tag','CRTraceCD');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','CRTraceCE');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','CRTraceCP');
    set(h1,'Value',1);
    h1 = findobj(gcf,'tag','CRTraceEC');
    set(h1,'Value',1);
else
    h1 = findobj(gcf,'tag','CRTraceCD');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','CRTraceCE');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','CRTraceCP');
    set(h1,'Value',0);
    h1 = findobj(gcf,'tag','CRTraceEC');
    set(h1,'Value',0);
end