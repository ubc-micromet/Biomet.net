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
%  (c) Zoran Nesic                          File created:       Mar 26, 1996
%                                           Last modification:  Feb 16, 1999

% Revisions:
%
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
    end
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
    if strcmp(CalDate,'new') | strcmp(CalDate,'1996-06-10')
        % Calibration date: Jun 10, 1996
        cp = [  7.9714e-17  -1.1923e-12  8.4407e-9  7.3872e-6  0.14998 0];
        hp = [  2.6352e-11   3.0878e-6  6.5481e-3  0 ];
        Tc = 36.4;
        Th = 41.5;
        pp = [0.01525 58.968];     % s/n PX 244
    end
%
% AES LI6262
%
elseif num == 118
    if strcmp(CalDate,'new') | strcmp(CalDate,'1997-03-06')
        % Calibration date: Mar 6, 1997
        cp = [  5.2580e-17  -7.6134e-13 5.6376e-9  1.3893e-5   0.13997 0];
        hp = [ -1.1276e-11   2.9162e-6  6.2932e-3  0 ];
        Tc = 36.8;
        Th = 42.2;
        pp = [0.01563 60.805];     % s/n PX 320
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
elseif num == 674
    if strcmp(CalDate,'new') | strcmp(CalDate,'1996-01-11')
        % Calibration date: Jan 11, 1996
        cp = [  7.4317e-17  -1.0597e-12 7.5567e-9  1.0726e-5   0.14143 0];
        hp = [  1.8368e-11   3.0078e-6  6.5109e-3  0 ];
        Tc = 35.7;
        Th = 41.0;
        pp = [0.01536 59.312];     % s/n PX 201 (Jan 12, 1996)
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
else     
    error  'Wrong LICOR serial number'
end