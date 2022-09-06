function [cpinv,hpinv] = inv_lic(num, vc, vh, plot_flag)
%
%   function [cpinv,hpinv] = inv_lic(num, vc, vh, plot_flag)
%  
%   inputs:
%           num         -   LICOR serial num
%           vc          -   co2 voltage array (mV)
%           vh          -   h2o voltage array (mV)
%           plot_flag   -   1 for plotting, 0 w/o plotting
%
%   outputs:
%           cpinv       -   inverse co2 poly
%           hpinv       -   inverse h2o poly
%
%
%   (c) Zoran Nesic                 File created:       Mar 26, 1996
%                                   Last modification:  Dec  2, 1997
%

% Revisions:
%
%   Dec  2, 1997
%       -   added two outputs (cpinv,hpinv) and input flag for plotting (plot_flag)
%

if ~exist('plot_flag')
    plot_flag = 1;
end

nameL = sprintf('L-%d',num);
[cp,hp] = licor(num);
hp = [ 0 0 hp];
c = polyval(cp,vc);
h = polyval(hp,vh);
cpinv = polyfit(c,vc,5);
hpinv = polyfit(h,vh,5);

if plot_flag == 1

    v1 = polyval(cpinv,c);
    v2 = polyval(hpinv,h);
    dd1 = vc-v1;
    dd2 = vh-v2;

    [junk,ind1] = min(abs(335 - c));
    [junk,ind2] = min(abs(436 - c));
    [junk,ind3] = min(abs(1005 - c));
    figure(1)
    plot(c,dd1,335,dd1(ind1),'or',436,dd1(ind2),'or',1005,dd1(ind3),'or',850,1.5,'or')
    text(900,1.5,'UBC calibration gases','fontsize',10)
    grid
    title(['co2 polynomials, ' nameL])
    xlabel('co2 [ppm]')
    ylabel('Voltage error [mV]')
    out1 = [cp' cpinv'] ;
    out1 = out1(length(out1):-1:1,:);
    out1 = [ [1:length(out1)]'-1 out1];

    fid = fopen([nameL '.dat'],'w');
    disp(sprintf('Coeff.     Poly        InvPoly\n'))
    disp(sprintf('%d    %8.6e   %8.6e\n',out1'))
    ff = [nameL '  CO2 \r\n'];
    ff = sprintf('\r\n\r\n%s CO2  Voltage range: %d to %d (mV)\r\n\r\n',nameL,min(vc),max(vc));
    fprintf(fid,ff);
    fprintf(fid,(sprintf('Coeff.     Poly        InvPoly\r\n')));
    fprintf(fid,(sprintf('%d    %8.6e   %8.6e\r\n',out1')));

    figure(2)
    plot(h,dd2)
    grid
    title(['h2o polynomials, ' nameL])
    xlabel('h2o [umol/mol]')
    ylabel('Voltage error [mV]')
    out2 = [hp' hpinv'] ;
    out2 = out2(length(out2):-1:1,:);
    out2 = [ [1:length(out2)]'-1 out2];
    disp(sprintf('Coeff.     Poly        InvPoly\n'))
    disp(sprintf('%d    %8.6e   %8.6e\n',out2'))
    ff = sprintf('\r\n\r\n%s H2O  Voltage range: %d to %d (mV)\r\n\r\n',nameL,min(vh),max(vh));
    fprintf(fid,ff);
    fprintf(fid,(sprintf('Coeff.     Poly        InvPoly\r\n')));
    fprintf(fid,(sprintf('%d    %8.6e   %8.6e\r\n',out2')));

    fclose(fid) ;

end
