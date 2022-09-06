function [z] = realroot(x, y1, y2)

%		Problem:
%			When calculating the polynomial root of a negative value, say  
%		[(-27).^(1/3)], MATLAB gives a solution of 1.5000 + 2.5981i, instead 
%		of the one we are looking for (-3).  This is because that [(-27).^(1/3)]  
%		has three solutions, namely, 1.5000 + 2.5981i, 1.5000 - 2.5981i and -3. 
%		This can cause a problem when we want to do regression.
%
%		Remedy:
%			This function gives us the real root of a	negative value. 
%		
%		Inputs:
%			x: 	the polynomial
%			y1: 	the numerator of the power (y1./y2)
%			y2: 	the denominator of the power (y1./y2)
%
%		Outputs:
%			z:  	the real (y1/y2) root of x [z = x.^(y1./y2)]
%
%		Syntax:
%			[z] = realroot(x, y1, y2)
%
%		Created on:  17 Feb. 1998 by Zoran Nesic and Paul Yang
%		Modified on: 17 Feb. 1998
%
%		Revisions:
%

n = length(x);
z = NaN*ones(n,1);
for i = 1:n
	if (x(i) < 0 & rem(y2,2) > 0) 	% x is negative and y2 is an odd number
   	z(i) = -abs(x(i)).^(y1./y2);
	else
   	z(i) = x(i).^(y1./y2);
	end
end