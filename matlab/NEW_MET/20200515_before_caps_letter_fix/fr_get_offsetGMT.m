function offsetGMT = FR_get_offsetGMT(SiteFlag)
% fr_get_offsetGMT.m
%
% (c) Zoran Nesic           File created:       Feb 10, 1998
%                           Last modification:  Apr 27, 2004
%

%
% Revisions:
% Apr 27, 2004 kai* - changed default offsetGMT from NaN to 0
% Oct 28, 2003 kai* - inserted shifts for all Biomet sites

switch upper(SiteFlag)
case {'CR','OY','YF'}
    offsetGMT = 8;
case {'HP09'}
    offsetGMT = 7;
case {'BS','HJP02','JP','PA','HP11'}
    offsetGMT = 6;
otherwise
%    offsetGMT = NaN;
    offsetGMT = 0;
end

