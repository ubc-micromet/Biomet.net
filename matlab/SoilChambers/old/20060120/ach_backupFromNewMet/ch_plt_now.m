function [Time_vector21x, data_21x, data_CR10] = ch_plt_now(currentDate,SiteID)

if exist('SiteID')~= 1 | isempty(SiteID)
    SiteID = fr_current_siteID;
end
if exist('currentDate')~= 1 | isempty(currentDate)
    currentDate = now;
end
 
 
[data_21x,data_CR10] = ch_read_data(currentDate,SiteID,1);

[pthHF, pthHH] = fr_get_local_path;

c = fr_get_init(SiteID,currentDate);                        % get the init data

%------------------------------------------------------------------------------------
%define time variables and create a Time_vector using datenum with format
%of Time_vector = datenum(year, month, day, hour, min, seconds)
          hour = floor(data_21x(:,4) / 100);										
       minutes = data_21x(:,4) - hour*100;				
         month = ones(size(data_21x(:,2))); 
   
   Time_vector21x = datenum(data_21x(:,2),...
                         month,...
                         data_21x(:,3),...
                         hour,...
                         minutes,...
                         data_21x(:,5));

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


%convert Licor data to Engineering units
[co2_ppm,h2o_mmol,Temperature,Pressure] = fr_licor_calc(c.chamber.Licor, [], ...
                                           data_21x(:,9), data_21x(:,10), ...
                                           data_21x(:,6),data_21x(:,7),...
                                            c.chamber.CO2_Cal,c.chamber.H2O_Cal);



figure(1)
plot(Time_vector21x, data_21x(:,9))
datetick('x',13)
xlabel(datestr(Time_vector21x(end),1))

figure(2)
plot(Time_vectorCR10, data_CR10(:,5+[8:11]),Time_vector21x,data_21x(:,9)/100)
legend('air_s','air_n','tb_s','tb_n')
datetick('x',13)
xlabel(datestr(Time_vectorCR10(end),1))
