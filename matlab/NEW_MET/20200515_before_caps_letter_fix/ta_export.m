function ta_export(traces_str, out_path)

bgc = [0 0.36 0.532];
disp('Exporting data ...');

h = waitbar(0,'Exporting data....');
set(h,'Color',bgc);
set(get(h,'Children'),'Color',bgc,'LineWidth',0.5);
set(get(get(h,'Children'),'Title'),'Color',[1 1 1])
% h1 = get(get(h,'Children'),'Children');
% set(h1(1),'Color',[1 1 1]);
%disp('***$$$$####  Rename function export.m from new_met.  There is a built in function in Matlab with the same name!');

numberTraces = length( traces_str );

file_opts.out_path = out_path;
file_opts.format   = 'bnc';
file_opts.days     = [0 367]; % This ensures that the whole trace is exported!

for countTraces=1:numberTraces
   trc = traces_str(countTraces);
   trace_export(file_opts,trc);      
   
   if ishandle(h)
      waitbar(countTraces/numberTraces);         
   end   
end      

if ishandle(h)
   close(h);
end
