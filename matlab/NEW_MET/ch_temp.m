fname = 'd:\met-data\csi_net\chambers_temp\cham_21x.dat';
data_21x = textread(fname,'%f','delimiter',',');
data_21x = reshape(data_21x,11,length(data_21x)/11)';
          hour = floor(data_21x(:,4) / 100);										
       minutes = data_21x(:,4) - hour*100;				
         month = ones(size(data_21x(:,2))); 
   
   Time_vector21x = datenum(data_21x(:,2),...
                         month,...
                         data_21x(:,3),...
                         hour,...
                         minutes,...
                         data_21x(:,5));

fname = 'd:\met-data\csi_net\chambers_temp\cham_cr.dat';

data_CR10 = textread(fname,'%f','delimiter',',');
data_CR10 = reshape(data_CR10,31,...
                     length(data_CR10)/31)';
hour = floor(data_CR10(:,3) / 100);										
minutes = data_CR10(:,3) - hour*100;				
month = ones(size(data_CR10(:,2)));
seconds = zeros(size(hour));
% Note: here we use 21x Year because cr10 data does not have that field !!??
Year   = data_21x(1,2)*ones(size(hour));
   
Time_vectorCR10 = datenum(Year,...
                         month,...
                         data_CR10(:,2),...
                         hour,...
                         minutes,...
                         seconds);

figure(1)
plot(Time_vector21x,data_21x(:,8))
datetick('x',13)
xlabel(datestr(Time_vector21x(end),1))
zoom on

figure(2)
plot(Time_vector21x,data_21x(:,9))
datetick('x',13)
xlabel(datestr(Time_vector21x(end),1))
zoom on

figure(3)
plot(Time_vectorCR10, data_CR10(:,5+[8:11]),Time_vector21x,data_21x(:,9)/100)
legend('air_s','air_n','tb_s','tb_n','co2(mV)/100')
datetick('x',13)
xlabel(datestr(Time_vectorCR10(end),1))
zoom on

figure(4)
plot(Time_vector21x,data_21x(:,7))
title('Pressure (mV)')
datetick('x',13)
xlabel(datestr(Time_vector21x(end),1))
zoom on

figure(5)
plot(Time_vector21x,data_21x(:,6))
title('Temperature (mV)')
datetick('x',13)
xlabel(datestr(Time_vector21x(end),1))
zoom on

%figure(6)
%plot(Time_vector21x,data_21x(:,11))
%title('MFC flow (ml/min)')
%datetick('x',13)
%xlabel(datestr(Time_vector21x(end),1))
%zoom on
