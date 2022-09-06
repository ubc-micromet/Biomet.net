%==================================================================
%
%   e_units.m
%
%
%       This meta file transfers raw data (MET.EXE) to eng.units.
%       - to load the data file use MET1.met
%
%==================================================================
%
%
%       Start of the calculation
%
%
% initialization of the vectors
format short e
u = zeros(NumOfLines,1);
v = u;
w = u;
t = u;
c = u;
h = u;
r = u;
p = u;
tmp = u;
u(:) = NumInt(:,1).*Ugain;
v(:) = NumInt(:,2).*Vgain;
w(:) = NumInt(:,3).*Wgain;
if AnemometerType == 'S'
    t(:) = (NumInt(:,4)*0.02).^2 /403 * Tgain - 273;
elseif AnemometerType == 'A'
    t(:) = NumInt(:,4) * Tgain;
end
%
TCcoeff = (Tinternal + 273)/(Tco + 273);
THcoeff = (Tinternal + 273)/(Tho + 273);
%
% Pressure correction
%
%
p(:) = ((NumInt(:,8) + ADoffset) * ADconv/1000 * Pconst1 + Pconst2)/10;
BarometricP = mean(p);
Pc = Po /( BarometricP - Pgauge) 
%
tmp(:) = ((NumInt(:,5)+ ADoffset) * ADconv / Cgain + OffsetC) * Pc;
c(:) = polyval([ec dc cc bc ac 0],tmp) * TCcoeff;
%
tmp(:) = ((NumInt(:,6)+ ADoffset) * ADconv / Hgain + OffsetH) * Pc;
h(:) = polyval([eh dh ch bh ah 0],tmp) * THcoeff;
%
r(:) = log((NumInt(:,7)+ADoffset) * ADconv / Vox) / XKw;
%
g(:) = (NumInt(:,9) + ADoffset) * ADconv * PGconst1 + PGconst2;
%
means = [       mean(u)
        mean(v)
        mean(w)
        mean(t)
        mean(c)
        mean(h)
        mean(r)
        BarometricP
        mean(g)       ]
clear NumInt
pack
