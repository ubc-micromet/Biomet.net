function [var_names] = fcrn_extract_var(stats_name,system_names,variable_info,generic_names)
% fcrn_extract_var - Extract variable info from stats structure
%                    and assign it in the caller workspace
%
% [var_names] = fcrn_extract_var(stats_name,system_names,variable_info,generic_names)

if ~exist('generic_names') | isempty(generic_names)
   generic_names = system_names;
end

[m,n_var] = size(variable_info);
n_sys = length(system_names);

j = 1;
for k = 1:n_var
   for i = 1:n_sys
      var_names(j) = {[char(variable_info(2,k)) '_' char(generic_names(i))]};
      % In the case of an instrument, replase brackets
      var_names(j) = strrep(var_names(j),'(','_');
      var_names(j) = strrep(var_names(j),')','');
      field_name    = [char(system_names(i)) '.' char(variable_info(1,k))];
      cmd = ['[' char(var_names(j)) ',tv] = get_stats_field(' stats_name ',''' field_name ''');'];
      evalin('caller',cmd);
      disp(['Extracted ' char(var_names(j))]);
      j = j+1;
   end
end

return
