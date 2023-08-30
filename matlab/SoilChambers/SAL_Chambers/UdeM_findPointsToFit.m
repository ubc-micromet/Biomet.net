function [t_oneSlope_sec,c_oneSlope,t_curvefit,gas_curvefit] = UdeM_findPointsToFit(timeIn,gasC,skipPoints,deadBand,timePeriodToFit)
% Extract index of points to fit based on:
%   skipPoint           -   number of *points* to skip
%   deadBand            -   number of *points* in the deadband 
%                           (points when chamber samples outside air)
%   timePeriodToFit     -   *time* period to fit.
%
% timeIn                -   in days
% gasC                  -   gas concentrations for the same period
%
%
%
% Zoran Nesic               File created:       Aug 29, 2023
%                           Last modification:  Aug 29, 2023
%

% First skip the points 
timeIn = timeIn(skipPoints:end,1);
c_oneSlope = gasC(skipPoints:end,1);

% Convert time to seconds. The first point starts at T = 0s
t_oneSlope_sec =(timeIn - timeIn(1))*24*60*60;    % time starts at 0s

% Extract period for curve fitting (time is in seconds)
ind_curvefit = find(t_oneSlope_sec>=deadBand & t_oneSlope_sec< deadBand+timePeriodToFit);
t_curvefit = t_oneSlope_sec(ind_curvefit);
gas_curvefit = c_oneSlope(ind_curvefit);

