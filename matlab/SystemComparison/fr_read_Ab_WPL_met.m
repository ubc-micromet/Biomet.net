function [EngUnits,Header] = fr_read_Ab_WPL_met(dateIn,configIn,instrumentNum)
% fr_read_Digital2 - reads data that is stored as a matrix of 2-byte signed integers with a header
% 
% This procedure supports all the new (2001->)UBC DAQ programs that use
% header structures. Needs a standard UBC ini file. Reads only one data file.
%
% Inputs:
%   dateIn      - datenum (this is not a vector, only one file is read at the time)
%   configIn    - standard UBC ini file
              %   systemNum   - system number (see the ini file)
%   instrumentNum - instrument number (see the ini file)
%
% Outputs:
%   EngUnits    - data matrix if file exists, empty if file is missing
%   Header      - file header
%
%
% (c) Zoran Nesic           File created:       Sep 26, 2001
%                           Last modification:  Aug 13, 2002

% Read data 
[Data_xls,Header_xls] = xlsread('D:\Experiments\AB-WPL\SiteData\met\AB_WPL_met.xls');
[n,m] = size(Data_xls);

var_name = configIn.Instrument(instrumentNum).OriginalName;

ind_var = intersect(find(strcmp(var_name(1),Header_xls(1,:))),find(strcmp(var_name(2),Header_xls(2,:))));

tv = datenum(Data_xls(:,2),ones(n,1),Data_xls(:,3),floor(Data_xls(:,4)./100),mod(Data_xls(:,4),100),0);
ind_tv = find(fr_round_hhour(dateIn) == fr_round_hhour(tv));

if ~isempty(ind_tv)
    EngUnits = Data_xls(ind_tv,ind_var);
    Header = [char(Header_xls(2,ind_var)) ' ' char(Header_xls(1,ind_var))];
else
    disp('No met data available for this period!')
    EngUnits = NaN;
    Header = [];
end



