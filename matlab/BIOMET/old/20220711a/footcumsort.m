function y = footcumsort(x);
% cumsort(x) - calculate cumulative sum of a sorted matrix x
% Reference: book, page, equation, paper
%
% Usage:   y = cumsort(  [ 20  100 310
%                          30   
% (c) Bob Chen
%   

% Revisions:
%

[sortX,indX] = sort(x(:));
z=cumsum(sortX(end:-1:1));
y=x;
y(indX(end:-1:1))=z;