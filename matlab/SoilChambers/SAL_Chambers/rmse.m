function rmse_out = rmse(x1,x2)
    N = length(x1);
    rmse_out = sqrt(sum((x1-x2).^2)/N);
    