% findRawTraceName - finds the trace name in the rawData structure based on it's name in configIn.chamber.traces name
% 
%   strTraceName = findRawTraceName(configIn,chNum,traceName)
%
%
%
%
% File created                  Aug 29, 2023
% Last modification:            Aug 29, 2023 (Zoran)
%

% Revisions:
%   

function strTraceName = findRawTraceName(configIn,chNum,traceName)
    strTraceName = [];
    for cntTraces = 1:size(configIn.chamber(chNum).traces,1)
        if strcmp(char(configIn.chamber(chNum).traces{cntTraces}),traceName)
            strTraceName = configIn.chamber(chNum).traces{cntTraces,4};
            break;
        end
    end
end