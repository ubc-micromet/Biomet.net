function [data_out, flag] = calc_sum_trace(tv, data_in, data_fill)
% Second level data processing function
%
% [data_out, flag] = calc_sum_traces(tv, data_in, data_fill)
%
% Computes the sum of multiple input traces and fills where no input is
% available
%
% The sum is taken across non-NaN elements in the rows of the matrix 
% data_in which contains  the traces in its columns
%
% flag: no of traces used in average
%
% (C) E. Humphreys          Dec 5, 2001
% (C) Kai Morgenstern	    File created:  14.08.00
%							Last modified: 14.08.00

% Revision: none

data_out = NaN * zeros(length(tv),1);		
n_out    = zeros(length(tv),1);	

if ~exist('data_fill','var')
   data_fill = [];
end 

[mm nn] = size(data_in);								%get size of input matrix
indf = find(mean(isfinite(data_in),2) == 1);		%find rows with all real numbers
data_out(indf,:) = sum(data_in(indf,:),2);		%calculate mean of each of these rows.
n_out(indf) =  nn;										%set flag to length of each row


%Get the rest of the indices that contains non-real numbers: NaN, inf, -inf:
indRest = find(mean(isfinite(data_in),2) < 1);   

for i = 1:length(indRest)  
   %find indices of real numbers in each row:
   ind = find(isfinite(data_in(indRest(i),:)));
   
   if ~isempty(ind)            
      data_out(indRest(i)) = sum(data_in(indRest(i),ind));          
      n_out(indRest(i)) = length(ind); 
   elseif ~isempty(data_fill)
      ind = find(isfinite(data_fill(indRest(i),:)));
      if ~isempty(ind)
         data_out(indRest(i)) = sum(data_fill(indRest(i),ind));
      else
         data_out(indRest(i)) = NaN;
      end
      n_out(indRest(i)) = -1;       
   end        
end
flag = n_out;