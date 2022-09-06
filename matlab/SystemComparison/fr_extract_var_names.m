function var_names_out = fr_extract_var_names(str)

if length(str) > 1
   str = str(1);
end

% Assume the structure is the same for all elements
var_names = fieldnames(str);

k = 1;
for i = 1:length(var_names)
   var_val = getfield(str(1),char(var_names(i)));
   
   switch class(var_val)
   case 'char'
      disp('Do nothing')
   case 'double'
      var_names_out(k) = var_names(i);
      k = k + 1;
   case 'struct'
      % disp(char(var_names(i)))
      switch char(var_names(i))
      case 'Configuration'
         % Do nothing
      case 'Instrument'
         % Do latter
      otherwise % MiscVariable & EC systems
         var_sub_str = fr_extract_var_names(var_val);
   	   for j = 1:length(var_sub_str)
      	   var_names_out(k) = {[char(var_names(i)) '_' char(var_sub_str(j))]};
         end
      end
      
   otherwise
      disp(['Could not identify ' char(var_names(i))])
   end
end

      
