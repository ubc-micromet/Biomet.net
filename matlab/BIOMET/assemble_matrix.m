function a = assemble_matrix(c)
%ASSEMBLE_MATRIX Assemble single value traces in to matrices
%    A = ASSEMBLE_MATRIX(C), where C of size [N M], reorders each row 
%    into a symetric matrix of the form 
%
%    C(i,1) C(i,2)  C(i,4)  C(i,7)  C(i,11) .
%    .      C(i,3)  C(i,5)  C(i,8)  C(i,12) .
%    .      .       C(i,6)  C(i,9)  C(i,13) .
%    .      .       .       C(i,10) C(i,14) .
%    .      .       .       .       C(i,15) .
%    .      .       .       .       .       .
%
%    For this to be possible S = -1/2 + sqrt(1/4 + 2 * M) must
%    yield an integer number for M. The result is returned in A, 
%    which is of size [S S N].
%
%    See also BLKDIAG_SP

% kai* Oct 31, 2002

[n m] = size(c);

% Test to see if a symetric matrix can be formed
s = -1/2 + sqrt(1/4 + 2 * m);
if mod(s,1) ~= 0
   disp('No symmetrix matrix can be formed from rows of input');
   a = [];
   return
end

% c contains the elements of the upper triangles of a, counted
% in the matlab way, i.e. down the first column first, then 
% down the next colum etc. 

% First, find the indices that represent the upper triangle
% and place c there
utri = triu(ones(s,s));
ind_u = find(utri(:));
a(:,ind_u) = c;

% To find symetric upper and lower triangle indices create an index
% matrix and flip it
mi = reshape([1:s^2]',s,s);
mi_flip = mi';
a(:,mi_flip(ind_u)) = a(:,ind_u);

% At this point reshape(a(1,:),s,s) will give a sym. matrix with the
% elements of c in the right places in the upper triangle.

a = reshape(a',s,s,n);
return


