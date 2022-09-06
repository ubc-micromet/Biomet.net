function select_YF

h1 = findobj(gcf,'tag','CheckboxYF');
h2 = findobj(gcf,'tag','YFTraceCD');
h3 = findobj(gcf,'tag','YFTraceEC');

if ((get(h2,'Value')==get(h2,'Max'))|(get(h3,'Value')==get(h3,'Max')))
    set(h1,'Value',1);
else 
    set(h1,'Value',0);
end