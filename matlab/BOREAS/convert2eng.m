function [x,units] = convert2eng(RawData)

[n,m] = size(RawData);
v = RawData * 5000/2^15;
x = v;

x(1,:)  = v(1,:) / 100;
x(8,:)  = 0.01221 * v(8,:);
x(9,:)  = polyval([0.01531 59.09  ], v( 9,:));
x(10,:) = polyval([0.01226 -0 ], v(10,:));
x(11,:) = polyval([0.40000  0.1492], v(11,:));
x([12 14 15],:) = ( v([12 14 15],:) - 2500 ) * 30/2500;
x(13,:) = (0.016 * v(13,:) + 290).^2 / 403 - 273.16 ;

units = str2mat('degC','mV','mV','mV','mV','mV','mV','degC','kPa','kPa');
units = str2mat(units,'kPa','m/s','degC','m/s','m/s');
