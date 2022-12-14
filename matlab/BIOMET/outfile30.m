%  outfile30.m
%
%   This function creates a datafile to be used for Roland Stull/Trina
colordef none
corrected = 0; % default to uncorrected data
dateToday = datevec(now);
yearToday = dateToday(1);
GMTshift = 8/24;                                    % ubc data is in GMT

%in_pth =
%sprintf('\\\\ANNEX001\\DATABASE\\%d\\UBC_Climate_Stations\\Totem',yearToda
%y);
in_pth = sprintf('\\\\ANNEX001\\DATABASE\\%d\\UBC_Totem\\Climate\\Totem1',yearToday);
out_pth = 'D:\Sites\web_page_weather\';

filename='\ubc.';
indOut    = [];

t=read_bor([ in_pth '\ubc_tv'],8);                  % get decimal time from the data base
 
num_days = 7;                      					% number of days to be plotted

ind = find( t >= (now-num_days) & t <=  now);        % extract the requested period
t = t(ind)-datenum(yearToday,1,0);

%-----------------------------------------------
% Read all data columns

for i = 5:29
   col_id = num2str(i);
   c = sprintf('c%s=read_bor(%s%s%s%s%s,[],[],[],indOut);',col_id,39,in_pth,filename,col_id,39);
   eval(c); 
end

	air_temp = c5(ind);
   soil1 = c8(ind);
	soil2 = c9(ind);
	soil3 = c10(ind);
   max_wspd = c24(ind);
   min_wspd= c25(ind);
   wind_speed = c14(ind);
	wdir = c16(ind);
   rain = c26(ind);
   RH = c6(ind);
   air_temp = c5(ind);
   solar = c7(ind);
   rain = c26(ind);
   snow = c29(ind);
   
	form='%12.6f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f \r\n';

   filestring = sprintf('%ssummary.dat', out_pth);
   fid=fopen([ filestring ],'wt');
   lotus_offset=datenum(yearToday,1,1)-datenum(1900,1,1)+1; % to convert matlab decimal time to Lotus/Excel time
   for n=1 : max(size(t))
      if RH(n)>100.0
          RH(n)=100.0;
      end
      if air_temp(n)+wind_speed(n)+wdir(n)+solar(n)+rain(n)+RH(n) ~=0
          fprintf(fid, form, t(n)+lotus_offset, air_temp(n), wind_speed(n), wdir(n), solar(n), rain(n), RH(n));
      end    
	end

   fclose(fid);


