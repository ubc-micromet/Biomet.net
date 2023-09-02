% findRawTraceName - finds the trace name in the rawData structure based on it's name in configIn.chamber.traces name
% 
%   [strTraceName,strInstrumentName,strInstrumentType]  = findRawTraceName(configIn,chNum,traceName)
%
% For the give inputs it returns: strTraceName,strInstrumentName,strInstrumentType.
% These strings define the raw data source for the traceName.
%
% Example:
%  If the ini file shows:
%               configIn.chamber(1).traces = { ...
%               'h2o_ppm',          'analyzer', 'PICARRO' ,    'H2O';]
% then:
%  strTraceName         = 'H2O'
%  strInstrumentName    = 'PICARRO'
%  strInstrumentType    = 'analyzer'
%
%
%
% File created                  Aug 29, 2023
% Last modification:            Sep  1, 2023 (Zoran)
%

% Revisions:
%   
% Sep 1, 2023 (Zoran)
%  - added strInstrumentName and strInstrumentType outputs.

function [strTraceName,strInstrumentName,strInstrumentType] = findRawTraceName(configIn,chNum,traceName)
    strTraceName = [];
    strInstrumentName = [];
    strInstrumentType = [];
    for cntTraces = 1:size(configIn.chamber(chNum).traces,1)
        if strcmp(char(configIn.chamber(chNum).traces{cntTraces}),traceName)
            strTraceName = configIn.chamber(chNum).traces{cntTraces,4};
            strInstrumentName = configIn.chamber(chNum).traces{cntTraces,3};
            strInstrumentType = configIn.chamber(chNum).traces{cntTraces,2};
            break;
        end
    end
end