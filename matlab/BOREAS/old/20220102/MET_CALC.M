function [means, covs, means1, covs1, means2, covs2] =  met_calc(EngUnits, header)
%
%   [means, covs, means1, covs1, means2, covs2] =  met_calc(EngUnits, header)
%
%
%
%
%
%
% (c) Zoran Nesic                   File created:       Aug 18, 1996
%                                   Last modification:  May  8, 1997
%
%   Revisions:
%           May 8, 1997
%               moved delay time correction to eng_met1.m
%

%
% delaying of the arrays has been moved to eng_met1.m, May 8, 1997, Zoran Nesic)
%

means = mean(EngUnits');
covs = cov(EngUnits');

%
%  Rotation
%
rotation = setstr(header(8));
if rotation == 'C'
    [means1,covs1] = rotatc(means,covs);
else
    [means1,covs1] = rotatn(means,covs);
end

[means2,covs2] = wplcorr (means1,covs1);
