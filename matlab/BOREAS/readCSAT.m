function x = readCSAT(fileName)
% x = readCSAT(fileName) - function that reads CSAT3 binary data (with delimiters)
%
% Inputs:
%   fileName    -   full file name (path and everything)
% Outputs:
%   x           -   a matrix of 5 columns (ux,uy,uz,ts and diagnostic word)
%                   Wind speeds are in m/s and the temperature is in deg C
%
%
% (c) Zoran Nesic           File created:   May 13, 2002
%                           Last revision:  May 16, 2002


% Constants
Rd = 287.04;  % J/K/kg
gamad = 1.4;

% Read data
fid=fopen(fileName,'rb');
if fid < 0 
    error 'Wrong file name'
end
x=fread(fid,[1 Inf],'int16');
fclose(fid);
ind = find(x==-21931);          % find delimiter word

if ind(1) < 6
    indStart = ind(1)+1;        % if there is an incomplete line at the beginning skip it
elseif ind(1)==6
    indStart = 1;               % if the first delimiter is ind==6 first line is complete
end

n = length(x);
if ind(end) < n
    indEnd = ind(end);          % if there is an incomplete line at the end crop it
else
    indEnd = n;                 % otherwise keep the end part in
end

x = x(indStart:indEnd);
x=reshape(x,[6 length(x)/6])';  % reshape vector x into a matrix [~36000 by 6]
x = x(:,1:5);                   % remove the delimiter column

bitX = 16;

diagX = x(:,5);
strX = dec2bin(diagX,bitX); 

%Extract each bit from 16 bit diagnostic string
%nb1 = strX(:,(bitX-0))=='1';
%nb2 = strX(:,(bitX-1))=='1';
%nb3 = strX(:,(bitX-2))=='1';
%nb4 = strX(:,(bitX-3))=='1';
%nb5 = strX(:,(bitX-4))=='1';
nb6 = strX(:,(bitX-5))=='1';
nb7 = strX(:,(bitX-6))=='1';
nb8 = strX(:,(bitX-7))=='1';
nb9 = strX(:,(bitX-8))=='1';
nb10 = strX(:,(bitX-9))=='1';
nb11 = strX(:,(bitX-10))=='1';
%nb12 = strX(:,(bitX-11))=='1';
%nb13 = strX(:,(bitX-12))=='1';
%nb14 = strX(:,(bitX-13))=='1';
%nb15 = strX(:,(bitX-14))=='1';
%nb16 = strX(:,(bitX-15))=='1';

% Calculate Ux in m/s
cx = 2.^(2.^nb11 + nb10-1);
ux = x(:,1)*0.001./cx;

% Calculate Uy in m/s
cy = 2.^(2.^nb9 + nb8-1);
uy = x(:,2)*0.001./cy;

% Calculate Uz in m/s
cz = 2.^(2.^nb7 + nb6-1);
uz = x(:,3)*0.001./cz;

% Speed of sound (m/s)
c = ((x(:,4)*0.001) + 340.0);

% Sonic Virtual Temperature (deg C)

ts = ((c.^2)/(gamad*Rd)) - 273.15;

x = [ux uy uz ts diagX];