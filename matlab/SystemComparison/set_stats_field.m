function Stats = set_stats_field(Stats,field,val)
%Stats = set_stats_field(Stats,field,val)
%
%Function to loop through Stats structure to set data for specified fields.  
%Data may be scalars or vectors but not matrices.

% kai*  May 13, 2004 - based on get_stats_field
% Revisions: 

err_flag = 1;
L  = length(Stats);
x  = [];
for i = 1:L
   try,
      eval(['Stats(i).' field ' = val(i);']);
      err_flag = 0;
   catch, 
      eval(['Stats(i).' field ' = NaN;']);
   end
 end
 
 if err_flag
    disp(['Could not set ' field]);
 end
 