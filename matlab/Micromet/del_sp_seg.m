function data = del_sp_seg(data, clean_tv, time_seg,verbose)

% Title:   delete_specific_segment
% Purpose: This function help to delete data in a specific period

%                                   File created:      2022.10.16
%                                   Last modification: 2022.10.17
%                                   Editor:            Tzu-Yi (ziyi)

% Input
%     data: a series of continuous measurements (Format: double)
% clean_tv: a time series of the measurements. (Format: datenum)
% time_seg: specific periods you want to delete 
%           (e.g. data within regular maintenance)
%           (Format: a paired datenum array with begin and finish time)


% Output
%     data: data points within the specified time segments are removed

% Revisions
%
% Nov 4, 2022 (Zoran)
%   - the program now prints the output on the screen only if 
%     verbose ~= 0. Otherwise the screen gets too much output during
%     automated cleaning.
%
arg_default('verbose',0);  % by default don't print anything
TF='yyyy/mm/dd HH:MM'; % time format
s = inputname(1);      % to identify which variable you are processing

if clean_tv(end)>time_seg(1,1)
    if verbose~=0
        fprintf(1, '- %s:',s);   % print the variable name for the log
    end
    for i=1:size(time_seg,1)
        ind_delete=find(clean_tv>=time_seg(i,1) & clean_tv<=time_seg(i,2)); 
        
        if i==1
            outS='delete %d\t data (%s ~ %s)\n';
        else
            outS='   \t delete %d\t data (%s ~ %s)\n';
        end
        if verbose~=0
            fprintf(1, outS,length(ind_delete),datestr(clean_tv(ind_delete(1)),TF),datestr(clean_tv(ind_delete(end)),TF))
        end
        
        if ~isempty(ind_delete)            
            data(ind_delete)=NaN;
        else
            if verbose~=0
                disp('Nothing to be deleted.')
            end
        end
    end
end


