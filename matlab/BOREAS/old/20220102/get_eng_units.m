function [EngUnits] = get_eng_units(FileName)
%
%
% This program reads raw data from 'FileName' (old 1994 - Nov 1997 file format for
% UBC eddy cov. system) and converts it to eng units.
%
%
% Zoran Nesic               File created:       Dec 8, 1999
%                           Last modification:  Dec 8, 1999
%



% Read raw data file
[RawData,header] = read_met(FileName);

% remove bad data (spiking caused by the communication errors)
Threshold = 1800;
ind = find(abs(RawData(1,:)) > Threshold | abs(RawData(2,:)) > Threshold | abs(RawData(3,:)) > Threshold);
RawData(:,ind) = [];
if length(ind) > 0
    fid = fopen('recalc.log','a');
    fprintf(fid,'%d of %d lines removed in %s\n',length(ind),length(RawData), FileName);
    fclose(fid);
end

% change the calibration constants if they don't
% make sense
if header(76) > 1.1 | header(76) < 0.8 | abs(header(75))>100 | abs(header(74))>100
    header(77) = 1;
    header(75) = 22;
    header(76) = 0.908;
    header(74) = 36;
end
% Convert to Eng. units
EngUnits = eng_met1(RawData, header,0,0,0);
