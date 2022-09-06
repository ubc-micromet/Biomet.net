%==================================================================
%
%   met-stat.m
%
%
%   This meta file does statistics for the given data:
%    [u v w t c h r] and delay.
%
%   (it is suppose to give the same results as on line 
%    calculation)
%
%==================================================================
%
%
%   Start of the calculation
%
%

c(1:NumOfLines -delay) = c(delay+1:NumOfLines) ;
h(1:NumOfLines -delay) = h(delay+1:NumOfLines) ;
%
% Make the covariance matrix
%
NumReal = [ u v w t c h r ];
NumReal = NumReal (1 : NumOfLines - delay,:);
%
% clear the memory
%
%clear NumInt
clear u
clear v
clear w
clear t
clear c
clear h
clear r
clear p
pack
%
%  Calculate the covariances
%
covs = cov(NumReal);
triu(covs)
%
%  Rotation
%
if rotation == 'C'
    [means1,covs1] = rotatC (means,covs);
else
    [means1,covs1] = rotatN (means,covs);
end
[means2,covs2] = WPLcorr (means1,covs1);
means2
triu(covs2)
