function trace_str_out = autoCleanTraces( trace_str_in )
% This function creates an array of trace structures that contain the 
% cleaned data.  Data has been cleaned using the function clean_trace
% 
% Input:		'trace_str_in' - array of traces that already have been loaded with
%									from the database (ie they contain a filled data field)
%									function is usually used on conjuncture with read_data
% Ouput:		'trace_str_out' - array of traces that have been cleaned (ie the data
%									field has been changed to reflect cleaning procedures)
%

bgc = [0 0.36 0.532];

trace_str_out = [];

numberTraces = length( trace_str_in );   %number of traces in the input trace structure that need cleaning

%-------------------------------------------------------------------------
% First round - clean single trace
%-------------------------------------------------------------------------
disp('Performing automatic cleaning ...');
h = waitbar(0,'Performing automatic cleaning ...');
set(h,'Color',bgc);
set(get(h,'Children'),'Color',bgc,'LineWidth',0.5);
set(get(get(h,'Children'),'Title'),'Color',[1 1 1])
h1 = get(get(h,'Children'),'Children');
set(h1(1),'Color',[1 1 1]);

for countTraces = 1:numberTraces
   
   cln = clean_trace( trace_str_in(countTraces) );				%do the basic cleaning on the trace.   
         
   if ishandle(h)
     waitbar(countTraces/numberTraces);         
   end   
               
   trace_str_in(countTraces) = cln;

end

trace_str_out = trace_str_in;

if ishandle(h)
   close(h);
end

return

