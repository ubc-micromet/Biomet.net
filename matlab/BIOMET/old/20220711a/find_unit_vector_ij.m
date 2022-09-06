function [i,j,k] = find_unit_vector_ij(U,k_single)
% [i,j,k] = find_unit_vector_ij(U,k)
%
% Find unit vectors i and j paralle to the new x and y axis,
% following the interpreation by Xuhui Lee.
%
% U = [u v w] measured, k - output of find_unit_vector_k
% the ouput unit vectors i,j,k have the same length as U

k = ones(length(U),1)*k_single;
j = cross(k,U,2);
j_length = real(sum(j.*j,2).^0.5) * ones(1,3);
j = j./j_length;
i = cross(j,k,2);