function select_CR

h1 = findobj(gcf,'tag','CheckboxCR');
h2 = findobj(gcf,'tag','CRTraceCD');
h3 = findobj(gcf,'tag','CRTraceCE');
h4 = findobj(gcf,'tag','CRTraceCP');
h5 = findobj(gcf,'tag','CRTraceEC');

if ((get(h2,'Value')==get(h2,'Max'))|(get(h3,'Value')==get(h3,'Max'))|(get(h4,'Value')==get(h4,'Max'))|(get(h5,'Value')==get(h5,'Max')))
    set(h1,'Value',1);
else 
    set(h1,'Value',0);
end