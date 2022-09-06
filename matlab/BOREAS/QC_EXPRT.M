function x = qc_exprt(OutputFileName,pth,YearX,MonthX,DayX,HourX,HHour,file_ext)
%
%   x = qc_exprt(OutputFileName,pth,YearX,MonthX,DayX,HourX,HHour,file_ext)
%
% qc_exprt.m
%
%   This program exports BOREAS high freq. data using the format
%   required by QCpak (see: QCPAK User Guide, College of Oceanic and
%   Atmospheric Sciences, Oregon State University, Corvallis, OR 97331, USA
%   Andrew Kowalski, Michael Jones and Dean Vickers)
%
%       
%
%
% (c) Zoran Nesic               File created:       Apr 14, 1997
%                               Last modified:      Apr 29, 1997
%
%OutputFileName = 'd:\qcpak\data001.dat';                            % output file name
%pth = 'd:\cd-rom\rawdata\';                                         % raw data path
%YearX = 1997;                                                       % year
YearX_short  = YearX - 1990;
%MonthX = 4;
%DayX = 2;
%HourX = 18;
%HHour = 1;
%file_ext = 'n2';

Fs = 20.833;                                                        % sampling freq. (Hz)
n_vars = 9;                                                         % number of raw data columns

InputFileName = [pth    frmtnum(YearX_short(length(YearX)),1) ...
                        frmtnum(MonthX,2) ...
                        frmtnum(DayX,2) ...
                        frmtnum(HourX,2) ...
                        frmtnum(HHour,1) ...
                        '.' ...
                        file_ext];                                % raw data file name
%=================
% constants
%=================
IntegerFormat = 'int32';
FloatFormat = 'float32';
KeyString = '##';
%-----------------

[RawData, header] = read_met(InputFileName);
EngUnits = eng_met1(RawData,header);
N = length(EngUnits);
time_vector = linspace(0,60*30,N);
EngUnits = [time_vector ; EngUnits];

%************************************************
% test remove when done
%
%n_vars = 2;
%N = 18000;
%EngUnits = EngUnits(1:n_vars+1,1:N);
%EngUnits = test_data';
%************************************************

HEADER_1 = 'This is UBC test data set';                             % create header 1
HEADER_1 = [KeyString HEADER_1 ' '*ones(1,72-length(HEADER_1))];         % fill it up to 72 chars
HEADER_2 = 'Second header line';                                  % create header 2
HEADER_2 = [KeyString HEADER_2 ' '*ones(1,72-length(HEADER_2))];         % fill it up to 72 chars

name = str2mat('wind_u','wind_v','wind_w','Tair','co2','h2o','rho','Pbarometric','Pgauge',blanks(16));
units = str2mat('m/s','m/s','m/s','degC','umol/mol','mmol/mol','g/m^3','kPa','kPa',blanks(8));
long_name = str2mat('Solent wind speed: u', ...
                    'Solent wind speed: v', ...
                    'Solent wind speed: w', ...
                    'Solent temperature: T', ...
                    'LICOR 6262: co2', ...
                    'LICOR 6262: h2o', ...
                    'Krypton H2O: rho', ...
                    'Barometer: Pbarometric', ...
                    'LICOR 6262 gauge pressure: Pg', ...
                    blanks(40));

fid = fopen(OutputFileName,'wb');

lenTmp = length(HEADER_1);                          % length of record
fwrite(fid,lenTmp,IntegerFormat);                   % write length at the beginning
fwrite(fid,HEADER_1,'char');
fwrite(fid,lenTmp,IntegerFormat);                   % and at the end of each record

lenTmp = length(HEADER_2);                          % length of record
fwrite(fid,lenTmp,IntegerFormat);                   % write length at the beginning
fwrite(fid,HEADER_2,'char');
fwrite(fid,lenTmp,IntegerFormat);                   % and at the end of each record

lenTmp = 22;                                        % length of record
fwrite(fid,lenTmp,IntegerFormat);                 % write length at the beginning
fwrite(fid,KeyString,'char');
fwrite(fid,Fs,FloatFormat);
fwrite(fid,YearX,IntegerFormat);
fwrite(fid,MonthX,IntegerFormat);
fwrite(fid,DayX,IntegerFormat);
fwrite(fid,n_vars,IntegerFormat);
fwrite(fid,lenTmp,IntegerFormat);                 % and at the end of each record

lenTmp = 66;                                        % length of record
for i=1:n_vars
    fwrite(fid,lenTmp,IntegerFormat);             % write length at the beginning
    fwrite(fid,[KeyString name(i,:)...
                units(i,:) long_name(i,:)],'char');
    fwrite(fid,lenTmp,IntegerFormat);             % and at the end of each record    
end

%tic
lenTmp = (n_vars+1) * 4;                          % length of a record
for i = 1:N
    fwrite(fid,lenTmp,IntegerFormat);             % write length at the beginning
    fwrite(fid,EngUnits(:,i),FloatFormat);
    fwrite(fid,lenTmp,IntegerFormat);             % and at the end of each record        
end
%toc

fclose(fid);