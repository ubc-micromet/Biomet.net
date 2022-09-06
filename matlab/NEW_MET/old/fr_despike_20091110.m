function [y,sp_len,sp_ind]= fr_despike(x,spike_len,threshold,threshold_const)

sp_ind = fr_find_spike(x,spike_len,threshold,threshold_const);
y = x;
if ~isempty(sp_ind)
    N = length(y);
    ind = 1:N;
    cl_ind = ind;
    cl_ind(sp_ind) = [];
    if spike_len > 1
        % next two lines work but slow (for 1 point spikes
        interp_points = interp1(ind(cl_ind),y(cl_ind),sp_ind);
        y(sp_ind) = interp_points;
    else
        sp_ind1 = sp_ind;
        if sp_ind(1) == 1
            sp_ind1 = [sp_ind(2:end)];
        end
        if sp_ind(end) == N
           sp_ind1 = sp_ind(1:end-1); 
        end
        y(sp_ind1) = (y(sp_ind1-1)+y(sp_ind1+1))/2;
        if sp_ind(1) == 1
            y(1) = y(2);
        end
        if sp_ind(end) == N
           y(end) = y(end-1); 
        end
    end
    sp_len = length(sp_ind);
else
    sp_len = [];
    sp_ind = [];
end

