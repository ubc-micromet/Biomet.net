function tv = fr_CSI_time(x);
% fr_CSI_time - converts Campbell logger time to time vector
% 
%
% Inputs:
%   x (:,1) -   year
%   x (:,2) -   doy
%   x (:,3) -   hhmm
%   
% Outputs:
%   tv      - time vector
%
%
% (c) Zoran Nesic           File created:       July 6, 2004
%                           Last modification:  July 6, 2004

% Revisions
%
hourIn = fix(x(:,3)/100);
minuteIn = x(:,3)-hourIn*100;
tv = datenum(x(:,1),1,x(:,2),hourIn,minuteIn,0);
