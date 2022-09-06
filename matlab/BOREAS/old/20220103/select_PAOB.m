function select_PAOB

h1 = findobj(gcf,'tag','CheckboxPAOB');
h2 = findobj(gcf,'tag','PAOBTraceCD');
h3 = findobj(gcf,'tag','PAOBTraceCE');
h4 = findobj(gcf,'tag','PAOBTraceCP');
h5 = findobj(gcf,'tag','PAOBTraceEC');
h6 = findobj(gcf,'tag','PAOBTraceCC');
h7 = findobj(gcf,'tag','PAOBTraceCh');

if ((get(h2,'Value')==get(h2,'Max'))|(get(h3,'Value')==get(h3,'Max'))|(get(h4,'Value')==get(h4,'Max'))|(get(h5,'Value')==get(h5,'Max'))|(get(h6,'Value')==get(h6,'Max'))|(get(h7,'Value')==get(h7,'Max')))
    set(h1,'Value',1);
else 
    set(h1,'Value',0);
end