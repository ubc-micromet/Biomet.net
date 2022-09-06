function c_out = blkdiag_sp(c)
%BLKDIAG_SP  Block diagonal concatenation of square
%            input matrices of dimension [m m n].
%
%                             |C(:,:,1) 0        .. 0|
%   Y = BLKDIAG(C)  produces  |0        C(:,:,2) .. 0|
%                             |0        0        ..  |
%
%   See also FULL_SP, DIAG, HORZCAT, VERTCAT
   
% (c) Kai Morgenstern   File created:       Oct  1, 2002
%                       Last modification:  Oct  5, 2002

[m1 m2 n] = size(c);

if m1 ~= m2
   disp('Input matrices not square - returning');
   c_out = [];
   return
else
   m = m1;
end

w = m*m;

% Example used to explain this:
% Create a matrix like this:
% c(:,:,1) = reshape(1:9,3,3);
% c(:,:,2) = reshape((1:9)+9,3,3);
% and try c(:)

% Target shape for c with org. size 2x3x3:
% (11) (12) (13)
% (21) (22) (23)
% (31) (32) (33)
%               (44) (45) (46)
%               (54) (55) (56)
%               (64) (65) (66)
%
% The column vector c(:) contains these elements in the following order 
% (11) (21) (31) (12) (22) (23) (13) (23) (33)...
%   (44) (54) (64) (45) (55) (65) (46) (56) (66)...

% Row indices for the target shape

% original index structure
org   = [ [1:m]' * ones(1,n*m) ];
%         1 1 1 1 1 1
% org   = 2 2 2 2 2 2
%         3 3 3 3 3 3
shift = [ [0:3:3*n-1]' * ones(1,3) ]';
%         0 3
% shift = 0 3
%         0 3
ind_sp_i = org + [shift(:) * ones(1,3)]';
%             1 1 1 4 4 4
% org+shift = 2 2 2 5 5 5 => i(:) = 123123123456456456
%             3 3 3 6 6 6

% Column indices
ind_sp_j      = [ones(m,1) * [1:m*n] ];
%     1 2 3 4 5 6
% i = 1 2 3 4 5 6 => i(:) = 111222333444555666
%     1 2 3 4 5 6
c_out  = sparse(ind_sp_i(:),ind_sp_j(:),c(:),m*n,m*n);

return