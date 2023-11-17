function [x, tv] = get_stats_field_fast(Stats,fieldIn)
%get_stats_field_fast
%Function to loop through Stats structure to retrieve data (x) from specified fields.  
%Data may be scalars or vectors but not matrices.
%For tv (timevector) to be output correctly, Stats must have the field, "Stats.TimeVector".  
%Note field names are case sensitive.
%
%Example:  [x, tv] = get_stats_field(Stats,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');


% Revisions:
%  Nov 16, 2023 (Zoran)
%   - wrote a new function based on get_stats_field. Working on making it
%     fully compatible with the original and faster.


% Old function get_stats_field
% Mar 4, 2020 (Zoran)
%   - The fix from Nov 4, 2019 worked only when "field" contained one field
%   only (like 'Fc' not with "MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc")
%     Returned to eval version.
% Nov 4, 2019 (Zoran)
%   - Removed some eval statements that seemed to slow down the program.
%

% E. Humphreys  Sept 30, 2003
% Revisions: Oct  3, 2003 - Now works on vector data with missing hhours
%            Apr 27, 2004 kai* - Added error notification
%            June 11, 2005
%               - fixed a bug that prevented plotting of some data (see
%               below) (Zoran)

err_flag = 1;
L  = length(Stats);
x  = [];

fieldParts = split(fieldIn,'.');

for i = 1:L
    try
        newStats = Stats(i);
        nFieldParts = length(fieldParts);
        for cntParts = 1:nFieldParts
            currentPart = char(fieldParts(cntParts)); 
            [matDim,mainField] = getArrayDimensions(currentPart);              
           if ~isempty(matDim)
               if length(matDim) == 1
                    newStats = newStats.(mainField);
                    newStats = newStats(matDim);
               elseif length(matDim) == 2
                    newStats = newStats.(mainField);
                    newStats = newStats(matDim(1),matDim(2));
               else
                   fprintf('get_stats_field_Fast: Matrix can be only N x 1 or N x M\n');
               end
           else 
                newStats = newStats.(currentPart);
           end
        end
        if isempty(newStats)
            newStats = NaN;
        end
        if length(size(newStats)) > 2
            newStats = squeeze(newStats);
        else         
            [m,n] = size(newStats); 
            if m ~= 1 
                newStats = newStats';
            end
            [m1, n1] = size(x); %check current size of x
            if n1 < n & n1 ~= 0          %#ok<*AND2> %if new data to add is more
                old_x = x;
                x = NaN.*ones(length(x),n);
                x(size(old_x)) = old_x;
            end

            % if all data sor far has been nan, blow it up.
            if length(find(isnan(x))) == m1*n1
                x = NaN .* ones(m1,m);
            end
            
        end
        x(i,1:size(newStats,2)) = newStats;       % changed from x(i,:) = newStats; to prevent errors (Zoran June 11, 2005)
        err_flag = 0;
    catch %#ok<*CTCH>
        x(i,:) = NaN; 
    end
    try
        %eval(['tv(i,:) = Stats(i).TimeVector;']);
        tv(i,:) = Stats(i).TimeVector; %#ok<*AGROW>
    catch
        tv(i) = NaN; 
    end
 end
 
 if err_flag
    disp(['Could not read ' fieldIn]);
 end
 
function [matDim,mainField] = getArrayDimensions(fieldPart)
    % find if this is a matrix by searching for ()
    lastFieldPart = char(fieldPart);
    indBrc1 = strfind(lastFieldPart,'(');
    matDim = [];
    mainField = [];
    if ~isempty(indBrc1)
        indBrc2 = strfind(lastFieldPart,')');
        if ~isempty(indBrc2)
            tmpStr = lastFieldPart(indBrc1(1)+1:indBrc2(1)-1);
            tmpStr = split(tmpStr);
            matDim = str2num(cell2mat(split(tmpStr)));
        end
        mainField = lastFieldPart(1:indBrc1(1)-1);        
    end