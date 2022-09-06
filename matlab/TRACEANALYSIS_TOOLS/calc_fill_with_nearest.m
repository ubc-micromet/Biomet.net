function[data_out] = calc_fill_with_nearest(data_in);

[n,m] = size(data_in);
if m > 1
    for i = 1:m-1
        ind = find(isnan(data_in(:,i)));
        j_start = i+1;
        for j = j_start:m;
            data_in(ind,i) = data_in(ind,j);      
            ind = find(isnan(data_in(:,i)));
        end
    end
    for i = m;
        ind = find(isnan(data_in(:,i)));
        data_in(ind,i) = data_in(ind,i-1);
    end
end

%do it again for good measure!

if m > 1
    for i = 1:m-1
        ind = find(isnan(data_in(:,i)));
        j_start = i+1;
        for j = j_start:m;
            data_in(ind,i) = data_in(ind,j);      
            ind = find(isnan(data_in(:,i)));
        end
    end
    for i = m;
        ind = find(isnan(data_in(:,i)));
        data_in(ind,i) = data_in(ind,i-1);
    end
end

data_out = data_in;