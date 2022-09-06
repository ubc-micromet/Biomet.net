function chansOut = fr_reorder_chans(chansIn,siteID,dateIn)
%
% chansIn		- channel numbers (as wired)
% chansOut		- channel numbers (as in EngUnits)
%
% Works on the DAQ book data only.
%
% (c) Zoran Nesic               File created:       Mar 23, 1999
%                               Last modification:  Sep  4, 2001
%

% Revisions:
%
% Sep 4, 2001
%   - fixed a bug that caused the function to insist on existance of "siteID" parameter
%     One can use this function now with only one input: fr_reorder_chans(1)
% Mar 20, 2001
%   - added an option to pass configuration file instead siteID. That
%     speeds up the function by avoiding time-consuming calls to
%     fr_get_init.
% Oct 10, 2000
%   - added the dateIn parameter
% Jun 8, 2000
%   - made it work for all sites and both MUX cards
%


%
% If the second input parameter us structure then
% it must be the configuration file passed to this
% function by its parent function. In that case
% use the structure - DO NOT call again fr_get_init
% Mar 20, 2001
if exist('siteID')~=1 | isempty(siteID) | ~isstruct(siteID)
    if exist('siteID')~=1 | isempty(siteID)
        siteID = fr_current_siteid;
    end
    if exist('dateIn')~=1 | isempty(dateIn)
        dateIn = now;
    end
    c=fr_get_init(siteID,dateIn);
else
    c = siteID;
end

ChanReorder =  c.ChanReorder;

ChanReorder = ChanReorder(5:end);           % skip thermocouple channels
[j,k] = sort(ChanReorder);
chansOut = k(chansIn+1)+4;                  % add one to skip zero chan for MUX1 and add 4 to skip TC card
ind = find(chansOut>20);
chansOut(ind) = chansOut(ind)+1;            % skip zero chan. for MUX2
