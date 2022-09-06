% h2o_dew   -   calibration of Li-Cor using dew-point hygrometer
%
%
%
%
%
%
% (c) Zoran Nesic       File created:       Jun 10, 1997
%                       Last modification:  Jun 10, 1997
%


Tdew = [4.935+4.969 4.367+4.254 4.229+4.667 4.452+4.096 4.522+4.57 ...
        3.873+3.537 3.855+4.061 3.399+2.639 1.864+1.895 2.055+2.322 ...
        2.165+2.248 2.356+2.832]/2;
Sat_vp = 0.61365 * exp( (Tdew * 17.502) ./ (240.97+Tdew));          % mmol/mol

DOY = read_bor('h:\zoran\paoa\paoa_dt') - 366+1;
%Tair = read_bor('h:\zoran\paoa\paoa_8.2_2');
Tair = read_bor('r:\paoa\newdata\eddy\eddy.12')-273.16;
P = read_bor('h:\zoran\paoa\paoa_12.2_2');
H = read_bor('h:\zoran\paoa\paoa_81.2_2');
LiCor = read_bor('h:\zoran\paoa\paoa_82.2_2');
Krypton = read_bor('h:\zoran\paoa\paoa_83.2_2');

x = read_bor('h:\zoran\paoa\paoa_10.2_2') ./ (1000/461*P./(Tair+273.16)) ; % mmol/mol
ind = find(DOY>=156+21.5/24-.001 & DOY<=157+3/24+.001);
figure(1)
clg
plot(DOY(ind),x(ind),DOY(ind),Sat_vp*1000./P(ind)')
xlabel('DOY')

figure(2)
clg
plot(DOY(ind),(Sat_vp'*1000./P(ind))./x(ind))
title('h2o_DewPoint / h2o_Li-Cor')
xlabel('DOY')

figure(3)
clg
% calibrated Licor h2o and O2 corrected Krypton (6% of H)
plot(DOY,LiCor*.89,DOY,Krypton+.06*H)
axis([157 162 -50 400])
title('Corrected Licor and corrected Krypton')
xlabel('DOY')