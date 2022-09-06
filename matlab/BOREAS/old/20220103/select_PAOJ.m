function select_PAOJ

h1 = findobj(gcf,'tag','CheckboxPAOJ');
h2 = findobj(gcf,'tag','PAOJTraceCD');
h3 = findobj(gcf,'tag','PAOJTraceCE');
h4 = findobj(gcf,'tag','PAOJTraceCP');
h5 = findobj(gcf,'tag','PAOJTraceEC');
h6 = findobj(gcf,'tag','PAOJTraceCC');
h7 = findobj(gcf,'tag','PAOJTraceCh');

if ((get(h2,'Value')==get(h2,'Max'))|(get(h3,'Value')==get(h3,'Max'))|(get(h4,'Value')==get(h4,'Max'))|(get(h5,'Value')==get(h5,'Max'))|(get(h6,'Value')==get(h6,'Max'))|(get(h7,'Value')==get(h7,'Max')))
    set(h1,'Value',1);
else 
    set(h1,'Value',0);
end