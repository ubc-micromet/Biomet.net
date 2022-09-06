function [c,ia,ib] = intersect(a,b,flag)
%INTERSECT Set intersection.
%   INTERSECT(A,B) when A and B are vectors returns the values common
%   to both A and B. The result will be sorted.  A and B can be cell
%   arrays of strings.
%
%   INTERSECT(A,B,'rows') when A are B are matrices with the same
%   number of columns returns the rows common to both A and B.
%
%   INTERSECT(A,B,'tv') when A are B are time vectors, i.e. both are sorted
%   and only contain unique elements, so these operations can be omitted.
%
%   [C,IA,IB] = INTERSECT(...) also returns index vectors IA and IB
%   such that C = A(IA) and C = B(IB) (or C = A(IA,:) and C = B(IB,:)).
%
%   See also UNIQUE, UNION, SETDIFF, SETXOR, ISMEMBER.

%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 1.15 $  $Date: 1998/04/02 18:01:45 $

%   Cell array implementation in @cell/intersect.m

error(nargchk(2,3,nargin));

if nargin==2,
  if length(a)~=prod(size(a)) | length(b)~=prod(size(b))
    error('A and B must be vectors or ''rows'' must be specified.');
  end
  rowvec = (size(a,1)==1) | (size(b,1)==1);

  % Make sure a and b contain unique elements.
  [a,ia] = unique(a(:));
  [b,ib] = unique(b(:));

  % Find matching entries
  [c,ndx] = sort([a;b]);
  d = find(c(1:end-1)==c(2:end));
  ndx = ndx([d;d+1]);
  c = c(d);
  n = length(a);
  
  if rowvec, c = c.'; ia = ia.'; ib = ib.'; end
elseif strcmp(flag,'tv')
 if length(a)~=prod(size(a)) | length(b)~=prod(size(b))
    error('A and B must be vectors or ''rows'' must be specified.');
  end
  rowvec = (size(a,1)==1) | (size(b,1)==1);

  % Make sure a and b contain unique elements.
  % [a,ia] = unique(a(:));
  % [b,ib] = unique(b(:));
  a = a(:); ia = [1:length(a)]';
  b = b(:); ib = [1:length(b)]';

  % Find matching entries
  [min_len ind_min] = min([length(a) length(b)]);
  ab(1:2:2*min_len,1)     = a(1:min_len);
  ab(2:2:(2*min_len+1),1) = b(1:min_len);
  ab_log(1:2:2*min_len,1)   = [1:min_len]';
  ab_log(2:2:(2*min_len+1)) = [1:min_len]'+length(a);
  if ind_min==1
     ab((2*min_len+2):((2*min_len+2)+length(b)-min_len)-1) = b(min_len+1:length(b));
     ab_log((2*min_len+2):((2*min_len+2)+length(b)-min_len)-1) = [min_len+1:length(b)]+length(a);
  else
    ab((2*min_len+2):((2*min_len+2)+length(a)-min_len)-1) = a(min_len+1:length(a));
    ab_log((2*min_len+2):((2*min_len+2)+length(a)-min_len)-1) = min_len+1:length(a);
  end
  
  [c,ndx] = sort(ab);
  d = find(c(1:end-1)==c(2:end));
  ndx = ab_log(ndx([d;d+1]));
  c = c(d);
  n = length(a);
  
  if rowvec, c = c.'; ia = ia.'; ib = ib.'; end
elseif strcmp(flag,'rows')
  % Make sure a and b contain unique elements.
  [a,ia] = unique(a,flag);
  [b,ib] = unique(b,flag);
  
  % Automatically pad strings with spaces
  if isstr(a) & isstr(b),
    if size(a,2) > size(b,2), 
      b = [b repmat(' ',size(b,1),size(a,2)-size(b,2))];
    end
    if size(a,2) < size(b,2), 
      a = [a repmat(' ',size(a,1),size(b,2)-size(a,2))];
    end
  end
  if size(a,2)~=size(b,2) & ~isempty(a) & ~isempty(b)
    error('A and B must have the same number of columns.');
  end
  % Find matching entries
  [c,ndx] = sortrows([a;b]);
  [m,n] = size(c);
  if m > 1 & n ~= 0
    % d indicates the location of matching entries
    d = c(1:end-1,:)==c(2:end,:);
  else
    d = zeros(m-1,n);
  end
  d = find(all(d,2));
  ndx = ndx([d;d+1]);
  c = c(d,:);
  n = size(a,1);
  
  % Automatically deblank strings
  if isstr(a) & isstr(b),
    c = deblank(c);
  end
end

if nargout>1,
  d = ndx > n;
  ia = ia(ndx(~d));
  ib = ib(ndx(d)-n);
end
