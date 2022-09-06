function c_out = full_sp(c,n,m)
%FULL_SP Undo BLKDIAG_SP
%   A = FULL_SP(C,N,M) returns the elements of the block
%   diagonal symetric sparse matrix C in a full array of
%   dimnesion [N M M]
%
%   See also BLKDIAG_SP

% (c) Kai Morgenstern   File created:       Oct  1, 2002
%                       Last modification:  Oct  5, 2002

% c = blk_diag(c); c = full_sp(c);

% Row indices - see blkdiag_sp for explanation

org   = [ [1:m]' * ones(1,n*m) ];
shift = [ [0:m:m*n-1]' * ones(1,m) ]';
ind_sp_i = org + [shift(:) * ones(1,m)]';

% Column indices
ind_sp_j      = [ones(m,1) * [1:m*n] ];

% find(c) does not work since there might be zero elements that
% have to be carried over into the output. So we create a sparse 
% matrix that has ones at every element that should be extracted
ext = sparse(ind_sp_i,ind_sp_j,1,m*n,m*n);
c_out = c + ext;

[dumi,dumj,c_out] = find(c_out);

c_out = reshape(c_out-1,m,m,n);

return