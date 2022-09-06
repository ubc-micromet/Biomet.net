%  outfile30_solar.m
%
%   This function creates a datafile for Oliver Riche / Richard Pawlowicz
colordef none
corrected = 0; % default to uncorrected data
dateToday = datevec(now);
yearToday = dateToday(1);
GMTshift = 8/24;                                    % ubc data is in GMT

%in_pth = sprintf('\\\\ANNEX001\\DATABASE\\%d\\UBC_Climate_Stations\\Totem',yearToday);
in_pth = sprintf('\\\\ANNEX001\\DATABASE\\%d\\UBC_Totem\\Climate\\Totem1',yearToday);
out_pth = 'D:\Sites\web_page_weather\';

filename='\ubc.';
indOut    = [];

t=read_bor([ in_pth '\ubc_tv'],8);                  % get decimal time from the data base
 
num_days = 30;                      					% number of days to be plotted

ind = find( t >= (now-num_days) & t <=  now);        % extract the requested period
t = t(ind)-datenum(yearToday,1,0);

%-----------------------------------------------
% Read all data columns

for i = 7:31
   col_id = num2str(i);
   c = sprintf('c%s=read_bor(%s%s%s%s%s,[],[],[],indOut);',col_id,39,in_pth,filename,col_id,39);
   eval(c); 
end

   solar = 1.31 * c7(ind);	%correct for drift
   lw30 = c30(ind);
   lw31 = c31(ind) + 273.15;
   
   longwave = lw30 +(5.67e-8*(lw31.^4));
 

	form='%12.6f %8.3f %8.3f  \r\n';

   filestring = sprintf('%ssolar.dat', out_pth);
   fid=fopen([ filestring ],'w');
   lotus_offset=datenum(yearToday,1,1)-datenum(1900,1,1)+1 - GMTshift; % to convert matlab decimal time to Lotus/Excel time
   for n=1 : max(size(t))
      fprintf(fid, form, t(n)+lotus_offset, solar(n), longwave(n));
	end

   fclose(fid);


