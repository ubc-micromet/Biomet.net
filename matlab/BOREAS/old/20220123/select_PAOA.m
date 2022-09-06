function select_PAOA

h1 = findobj(gcf,'tag','CheckboxPAOA');
h2 = findobj(gcf,'tag','PAOATraceCD');
h3 = findobj(gcf,'tag','PAOATraceCE');
h4 = findobj(gcf,'tag','PAOATraceCP');
h5 = findobj(gcf,'tag','PAOATraceEC');
h6 = findobj(gcf,'tag','PAOATraceCC');
h7 = findobj(gcf,'tag','PAOATraceCh');

if ((get(h2,'Value')==get(h2,'Max'))|(get(h3,'Value')==get(h3,'Max'))|(get(h4,'Value')==get(h4,'Max'))|(get(h5,'Value')==get(h5,'Max'))|(get(h6,'Value')==get(h6,'Max'))|(get(h7,'Value')==get(h7,'Max')))
    set(h1,'Value',1);
else 
    set(h1,'Value',0);
end