%
%
% QC_inpt
%
%   This program imports BOREAS high freq. data using the format
%   required by QCpak (see: QCPAK User Guide, College of Oceanic and
%   Atmospheric Sciences, Oregon State University, Corvallis, OR 97331, USA
%   Andrew Kowalski, Michael Jones and Dean Vickers)
%
%
%
% (c) Zoran Nesic			File created:	    Apr 16, 1997
%                           Last modification:  Apr 30, 1997
%

%InputFileName = 'd:\qcpak\test_dat.bin';
InputFileName = 'n:\met-data\resdrp.prt';
%InputFileName = 'd:\qcpak\data001.dat';
%=================
% constants
%=================
IntegerFormat = 'int32';
FloatFormat = 'float32';
KeyString = '##';
HEADER_LEN = 74;
%-----------------

fid =fopen(InputFileName,'rb');


lenTmp1 = fread(fid,[1 1],IntegerFormat);               % read length at the beginning
Header1 = setstr(fread(fid,[1 lenTmp1],'char'));
disp(Header1);
lenTmp2 = fread(fid,[1 1],IntegerFormat);               % and at the end of each record
if lenTmp2 ~= lenTmp1
    error 'Wrong record format';
end

lenTmp1 = fread(fid,[1 1],IntegerFormat);               % read length at the beginning
Header2 = setstr(fread(fid,[1 lenTmp1],'char'));
disp(Header2);
lenTmp2 = fread(fid,[1 1],IntegerFormat);               % and at the end of each record
if lenTmp2 ~= lenTmp1
    error 'Wrong record format';
end

lenTmp1 = fread(fid,[1 1],IntegerFormat);               % read length at the beginning
key = setstr(fread(fid,[1 2],'char'));                  % read the key characters
Fs = fread(fid,[1 1],FloatFormat);                      % read sampling freq.
YearX = fread(fid,[1 1],IntegerFormat);                 % read year
MonthX = fread(fid,[1 1],IntegerFormat);                % read month
DayX = fread(fid,[1 1],IntegerFormat);                  % read day
n_vars = fread(fid,[1 1],IntegerFormat);                % read n_vars
lenTmp2 = fread(fid,[1 1],IntegerFormat);               % and at the end of each record
if lenTmp2 ~= lenTmp1
    error 'Wrong record format';
end
disp(sprintf('Fs = %d, Date: %d-%d-%d, n_vars = %d\n',Fs,YearX,MonthX,DayX,n_vars));

name = zeros(n_vars,16);
units = zeros(n_vars,8);
long_name = zeros(n_vars,40);
for i=1:n_vars
    lenTmp1 = fread(fid,[1 1],IntegerFormat);           % read length at the beginning
    key = setstr(fread(fid,[1 2],'char'));              % read the key characters
    name(i,:) = setstr(fread(fid,[1 16],'char'));       % read name
    units(i,:) = setstr(fread(fid,[1 8],'char'));       % read units
    long_name(i,:) = setstr(fread(fid,[1 40],'char'));  % read long name
    lenTmp2 = fread(fid,[1 1],IntegerFormat);           % and at the end of each record
    if lenTmp2 ~= lenTmp1
        error 'Wrong record format';
    end
    disp(sprintf('name = %16s, units = %8s, long_name = %40s', ...
                 name(i,:),units(i,:),long_name(i,:)));
end

curr_pos = ftell(fid);
fseek(fid,0,1);
end_pos = ftell(fid);
k_max = (end_pos - curr_pos)/(n_vars+3)/4
fseek(fid,curr_pos,-1);

tic
data_in = fread(fid,[n_vars+3 k_max],FloatFormat)';     % read all the data
toc

fclose(fid);
data_in = data_in(:,2:n_vars+2);                        % remove record lengths from data
                                                        % (FORTRAN puts them before and after
                                                        %    each record)