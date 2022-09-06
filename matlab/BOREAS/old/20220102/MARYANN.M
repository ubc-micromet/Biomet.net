%
% File name: maryann.m 
%
%
% (c) Zoran Nesic			File created:       Dec  2, 1996
%                           Last modification:  Jan 22, 1997




pth = 'h:\zoran\paoa\';
GMT = read_bor('h:\zoran\paoa\paoa_dt')+1;
timeStr = read_bor('h:\zoran\paoa\paoa_t',5);
dateStr = read_bor('h:\zoran\paoa\paoa_d',4);
co2conct = read_bor('h:\zoran\paoa\paoa_9.2_2');
Tair=read_bor([ pth 'paoa_8.2_2'])+273.16;  		    % get air Temp
Pb = read_bor([ pth 'paoa_12.2_2']);       		        % get Pbarometric
co2conct = co2conct ./ ( 1000/189 .* Pb ./ Tair );      % convert to ppm
h2oconct = read_bor('h:\zoran\paoa\paoa_8.2_2');        % H2O conc.
h2oconct = h2oconct ./ ( 1000/461 .* Pb ./ Tair );      % convert to mmol/mol
wc=read_bor([ pth 'paoa_46.2_2'])*1000/44;         	    % get CO2 fluxes
LE=read_bor([ pth 'paoa_82.2_2']);                      % get LE LICOR
H=read_bor([ pth 'paoa_81.2_2']);                       % get sensible heat
CST = GMT - 0.25;                                       % CST time
Rn=read_bor([ 'r:\paoa\newdata\bonet\bnt.7']);          % Net Radiation (Middleton)
GMTfloor = floor(GMT);
ind = find(GMTfloor == 191 | GMTfloor == 193 | GMTfloor == 201 | GMTfloor == 208 | GMTfloor == 211) + 13;
if 1==2
    fid = 2;
else
    fid = fopen('h:\zoran\maryann.out','w');
end
fprintf(fid,'   Date    EndTime     H        LE         Fc       H2O      CO2      Tair      Pbarom     NetRadiation\n');
fprintf(fid,'                      W/m2     W/m2    umol/m2/s  mmol/mol umol/mol   degK        kPa          W/m2\n\n');
for k=ind'
   fprintf(fid,'%s %s %8.4f %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f      %8.4f\x0d\x0a', dateStr(k,:),timeStr(k,:),H(k),LE(k),wc(k),h2oconct(k),co2conct(k),Tair(k),Pb(k),Rn(k)  );
end
if fid > 2
    fclose(fid)
end