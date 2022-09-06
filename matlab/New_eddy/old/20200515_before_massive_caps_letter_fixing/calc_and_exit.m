function calc_and_exit(varargin)
%
% This program runs new_calc_and_save and passes all 
% the input parameters to it.  Once the calculations are
% finished the program exists Matlab (reduces Desktop clutter)
% 

%Revisions:  
% Jun 30, 2008 - Nick modified to include calibration extraction
% Nov 4, 2004 - Function created Zoran

disp('Entering calc_and_exit')

varargin{:};
try
   extract_LI6262_all_cal(varargin{1},[],0);
catch
    disp(['Calibration extraction failed ' datestr(now,0) ]);
end

try
	new_calc_and_save(varargin{:});
end
exit