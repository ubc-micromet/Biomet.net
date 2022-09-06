function calc_and_exit(varargin)
%
% This program runs new_calc_and_save and passes all 
% the input parameters to it.  Once the calculations are
% finished the program exists Matlab (reduces Desktop clutter)
% 

%Revisions:  
% Nov 4, 2004 - Function created Zoran

disp('Entering calc_and_exit')

try
	varargin{:};
	new_calc_and_save(varargin{:});
end
exit