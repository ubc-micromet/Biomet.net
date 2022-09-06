function x = dispTime;
%
%	function x = dispTime;
%
%	This function returns current time and date.
%
%	x - current time and date
%
%	if no output arguments than the function displays the output
%
x = clock;
x = sprintf('%d-%d-%d at %d:%d', x(1:5) );
if nargout == 0
	disp(x);
	x = [];
end
