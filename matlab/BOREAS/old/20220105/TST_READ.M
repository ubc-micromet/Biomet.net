%
% tst_read.m
%
%   Test for reading/recalculating raw data from the Eddy Corr. system
%
%
%
%
% (c) Zoran Nesic 		File created:		Aug 20, 1996
%       				Last Modification:	Aug 22, 1996

%FileName = 'd:\cd-rom\tmp\08-02-96\60801182.n2';
[RawData,header] = read_met(FileName);
EngUnits = eng_met1(RawData,header);
header(5) = 23;                         % correct time delay
[means, covs,means1, covs1,means2, covs2] =  met_calc(EngUnits, header);

