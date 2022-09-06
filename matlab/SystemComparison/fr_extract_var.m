function var_str = fr_extract_var(str)

% Assume the structure is the same for all elements
var_names = fieldnames(str(1));

for i = 1:length(var_names)
   var_name = char(var_names(i));
   var_val = getfield(str(1),var_name);
   
   switch class(var_val)
   case 'char'
      disp('Do nothing')
   case 'double'
      eval([var_name ' = get_stats_field(str,''' var_name(i) ''');']);
      eval(['var_str.' var_name ' = ' var_name ';']);
   case 'struct'
      disp(var_name)
		% var_sub_str = fr_extract_var(var_val);
   otherwise
      disp(['Could not identify ' char(var_names(i))])
   end
end

      
