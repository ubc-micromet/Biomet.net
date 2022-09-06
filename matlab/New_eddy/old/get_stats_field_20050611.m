function [x, tv] = get_stats_field(Stats,field)
%get_stats_field   
%Function to loop through Stats structure to retrieve data (x) from specified fields.  
%Data may be scalars or vectors but not matrices.
%For tv (timevector) to be output correctly, Stats must have the field, "Stats.TimeVector".  
%Note field names are case sensitive.
%
%Example:  [x, tv] = get_stats_field(Stats,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');


% E. Humphreys  Sept 30, 2003
% Revisions: Oct  3, 2003 - Now works on vector data with missing hhours
%            Apr 27, 2004 kai* - Added error notification

err_flag = 1;
L  = length(Stats);
x  = [];
for i = 1:L
    try,eval(['tmp = Stats(i).' field ';']);
        if length(size(tmp)) > 2;
            tmp = squeeze(tmp);
        else         
            [m,n] = size(tmp); 
            if m ~= 1; 
                tmp = tmp';
            end
            [m1, n1] = size(x); %check current size of x
            if n1 < n & n1 ~= 0;          %if new data to add is more
                old_x = x;
                x = NaN.*ones(length(x),n);
                x(size(old_x)) = old_x;
            end

            % if all data sor far has been nan, blow it up.
            if length(find(isnan(x))) == m1
                x = NaN .* ones(m1,m);
            end
            
        end
        x(i,:) = tmp;
        err_flag = 0;
    catch, x(i,:) = NaN; end
    try,eval(['tv(i,:) = Stats(i).TimeVector;']); catch, tv(i) = NaN; end
 end
 
 if err_flag
    disp(['Could not read ' field]);
 end
 