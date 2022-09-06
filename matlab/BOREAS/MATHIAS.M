function [Tv,Ta,T_s,w_s,q]  = mathias(u, v, w, c, vT_s, vw_s, vq)
%
%
%
%
%
%
%
% (c) Matthias Roth & Zoran Nesic		File created:		Oct 24, 1996
%										Last modification:	Oct 25, 1996
%
const403 = 20.067^2;
Tv = c.^2/const403 - 273.16;
Ta = (c.^2 + 0.75*u.^2 + 0.75 * v.^ 2 + 0.5 * w .^ 2)/const403 - 273.16;
T_s = (vT_s - 12280*100/502)*770/470*0.004;
w_s = (vw_s - 12550*100/502)*770/470*0.001;
mvq = mean(vq);
q = (vq - mvq)/(-mvq * 0.166 * 0.791);



