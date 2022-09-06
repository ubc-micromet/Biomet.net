%
% test_cal
%
% Manual calibrations of PAOA and CR sites
%
% (c) Zoran Nesic			File created:			Dec  2, 1997
%								Last modification:	Dec  2, 1997
%

%
% PAOA
%
c_cal = fr_cal_licor(791, 330, -53, 1669, 0, 3233, 2003)
c_cal = fr_cal_licor(791, 330, -53, 1640, 0, 3247, 1905)
c_cal = fr_cal_licor(791, 330, -54, 1650, 0, 3251, 1945)
c_cal = fr_cal_licor(791, 330, -56, 1650, 0, 3232, 1944)     % Dec 22, 1997
%
%
% Jan 7, 1998 before ref tank change
c_cal = fr_cal_licor(791, 330, -58, 1670, 0, 3226, 2021)

% Jan 7, 1998 after ref tank change 70 cc/min
c_cal = fr_cal_licor(791, 330, -58, 1670, 0, 3222, 2021)
c_cal = fr_cal_licor(791, 330, -58, 1670, 0, 3225, 2024)

% Jan 7, 1998 after ref tank change 60 cc/min
c_cal = fr_cal_licor(791, 330, -56, 1672, 0, 3228, 2024)
c_cal = fr_cal_licor(791, 330, -56, 1672, 0, 3221, 2026)

% Jan 9, 1998 after ref tank turned back on
c_cal = fr_cal_licor(791, 330, -64, 1673, 0, 3187, 2026)
c_cal = fr_cal_licor(791, 330, -57, 1674, 0, 3197, 2027)


%-----------------------------------------------------------------
% CR
%
c_cal = fr_cal_licor(174, 350, 18.5, 1770.5, 0, 1869.5, 1884.3)
c_cal = fr_cal_licor(174, 350, 	 20, 1769.8, 0, 1876.5, 1883.2)
c_cal = fr_cal_licor(174, 350, 	 20, 1768.5, 0, 1883.5, 1882.6)
% Dec 10, 1997
c_cal = fr_cal_licor(174, 350,   20, 1858, 0, 1597, 2116)
c_cal = fr_cal_licor(174, 350, 20, 1860, 0, 1599, 2117)
% Dec 22, 1997
c_cal = fr_cal_licor(174, 350, 27, 1819, 0, 1336, 1921)
%Jan 29, 1998
c_cal = fr_cal_licor(174, 350, 19.68, 1742.4, 0, 2193, 1838)
%Jan 30, 1998
c_cal = fr_cal_licor(174, 350, 21.5, 1784, 0, 2018, 1955)
%Feb 5, 1998 With possible leaking zero tank
c_cal = fr_cal_licor(174, 350, 23, 1841, 0, 1743, 2086)

% Feb 24, 1998 (GOOD calibration)
c_cal = fr_cal_licor(174, 346.9, 21.85, 1780.2, 0, 1861.5, 2080)