function x = DBC_Bonet
%
% This is conversion file that enables switching from old Bonet format
% (before May 1998) to the new one. It uses the old traces (when they
% exist) to produce continuous traces. 
%
% NOTE:
%   Flag files are NOT updated (if one is using flag files he/she would
%   see only the new data points).
%
% (c) Zoran Nesic       File created:       Jun 8, 1998
%                       Last modification:  Jun 8, 1998
%

oldFileName = 'r:\paoa\newdata\bonet\bnt';
newFileName = 'r:\paoa\newdata\bonet_new\bntn';
fromChannel = [58 7 22 57 23:31 8 9 12 61 56 5 14 16 10 18 6 15 17 11 19 73 77 ...
               60 32:36 55 81 82 66:72];
toChannel   = [6:41 43:52 53:104];
fromChannel = [fromChannel 80*ones(1,length(toChannel)-length(fromChannel))];
toChannel   = [6:41 43:52 53:104];
[s,w] = copy_all(oldFileName, newFileName, fromChannel, toChannel);

oldFileName = 'r:\paoa\newdata\bonet\bnt1';
newFileName = 'r:\paoa\newdata\bonet_new\bntn1';
fromChannel = [5:64];
toChannel   = [5:64];
[s,w] = copy_all(oldFileName, newFileName, fromChannel, toChannel);

oldFileName = 'r:\paoa\newdata\bonet\bnt';
newFileName = 'r:\paoa\newdata\bonet_new\bntn3';
fromChannel = [37:41 43:47];
toChannel   = [6:15];
[s,w] = copy_all(oldFileName, newFileName, fromChannel, toChannel);



% ------- Local functions --------------
function [s,w] = copy_all(oldFileName, newFileName, fromChannel, toChannel)

    for i=1:length(fromChannel)
        c = ['copy ' oldFileName '.' num2str(fromChannel(i)) ' ' newFileName '.' num2str(toChannel(i))];
        [s, w] = dos(c);
    end
