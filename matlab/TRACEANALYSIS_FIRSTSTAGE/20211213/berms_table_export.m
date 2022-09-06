function berms_table_export(traces,export_path,file_opts,export_mat)
% berms_table_export(traces,export_path)
%
% Exports the data that is delivered to BERMS in monthly boreas-style ASCII files
%
%	kai* 	Created:			22 Dec, 2000
%			Last Modified: 22 Dec, 2000

% Assemble the file_opts information
if ~exist('file_opts') | ~isfield(file_opts,'out_path')
   file_opts.out_path = export_path;
end
   
switch upper(traces(1).SiteID)
case 'PA'
   file_opts.station_id = 'SOA';
   file_opts.station_no = 601; 
   file_opts.name_id = 'OA';
case 'BS'
   file_opts.station_id = 'SOBS';
   file_opts.station_no = 602; 
   file_opts.name_id = 'OB';
case 'JP'
   file_opts.station_id = 'SOJP';
   file_opts.station_no = 606; 
   file_opts.name_id = 'OJ';
case 'CR'
   file_opts.station_id = 'CR';
   file_opts.station_no = 101; 
   file_opts.name_id = 'CR';
case 'OY'
   file_opts.station_id = 'OY';
   file_opts.station_no = 102; 
   file_opts.name_id = 'OY';
case 'YF'
   file_opts.station_id = 'YF';
   file_opts.station_no = 103; 
   file_opts.name_id = 'YF';
end

if ~isfield(file_opts,'table_id') % if table_id is there so must be type_id & ext
   % Default export purposes
   switch upper(traces(1).ini.measurementType)
   case 'CL'
      file_opts.table_id = 784;
      file_opts.type_id = 'c';   
      file_opts.ext = '.CL1';   
   case 'FL'
      file_opts.table_id = 785;
      file_opts.type_id = 'e';   
      file_opts.ext = '.EC1';   
   case 'HIGH_LEVEL'
      file_opts.table_id = 786;
      file_opts.type_id = 'f';   
      file_opts.ext = '.FLX';   
   end
end

yy_str = num2str(traces(1).Year);
yy_str = yy_str(3:4);

clean_tv = traces(1).timeVector;
[doy,year] = convert_tv(clean_tv,'doy');

if isfield(file_opts,'days')
    ind_tv = find(doy >= file_opts.days(1) & doy <= file_opts.days(2) & (year == traces(1).Year | file_opts.days(2)>=365));
else
    ind_tv = 1:length(clean_tv);
end
% Loop through all the months in the data
dt_vec = datevec(clean_tv(ind_tv));
months_in_data = unique(dt_vec(:,2));

for mm = months_in_data'
   ind_mm = find(dt_vec(:,2) == mm);
   
   file_opts.days(1) = floor(doy(ind_mm(2)));
   file_opts.days(2) = floor(doy(ind_mm(end-1)));
   doy_str = sprintf('%03i',file_opts.days(1));
   
   file_opts.out_name = [file_opts.name_id file_opts.type_id yy_str doy_str file_opts.ext];
   
   if exist('export_mat')
      boreas_table_export(file_opts,traces,export_mat);
   else
      boreas_table_export(file_opts,traces);
   end
end

