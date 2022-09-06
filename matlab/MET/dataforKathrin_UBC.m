function dataforKathrin_UBC;
%Data for Rachelle from CR site
%

% kai* Sep 09, 2004 base on dataforal_cr
%
% Revisions:     

format short g;

[yyyy,mm, dd] = datevec(now);
% years   = yyyy;
years   = 2004:2005;

ptha  = biomet_path('yyyy','UBC_Climate_Stations','Totem');

GMT_shift = 8/24;       %shift grenich mean time to 24hr day
tv        = read_bor([ptha 'ubc_tv'],8,[],years);
tv = tv-GMT_shift;

ind = find(tv<floor(now)-1);

traces_to_load = {...
'AirTemp_AVG',...
'Humidity_AVG',...
'Solar_AVG',...
'Rain_TOT_2'...
};

traces_units = {...
      '^oC',...
      '%',...
      'W m^{-2}',...
      'mm'...
};

datevector = datevec(tv);

output = [datevector(:,1) ...
      datevector(:,2) ...
      datevector(:,3) ...
      datevector(:,4) ...
      datevector(:,5)];

output(:,6) = read_bor([ptha 'ubc.5'],[],[],years);
output(:,7) = read_bor([ptha 'ubc.6'],[],[],years);
output(:,8) = read_bor([ptha 'ubc.7'],[],[],years);
output(:,9) = read_bor([ptha 'ubc.26'],[],[],years);

string_mat  = 'Year,Month,Day,Hr,Min';
string_unit = ' , , , , ';
string_form = '%4i,%2i,%2i,%2i,%2i';

for i = 1:length(traces_to_load)
   %eval(['output = [output ' char(traces_to_load(i)) '];']);   
   string_mat  = [string_mat,',',char(traces_to_load(i))];
   string_unit = [string_unit,',',char(traces_units(i))];
   string_form = [string_form,',%4.2f'];
end

fname = (['D:\Sites\web_page_weather\ubc_kathrin.txt']);

FID = fopen(fname, 'wt');
fprintf(FID, '%s\n',string_mat);
fprintf(FID, '%s\n',string_unit);
fprintf(FID, [string_form '\n'],output(ind,:)');
fclose(FID);

return
