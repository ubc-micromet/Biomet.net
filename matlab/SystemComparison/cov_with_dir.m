function [cov_elements] = cov_with_dir(dir,x);

for i = 1:36
    ind = find( dir > 10*(i-1) & dir <= 10*i );
    cov_elements.n(i) = length(ind);
    if cov_elements.n(i)>0
        cov_elements.sum12(i) = sum(x(ind,1).*x(ind,2));
        cov_elements.sum1(i)  = sum(x(ind,1));
        cov_elements.sum2(i)  = sum(x(ind,2));
    else
        cov_elements.sum12(i) = NaN;
        cov_elements.sum1(i)  = NaN;
        cov_elements.sum2(i)  = NaN;
    end
end
