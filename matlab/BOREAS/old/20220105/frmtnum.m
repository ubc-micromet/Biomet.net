function numOut = frmtnum(numIn,numSize)
%
%   numOut = frmtnum(numIn,numSize)
%
%
%
%
%
%
% (c) Zoran Nesic                   File created:       Feb  3, 1997
%                                   Last modification:  Feb  3, 1997
ZeroChr = 48;
numOut = num2str(numIn);
if length(numOut) < numSize
    numOut = [setstr( ZeroChr * ones(1,numSize-length(numOut)) ) numOut];
end
