function [cp,hp,Tc,Th,pp] = licor(num,CalDate)
%
%       function [cp,hp,Tc,Th,pp] = licor(num)
%
%       Returns both polynomials (co2, h2o) for the given licor serial number.
%
%       inputs:
%              num      - LICOR serial number
%              CalDate  - calibration date ('new' - is default, "yyyy-mm-dd")
%       outputs:
%              cp       - co2 poly
%              Tc       - co2 temperature
%              hp       - h2o poly
%              Th       - h2o temperature
%              pp       - Pressure sensore poly
%
%       note:  Polynomials are given in Matlab format, i.e.:
%               co2 = cp(1) * V^5 + cp(2)*V^4 ... + cp(5)*V + cp(6)
%              Therefore they can be used in Matlab function "polyval"
%               v = linspace(0,2000,128);    % voltage in milivolts (0-2000mv, 128 points)
%               co2 = polyval(cp,v);         % co2 calculated for those 128 voltage values
%
%
%  (c) Zoran Nesic                         File created:       Mar 26, 1996
%                                          Last modification:  May  4, 2007
%                                           
                                           

% Revisions:
%  May 4, 2007
%       -Added SN#174001
%  Feb 9, 2007
%       ***begin NEW SN convention instead of CalDate***
%       -Nick added a new Licor SN#1036001, 1037001 so that the older
%       calibrations would be used for 1999.
%  Jan 16, 2007
%       - new polynomials for S/N 1037 (MSC)
%  Aug 2, 2004
%       - added a Queen's 6262 SN 1180
%  July 22, 2004
%      - new polynomials for S/N 118 (MSC)
%  Dec 11, 2003
%      - new polynomials for S/N 1234 (Fluxnet-CA)
%  July 5, 2003
%      - new polynomials for S/N 1036
%  May 14, 2003
%      - added calibration for LI-6262 unit S/N 1236 
%  May 6, 2003
%      - added calibration for Queen's LI-6252 unit S/N 209 (dgg) 
%  Nov 29, 2001
%		- corrected an error in licor #749 
%			C2 D was
%				-1.2752e-13
%			now it's:
%				-1.2752e-12
%   Apr 01, 1999
%       - added calibration for AES units: #1036, #1037, #1038
%   Feb 16, 1999
%       - added calibration for AES unit: #118
%	Dec 11, 1998
%		- OJP licor added (#939)
%   Jun 17, 1998
%       Added calibration for AES IRG 674, 914
%   Aug 12, 1997
%       Changed pressure calibration for 174. For some reason it was wrong.
%

if nargin < 2
    CalDate = 'new';
end
if num == 174
    % ----------
    % UBC unit
    % ----------
    if strcmp(CalDate, '1996-01-03')
        % Calibration date: Jan 3, 1996
        Tc = 36.4;
        Th = 41.7;
        cp = [ 6.7375e-17  -1.0289e-12  7.1739e-9  8.86e-6  0.15831 0];
        hp = [ -1.1733e-11  3.3072e-6  6.5087e-3  0 ];
    elseif strcmp(CalDate,'new') | strcmp(CalDate,'1997-01-07')
        % Calibration date: Jan 7, 1997
        Tc = 35.3;
        Th = 41.2;
        cp = [ 4.9263e-17  -7.0412e-13  5.0905e-9  1.4306e-5  0.14937 0];
        hp = [ -2.3537e-11  3.3074e-6   5.8763e-3  0 ];
%                            pp = [ 0.01510 58.239];     % s/n PX 295
        pp = [ 0.01531 59.09];     % s/n PX 295    
    elseif strcmp(CalDate,'2006-11-05')
        % Calibration date: Nov 5, 2006
        cp = [ 3.3738e-17  -5.6183e-13  4.7843e-9   1.2146e-5   0.14785  0];
        hp = [ -5.9287e-12  2.9272e-6    6.1833e-3   0];
        Tc = 40.8;
        Th = 41.2;
        pp = [0.01506 58.340];
    end
elseif num == 174001
        cp = [ 1.98879e-17  -3.63072e-13  4.54906e-9   1.26999e-5   0.139529  0];
        hp = [ 1.23714e-12  2.74189e-6    6.10447e-3   0 ];
        Tc = 40.58;
        Th = 40.85;
        pp = [0.01531 59.090];
elseif num == 234
    % ----------
    % UBC unit
    % ----------
    if strcmp(CalDate,'new') | strcmp(CalDate,'1998-10-05')    
        % Calibration date: Oct 5, 1998
        cp = [ 5.5154e-17  -8.2824e-13  5.9646e-9   1.2034e-5   0.15197  0];
        hp = [ 1.2248e-11  3.1208e-6    6.5890e-3   0];
        Tc = 35.6;
        Th = 40.0;
        pp = [0.01506 58.340];
    elseif strcmp(CalDate,'1996-01-04')
        % Calibration date: Jan 4, 1996
        cp = [ 6.337e-17  -9.3673e-13  6.4032e-9   1.1892e-5   0.15121  0];
        hp = [ -5.2950e-11  3.4709e-6    6.2274e-3   0];
        Tc = 36.6;
        Th = 41.7;
        pp = [0.01506 58.340];
    end
elseif num == 483
    % ----------
    % UBC unit
    % ----------
    if strcmp(CalDate,'new') | strcmp(CalDate,'1998-02-26')
        % Calibration date: Feb 26, 1998
        cp = [  6.8553e-17 -1.0353e-12  7.5782e-9  9.6363e-6  0.14747 0];
        hp = [ -2.0252e-11  3.0014e-6   6.7142e-3  0 ];
        Tc = 35.8;
        Th = 41.1;
        pp = [0.01507 58.645];
    elseif strcmp(CalDate,'1994-05-16')        
        % Calibration date: May 16, 1994
        cp = [  6.7107e-17  -1.0228e-12  7.6386e-9  8.9819e-6  0.14953 0];
        hp = [  1.0068e-11   2.8328e-6  6.7726e-3  0 ];
        Tc = 36.5;
        Th = 41.6;
        pp = [];
    end
elseif num == 740
    % ----------
    % UBC unit
    % ----------
    if strcmp(CalDate,'1996-06-10')
        % Calibration date: Jun 10, 1996
        cp = [  7.9714e-17  -1.1923e-12  8.4407e-9  7.3872e-6  0.14998 0];
        hp = [  2.6352e-11   3.0878e-6  6.5481e-3  0 ];
        Tc = 36.4;
        Th = 41.5;
        pp = [0.01525 58.968];     % s/n PX 244
    elseif strcmp(CalDate,'new') | strcmp(CalDate,'2002-09-23')
        % Calibration date: Sep 23, 2002
        cp = [  3.01019e-17  -4.8494e-13  5.0153e-9  1.11063e-5  0.136527 0];
        hp = [  7.94464e-12   2.70917e-6  5.97631e-3  0 ];
        Tc = 38.96;
        Th = 39.16;
        pp = [0.01525 58.968];     % s/n PX 244
    end
%
% AES LI6262 -BERMS
%
elseif num == 118
    if strcmp(CalDate,'new') | strcmp(CalDate,'2004-06-25')
        % Calibration date: June 25, 2004
        cp = [  3.85323e-17  -6.40379e-13 5.49179e-9  1.15242e-5   0.142193 0];
        hp = [ -1.38354e-11   2.67142e-6  6.21589e-3  0 ];
        Tc = 42.19;
        Th = 42.21;
        pp = [0.01562 60.805];     % s/n PX 320
    elseif strcmp(CalDate,'1997-03-06')
        % Calibration date: Mar 6, 1997
        cp = [  5.2580e-17  -7.6134e-13 5.6376e-9  1.3893e-5   0.13997 0];
        hp = [ -1.1276e-11   2.9162e-6  6.2932e-3  0 ];
        Tc = 36.8;
        Th = 42.2;
        pp = [0.01563 60.805];     % s/n PX 320
    end
elseif num == 674
    if strcmp(CalDate,'new') | strcmp(CalDate,'1996-01-11')
        % Calibration date: Jan 11, 1996
        cp = [  7.4317e-17  -1.0597e-12 7.5567e-9  1.0726e-5   0.14143 0];
        hp = [  1.8368e-11   3.0078e-6  6.5109e-3  0 ];
        Tc = 35.7;
        Th = 41.0;
        pp = [0.01536 59.312];     % s/n PX 201 (Jan 12, 1996)
    end
elseif num == 791
    if strcmp(CalDate,'new') | strcmp(CalDate,'1996-12-09')
        % Calibration date: Dec 9, 1996
        cp = [  5.9119e-17  -8.1876e-13 6.2785e-9  1.3130e-5   0.14041 0];
        hp = [  4.0057e-11   2.8785e-6  6.7793e-3  0 ];
        Tc = 35.9;
        Th = 41.2;
        pp = [0.01522 59.812];     % s/n PX 311
    end
elseif num == 914    
    if strcmp(CalDate,'new') | strcmp(CalDate,'1998-02-19')
       % Calibration date: Feb 19, 1998
        cp = [  6.8367e-17  -9.8349e-13 7.3852e-9  9.9091e-6   0.14746 0];
        hp = [  -1.6832e-11   3.1085e-6  6.38e-3  0 ];
        Tc = 36.6;
        Th = 41.9;
        pp = [0.01529 58.695];     % s/n PX 446
     end
elseif num == 1036    
%     if strcmp(CalDate,'new') | strcmp(CalDate,'2003-06-16')
       % Calibration date: Jun 16, 2003
        cp = [  2.23506e-17 -3.01992e-13 3.8172e-9 1.53045e-5 1.34689e-1 0];
        hp = [ -2.55988e-11  2.90333e-6  5.96133e-3 0];
        Tc = 39.62;
        Th = 39.67;
        pp = [0.01536 58.919];     % s/n PX 617
elseif num == 1036001 % same licor as 1036, just different calibration
%     elseif strcmp(CalDate,'1999-03-22')
       % Calibration date: Mar 22, 1999
        cp = [  6.5803e-17  -9.5783e-13 7.3596e-9  9.4450e-6   0.14677 0];
        hp = [  -1.0190e-11   2.9544e-6  6.5140e-3  0 ];
        Tc = 37.0;
        Th = 42.3;
        pp = [0.01536 58.919];     % s/n PX 617
%      end
elseif num ==1037  
%    if strcmp(CalDate,'new') | strcmp(CalDate,'2007-01-08')
       % Calibration date: Jan 08, 2007
        cp = [  1.91273e-17 -3.42587e-13 4.51288e-9 1.22073e-5 1.35284e-1 0];
        hp = [ -7.05199e-11  2.57386e-6  6.382e-3 0];
        Tc = 39.94;
        Th = 40.79;
        pp = [0.01512 58.273];     % s/n PX 618
        
        %    elseif strcmp(CalDate,'1999-03-24')
% Calibration date: Mar 24, 1999
elseif num ==1037001       % same licor as 1037, just different calibration
        cp = [  7.0704e-17  -9.9935e-13 7.5402e-9  1.0131e-5   1.4603e-1 0];
        hp = [  7.6605e-12   3.0716e-6  6.5714e-3  0 ];
        Tc = 36.6;
        Th = 41.9;
        pp = [0.01512 58.273];     % s/n PX 618
        
        %end
elseif num == 1038    
    if strcmp(CalDate,'new') | strcmp(CalDate,'1998-03-24')
       % Calibration date: Mar 24, 1999
        cp = [  6.8449e-17  -9.6640e-13 7.3325e-9  1.0690e-5   0.14255 0];
        hp = [  2.7987e-11   3.0462e-6  6.4501e-3  0 ];
        Tc = 35.9;
        Th = 41.4;
        pp = [0.01526 58.855];     % s/n PX 619
     end
     
 elseif num == 7000    
    if strcmp(CalDate,'new') | strcmp(CalDate,'1998-02-19')
       % This is a generic LI-7000 dummy setup to make it appear as LI-6262
       % It's assumed that CO2 is set to bipolar, 0 to 800 ppm, water, 0 to 30
       % mmol/mol, Temp is set the same way as LI-6262, and pressure is 60
       % to 120 kPa, for 0 to 5V
        cp = [  800/5000 0];
        hp = [  30/5000  0 ];
        Tc = 36.6;
        Th = 41.9;
        % pp = [0.03062 59.23];     
        pp = [60/5000 60];
     end
%
% Queen's LI6262
%
elseif num == 939
    if strcmp(CalDate,'new') | strcmp(CalDate,'1997-10-01')
       % Calibration date: Oct 1, 1997
        cp = [  4.0295e-17  -4.7116e-13 4.3759e-9  1.7356e-5   0.13814 0];
        hp = [  5.6128e-11   2.8367e-6  6.8940e-3  0 ];
        Tc = 35.230;
        Th = 40.97;
        pp = [0.01529 58.817];     % s/n PX ???
     end
%
% Queen's LI6252 (No cell pressure, no water vapor)
%
elseif num == 209
    if strcmp(CalDate,'new') | strcmp(CalDate,'1997-06-04') 
       % Calibration date: '1997-06-04'
        cp = [  3.9838e-17  -5.5267e-13  4.3079e-9  1.4550e-5  1.4509e-1 0];
        hp = [  0  0  0  0];
        Tc = 37; % This is a fudge temperature (was not provided with the LI-6252 calibration)
        Th = 0;
        pp = [0 0];     
    end

elseif num == 1180 %new EC IRGA
     if strcmp(CalDate,'new') | strcmp(CalDate,'2000-09-20')
       % Calibration date: 20 Sep 2000
        cp = [  6.33491e-17 -8.87016e-13 6.63385e-9 1.15944e-5 1.39328e-1 0];
        hp = [  1.10388e-10 2.44388e-6 6.2639e-3 0 ];
        Tc = 38.35;
        Th = 38.75;
        pp = [0.01522 58.810];     % s/n PX-810
     end
%
% UVic's LI6262
%     
elseif num == 749
    if strcmp(CalDate,'new') | strcmp(CalDate,'1996-07-03')
       % Calibration date: Oct 1, 1997
        cp = [  8.6993e-17  -1.2752e-12 8.8845e-9  7.6388e-6  0.14500 0];
        hp = [  -2.3177e-11   3.3407e-6  6.3016e-3  0 ];
        Tc = 35.90;
        Th = 41.1;
        pp = [0.01519 56.218];     % s/n PX 258
     end

%
% Fluxnet Canada
%     
elseif num == 1234
    if strcmp(CalDate,'new') | strcmp(CalDate,'2002-12-05')
       % Calibration date: Dec 5, 2002
        cp = [  4.03307e-17  -6.52637e-13 5.83444e-9  9.71281e-6  0.139245 0];
        hp = [  -2.12203e-11   2.66541e-6  6.29055e-3  0 ];
        Tc = 40.07;
        Th = 40.13;
        pp = [0.01529 59.172];     % s/n PX 1059
     end

elseif num == 1236
    if strcmp(CalDate,'new') | strcmp(CalDate,'2002-12-09')
       % Calibration date: Dec 9, 2002
        cp = [  3.86056e-17  -6.02309e-13 5.67443e-9  1.14133e-5  0.138935 0];
        hp = [  -4.02728e-12   2.38434e-6  5.91894e-3  0 ];
        Tc = 35.90;
        Th = 41.1;
        pp = [0.01532 58.650];     % s/n PX 1059
     end
else     
    error  'Wrong LICOR serial number'
end