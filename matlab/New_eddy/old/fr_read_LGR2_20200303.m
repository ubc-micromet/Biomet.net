function [EngUnits,Header] = fr_read_LGR2(dateIn,configIn,instrumentNum)
% fr_read_LGR - reads data that is created by LGR CH4/N2O instrument
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
%
%
% (c) Zoran Nesic           File created:       Jan 30, 2019
%                           Last modification:  Jan 30, 2019

% Revisions
%  Jan 30, 2019 (Zoran)
%   - file created base on fr_read_LGR2.m
%


    [fileName,dummy] = fr_find_data_file(dateIn,configIn,instrumentNum);

    if isempty(fileName)
        error(['File: ' dummy ' does not exist!'])
    end

    [EngUnits,Header,tv] = fr_read_LGR1_file(fileName,[],1);
    % The LGR data is sampled at an odd rate (instead of 18000 samples per
    % 30min or 10Hz it collects over 22,000.  Luckly, it timestamps each
    % data sample so we'll need to resample data to 20 Hz during the System
    % creation part of the EC program
    % Preserve the time vector by adding it to the end
    % and add the channel name to be "tv"
    EngUnits(:,end+1) = tv;  
    Header.line3{end+1} = 'tv';
    