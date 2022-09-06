function select_OY

h1 = findobj(gcf,'tag','CheckboxOY');
h2 = findobj(gcf,'tag','OYTraceCD');
h3 = findobj(gcf,'tag','OYTraceEC');

if ((get(h2,'Value')==get(h2,'Max'))|(get(h3,'Value')==get(h3,'Max')))
    set(h1,'Value',1);
else 
    set(h1,'Value',0);
end