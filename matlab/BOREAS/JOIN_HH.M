function [xx,decd] = join_hh(Fpath, nm, ind, Page, Port, Chan1, Chan2,getdecd)
%
%
% function [xx,decd] = join_hh(Fpath, nm, ind, Page, Port, Chan1, Chan2,getdecd)
%
%
%   (c) Zoran Nesic             Last modification: June 16, 1996
%
xx = [];
dd = [];
tt = [];
if nargin < 8
    getdecd = 0;
end

for i=ind
    FileName = sprintf('%s%d',Fpath,i);
    s = sprintf('x = hhread(%s%s%s, %s%s%s, 1:48, Port, Page, Chan1, Chan2);',39,FileName,39,39,nm,39);
    eval(s);
    xx = [xx ; x];    
    if getdecd == 1
        s = sprintf('d = hhread(%s%s%s, %sdate%s, 1:48, Port, Page, Chan1, Chan2);',39,FileName,39,39,39);
        eval(s);
        dd = [dd ; d];    
        s = sprintf('t = hhread(%s%s%s, %stime%s, 1:48, Port, Page, Chan1, Chan2);',39,FileName,39,39,39);
        eval(s);
        tt = [tt ; t];    
    end
end
if getdecd == 1
    decd = decdoy(dd,tt);
end    
