function [EngUnits,Header,LGR] = fr_read_LGR2(dateIn,configIn,instrumentNum)
% fr_read_LGR2 - reads data that is created by LGR CH4/CO2 instrument (UdeM)
% 
%
% Inputs:
%   dateIn      - datenum (this is not a vector, only one file is read at the time)
%   configIn    - standard UBC ini file
%   instrumentNum - instrument number (see the ini file)
%
% Outputs:
%   EngUnits    - data matrix if file exists, empty if file is missing
%   Header      - file header
%   LGR         - output structure containing all variables
%
%
% (c) Zoran Nesic           File created:       Jan  22, 2020
%                           Last modification:  Jan  31, 2020

% Revisions
%
% Jan 31, 2020 (Zroan)
%   - changed (for consistency)
%       configIn.Instrument(instrumentNum).Name
%     to
%       configIn.Instrument(instrumentNum).varName

arg_default('assign_in',0);
[fileName,dummy] = fr_find_data_file(dateIn,configIn,instrumentNum);

if isempty(fileName)
    error(['File: ' dummy ' does not exist!'])
end

flagUBCGII_ASCII    =configIn.Instrument(instrumentNum).flagUBCGII_ASCII;
varName             = configIn.Instrument(instrumentNum).varName;
forceReadASCII      = configIn.Instrument(instrumentNum).forceReadASCII;
assign_in           = configIn.Instrument(instrumentNum).assign_in;
[EngUnits, Header,tv] = fr_read_LGR2_file(fileName,assign_in,flagUBCGII_ASCII,varName,forceReadASCII);

% if assign_in==0
%     [EngUnits,Header,tv] = fr_read_LGR2_file(fileName,[],1);
% else
%     [EngUnits,Header,tv] = fr_read_LGR2_file(fileName,'caller',1);
%     LGR.tv = tv;
% end

% Preserve the time vector by adding it to the end
% and add the channel name to be "tv"
EngUnits(:,end+1) = tv;  
Header.line3{end+1} = 'tv';

    