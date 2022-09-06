function boreas_table_export(file_opts,traces,export_mat)
% boreas_table_export(file_opts,traces,export_mat)
%
% Export the traces structure, that comes out of first or second stage cleaning 
% to a BOREAS style ascii table, using the information in file_opts.
%
% Fields of file_opts used here:
%	out_path 	(required)
%	out_name 	(optional, default: data.txt)
%  days 			(optional, if not present, all data is output)
%	station_id 	(optional, default: ***)
%	station_no 	(optional, default: 0)
%	table_id 	(optional, default: 0)
%
% export_mat is an optional argument, that is assumed to contain the .data columns
% of traces in matrix form (as in the output of trace_export). It is assumed to contain
% only the data given by file_opts.days. 
% If not present it is created here.
%
%	kai* 	Created:			15 Dec, 2000
%			Last Modified: 15 Dec, 2000

if ~isfield(file_opts,'out_path')
   disp('file_opts must contain out_path.');
   return
end
if file_opts.out_path(end) ~= '\'
   file_opts.out_path(end+1) = '\';
end

if ~isfield(file_opts,'out_name')
   file_opts.out_name = 'data.txt';
end
if ~isfield(file_opts,'station_id')
   file_opts.station_id = '***';
end
if ~isfield(file_opts,'station_no')
   file_opts.station_no = 000;
end
if ~isfield(file_opts,'table_id')
   file_opts.table_id = 000;
end
% Time vector should be the same for all variables, so use first trace to get time vector
clean_tv = traces(1).timeVector;
% traces(1).DOY contains local time, so create DOY here
[doy,year] = convert_tv(clean_tv,'doy');
if ~isfield(file_opts,'days')
   file_opts.days = [floor(doy(1)) floor(doy(end))];
end

% Let data start at 0030 ond .days(1) and end at 2400 on .days(2)
ind_tv     = find(doy <= file_opts.days(2)+1 & ... 
                  doy >  file_opts.days(1));
clean_tv   = clean_tv(ind_tv);
% Get no of day , i.e. floor doy, in range requested
doy        = floor(doy(ind_tv));
year       = year(ind_tv);

n = length(traces);
m = length(clean_tv);

% Create first two row of output table: Variable names & units
header1 = 'Table Year Day End_Time Station_ID ';
header2 = ['(All) (UTC) (UTC) (HrMn_UTC) (' file_opts.station_id ') '];
for i = 1:n
   header1 = [header1 traces(i).variableName ' '];

   % kai* June 6, 2001
   % Space is throughn out here, so table can be loaded easily
   ind = find(traces(i).ini.units ~= ' ');
   units = traces(i).ini.units(ind);
   % end kai*
   header2 = [header2 '(' units ') '];
end

% Create time stamps
table_id   = char(ones(m,1) * num2str(file_opts.table_id,'%03i'));
dlm        = char(ones(m,1) * ' ');
station_id = char(ones(m,1) * num2str(file_opts.station_no,'%03i'));
dtvec      = datevec(clean_tv);
hh         = dtvec(:,4);
ind_hh     = find(hh == 0);
hh         = int2str(hh);
hh(ind_hh,:) = char(ones(length(ind_hh),1) * '  ');
mm         = dtvec(:,5);
ind_mm     = find(mm == 0);
mm         = int2str(mm);
mm(ind_mm,:) = char(ones(length(ind_mm),1) * '00');

hhmm       = [hh mm];
time_stamp = [table_id dlm int2str(year) dlm int2str(doy) dlm hhmm dlm station_id dlm];

% Create export data, if not present
if ~exist('export_mat') | isempty(export_mat)
   export_mat = NaN .* zeros(m,n);
   for i = 1:n
      export_mat(:,i) = traces(i).data(ind_tv);
   end
else
      export_mat = export_mat(ind_tv,:);
end

ind_dat = find(isnan(export_mat) == 1);
export_mat(ind_dat) = -999;

% Bring all rows in the strings matrix to the same length
out_data = [time_stamp num2str(export_mat)];
fp = fopen([file_opts.out_path file_opts.out_name],'w');
fprintf(fp,'%s\n',header1);
fprintf(fp,'%s\n',header2);
for i = 1:m
   k = fprintf(fp,'%s\n',out_data(i,:));
end
fclose(fp);
