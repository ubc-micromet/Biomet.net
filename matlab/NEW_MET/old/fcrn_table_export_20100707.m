function fcrn_table_export(traces_in,Type_str,pth_out,flag_six_months)
% fcrn_table_export(traces_in,Type_str,pth_out)
%
% Export the traces structure returned by read_data
% to monthly FCRN ascii datafiles as specified  by
% the Fluxnet Canada Data Management Plan
% 
% Mandatory elements in the trace structure are:
% trc(i).SiteID
% trc(i).Year
% trc(i).timeVector
% trc(i).data
% trc(i).ini.FCRN_Variable
% trc(i).ini.FCRN_DataType
% trc(i).ini.units
% trc(i).Last_Updated

%	kai* 	Nov 25, 2003
% 
%	Revisions:
%
% August 7, 2007
%   -Nick revised so that the first half-hour of every year is correctly
%   exported (previous version skipped to 01:00 for January)

%-------------------------------------------
% Check input
%-------------------------------------------
if ~exist('pth_out') | isempty(pth_out) 
   disp('Function call: fcrn_table_export(traces_in,Type_str,pth_out)');
   return
end

arg_default('flag_six_months',1)

% No of columns
traces = [];
for i = 1:length(traces_in)
   if isfield(traces_in(i).ini,'FCRN_Variable') & sum(strcmp(traces_in(i).ini.FCRN_DataType,Type_str)) % sum in case there is more than one entry
      traces = [traces traces_in(i)];
      if isempty(traces(end).data)
         traces(end).data = NaN.*ones(size(traces(end).timeVector));
      end
   end
end

if isempty(traces)
   disp(['No data to export to ' pth_out]);
   return
end

m = length(traces);

SubSite = 1;

% Create commen file name parts
SiteId = traces(1).SiteID;
switch upper(SiteId)
case 'CR'
   Site     = 101;
   Site_str = 'DF49';
   Stn      = 'BC';
case 'YF'
   Site     = 111;
   Site_str = 'HDF88';
   Stn      = 'BC';
case 'OY'
   Site     = 112;
   Site_str = 'HDF00';
   Stn      = 'BC';
case 'OR'
   Site     = 113;
   Site_str = 'OR';
   Stn      = 'BC';
case 'BS'
   Site     = 112;
   Site_str = 'OBS';
   Stn      = 'SK';
case 'JP'
   Site     = 000;
   Site_str = 'OJP';
   Stn      = 'SK';
case 'PA'
   Site     = 000;
   Site_str = 'OA';
   Stn      = 'SK';
case 'HJP02'
   Site     = 000;
   Site_str = 'HJP02';
   Stn      = 'SK';
case 'HJP75'
   Site     = 000;
   Site_str = 'HJP75';
   Stn      = 'SK';
otherwise
   Site     = 000;
   Site_str = SiteId;
   Stn      = SiteId;
end

switch SubSite
case 1
   SubSite_str = 'FlxTwr';
end

Dy = '00';

%-------------------------------------------
% Create the 2 header lines
%-------------------------------------------
header1 = 'DataType,Site,SubSite,Year,Day,End_Time,';
header2 = '(n/a),(n/a),(n/a),(UTC),(UTC),(HrMn_UTC),';
for i = 1:m
   header1 = [header1  traces(i).ini.FCRN_Variable ','];
   % Space is throughn out here, so table can be loaded easily
   ind = find(traces(i).ini.units ~= ' ');
   units = traces(i).ini.units(ind);
   header2 = [header2 '(' units '),'];
end
header1 = [header1 'CertificationCode,RevisionDate'];
header2 = [header2 '(n/a),(yyyymody)'];

CertificationCode = 'PRE';	 % Hard coded for now
dv = datevec(datenum(traces(1).Last_Updated));
RevisionDate = sprintf('%4i%02i%02i',dv(1:3));

%-------------------------------------------
% Extract time vector
%-------------------------------------------
% Time vector should be the same for all variables, so use 
% first trace to get time vector
clean_tv = fr_round_hhour(traces(1).timeVector);
if ischar(traces(1).Year)
   Year = str2num(traces(1).Year);
else
   Year = traces(1).Year;
end   
dt_vec = datevec(clean_tv);
mondate = dt_vec(:,1) .* 100 + dt_vec(:,2); 
ind = find(dt_vec(:,1) == Year);
months_in_data = unique(mondate(ind));

if flag_six_months == 1
    dv = datevec(now);
    % mm = mod(dv(2)+24-7,12)+1; % Last six months excluded
    mm = mod(dv(2)+24-4,12)+1; % Last three months excluded
    if mm > dv(2)
        yy = dv(1)-1;
    else
        yy = dv(1);
    end        
    dv = datevec(datenum(yy,mm,1));
    ind_six_months = find(months_in_data <= dv(1) .* 100 + dv(2));
    months_in_data  = months_in_data(ind_six_months);
end

%-------------------------------------------
% Extract and export monthly data
%-------------------------------------------
for i = 1:length(months_in_data)
   tic
   ind_mm = find(mondate == months_in_data(i));
   
   % clean_tv contains end of hhour intervals
   % ind_mm may contain 1st of month 00:00, which does not belong
   % to month and will not contain 31st 24:00 which does belong to
   % month. 
   %
   % ---August 7, 2007: Nick added fix (if statement) to make this work for January of each year---
   if months_in_data(i) - (Year .* 100) ~= 1
       ind_mm = ind_mm(2:end);
   end
   %----end of fix-----------------------------------------------------
   if length(dt_vec(:,1)) >= ind_mm(end)+1
       ind_mm = [ind_mm;ind_mm(end)+1];
   end
  
   % No of rows
   n = length(ind_mm);

   %-------------------------------------------
   % Create export filename
   %-------------------------------------------
   year_str = num2str(Year);
   mon_str  = num2str(dt_vec(ind_mm(1),2),'%02i');
   file_name = [Stn '-' Site_str '_' SubSite_str '_' ...
      Type_str '_' year_str '-' mon_str '-' Dy ...
      '.csv' ];
   
   %-------------------------------------------
   % Extract data
   %-------------------------------------------
   % Create line identifier as numbers
   doy = floor(clean_tv(ind_mm))-datenum(dt_vec(ind_mm(1),1),1,0);
   hhmm = dt_vec(ind_mm,4)*100+dt_vec(ind_mm,5);
   
   % Change doy 00hrs to (doy-1) 2400hrs
   ind_24 = find(hhmm == 0);
   hhmm(ind_24) = 2400;
   doy(ind_24) = floor(clean_tv(ind_mm(ind_24)))-1-datenum(dt_vec(ind_mm(1),1),1,0);
   
   export_mat = [ones(n,1) * [Year] doy hhmm NaN.*zeros(n,m)];
   % Write data into export matrix
   for j = [1:m]
         if ~isempty(traces(j).data)
            export_mat(:,3+j) = traces(j).data(ind_mm);
         end
   end
   
   %-------------------------------------------
   % Write output file line by line
   %-------------------------------------------
   fp = fopen(fullfile(pth_out,file_name),'w');
   if fp>0
      fprintf(fp,['%s\n'],header1);
      fprintf(fp,['%s\n'],header2);
      for k = 1:n
         % Format row
         str = format_dataline(export_mat(k,:),4);
         fprintf(fp,['%s,%s-%s,%s,%s,%s,%s\n'],Type_str,Stn,Site_str,SubSite_str,str,CertificationCode,RevisionDate);
      end
      fclose(fp);
      disp(['Exported ' file_name ' in ' num2str(toc) 's']);
   else
      disp(['Could not open ' fullfile(pth_out,file_name)]);
   end
end

return