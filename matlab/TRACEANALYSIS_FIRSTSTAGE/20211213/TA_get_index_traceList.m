function answer = ta_get_index_traceList(trc_names,list_of_traces)
%This function returns the indices of the traces listed in 'trc_names' 
%within the list of all traces present in the ini_file.
%
%Input:	'trc_names'			-a character array of trace variableNames
%			'list_of_traces'	-contains list of all traces present in the ini_file.
%Output:	'answer'				-contains indices of trc_names within list_of_traces.


answer = [];
if ~exist('trc_names') | ~exist('list_of_traces') | ...
      isempty(trc_names) | isempty(list_of_traces)
   return
end
%First, remove all white space since it should not be present(variable names of traces
%should only contain character and underscores):
ind = find(trc_names ~=32 & trc_names ~=9);
trc_names = trc_names(ind);

%First seperate the string between commas:
ind = find(trc_names == ','); 
temp = trc_names;

%parse the string into a 'cell' data type:
if ~isempty(ind)
   temp = {trc_names(1:ind(1)-1)};
   for j=1:length(ind)
      if length(ind) >= j+1
         temp = [temp {trc_names(ind(j)+1:ind(j+1)-1)}];
      else
         temp = [temp {trc_names(ind(j)+1:end)}];
      end            
   end
end 
%Get the indices of all traces:
[val bi ci]=intersect(temp,{list_of_traces.variableName});
% kai* 10 Nov, 2000
% Before, this read
%   answer =  ci';
% The new MATLAB returns ci as a column. So it is reversed to a row if neccessary
[n,m] = size(ci);
if n<m
   answer = ci;
else 
   answer =  ci';
end
% end kai*



