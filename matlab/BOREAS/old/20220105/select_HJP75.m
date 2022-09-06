function select_HJP75

h1 = findobj(gcf,'tag','CheckboxHJP75');
h2 = findobj(gcf,'tag','HJP75TraceCD');
h3 = findobj(gcf,'tag','HJP75TraceEC');
h4 = findobj(gcf,'tag','HJP75TraceCE');

if ((get(h2,'Value')==get(h2,'Max'))|(get(h3,'Value')==get(h3,'Max'))|(get(h4,'Value')==get(h4,'Max')))
    set(h1,'Value',1);
else 
    set(h1,'Value',0);
end