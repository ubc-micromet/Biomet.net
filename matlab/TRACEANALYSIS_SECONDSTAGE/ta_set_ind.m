function ind = ta_set_ind(ind1,ind2,operation)
% ind = ta_set_ind(ind1,ind2,operation)
%
% ta_set_ind when ind1 and ind2 are indecies to yearly time vectors 
% returns the values from ind1 and ind2 as specified by operation.  
% The function assumes that ind1 and ind2 are sorted.
% 
% Possible operations: 
% 'union' - set union of ind1 and ind2
% 'diff'  - set difference between ind1 and ind2
% 
% kai* Jan 14, 2002

if ~exist('operation') | isempty(operation)
   operation = 'union';
end

if size(ind1,1)==1, ind1 = ind1.'; rowvec = 1; end
if size(ind2,1)==1, ind2 = ind2.'; rowvec = 1; end
ind_max = max([ind1;ind2]);

vec1 = zeros(ind_max,1);
vec1(ind1) = 1;

vec2 = zeros(ind_max,1);
vec2(ind2) = 1;

switch operation
case 'union'
   ind = find(vec1==1 | vec2==1);
case 'diff'
   ind = find(vec1==1 & vec2==0);
end   
   
