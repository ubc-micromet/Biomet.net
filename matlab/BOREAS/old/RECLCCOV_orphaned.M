function [No_WPL,No_rot,C_rot, N_rot] = reclccov(means,covs,ind,out_var)
%
%
%
%
%
%
% (c) Zoran Nesic & Peter Blanken       File created:       Sep 25, 1996
%                                       Last modification:  Sep 25, 1996

[out_n, out_m] = size(out_var);
for i = ind
    mean1 = means(i,:);
    cov1  = zeros(10,10);
    xx = 0;
    for j = 1:10;
        for k = j:10
            xx = xx + 1;
            cov1(j,k) = covs(i,xx);
        end
    end
    %
    %  Rotation
    %
    for z = 1:out_n    
        No_WPL(i,z) = cov1(out_var(z,1),out_var(z,2));
    end
    [means2,covs2] = WPLcorr (mean1,cov1);
    for z = 1:out_n    
        No_rot(i,z) = covs2(out_var(z,1),out_var(z,2));
    end
    [means1,covs1] = rotatC (mean1,cov1);
    [means2,covs2] = WPLcorr (means1,covs1);
    for z = 1:out_n    
        C_rot(i,z) = covs2(out_var(z,1),out_var(z,2));
    end
    [means1,covs1] = rotatN (mean1,cov1);
    [means2,covs2] = WPLcorr (means1,covs1);
    for z = 1:out_n    
        N_rot(i,z) = covs2(out_var(z,1),out_var(z,2));
    end
end

