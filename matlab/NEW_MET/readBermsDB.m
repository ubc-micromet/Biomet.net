function berms_out = readBermsDB( Year, pth, file_extension )

berms.data = [];           %stores all the data from the berms dB (for that particular year and site)
berms.timeVector = [];     %stores the time vector information
berms.variables = [];      %stores the name of each variable
berms.units = [];          %stores the unit of each variable

columnTime = 4;            %Column in the berms database where the Time is stored
columnDay  = 3; 			   %Column in the berms database where the Day is stored

%Determine if berms data exists for the set of traces   
fileName = getAllFileNames( pth, file_extension );

if isempty( fileName )
   berms_out = [];
   return;
end

[day,YearInFile] = getBermsDayYear(fileName);

ind_files = find(YearInFile == Year);
fileName = fileName(ind_files);
day = day(ind_files);
[dum,ind_day_sorted] = sort(day);
fileName = fileName(ind_day_sorted);

if isempty( fileName )
   berms_out = [];
   return;
end

skipFile = 0;      %flag to signal that this particular berms file is corrupted and needs to be skipped
variableRow = [];  %first row of the Berms file

%Load up the data from berms database
for countFiles = 1:length(fileName)
   
   skipFile = 0;   
   
	%construct the full file name
	fullFileName = fullfile( fileName(countFiles).path, [fileName(countFiles).name fileName(countFiles).ext]);   	   
     
   %get the first row from the Berms DB (first row contains all of the variable names        
   [variableRowNew,units] = getBermsVariableRow( fullFileName );
   variableRowChar = char(variableRowNew);
   indUscore = find(variableRowChar=='-');
   variableRowChar(indUscore) = '_';
	variableRowNew = cellstr(variableRowChar);
   
   %check to see if the variableRow is empty (ie first iteration)
   if isempty( variableRow ) 
      %if it is then set it
      variableRow = variableRowNew;      
   else
      %if variableRow is already filled then compare the two of them together, and if they are not the same skip that particular berms file
      if ~(length(variableRow) == length(variableRowNew)) 
         disp(['   Warning: Berms file ' fullFileName ' is corrupted, skipping file']);
         skipFile = 1;
      end
   end
   
   %if the file is not corrupted then read it
   if ~skipFile
      
	   %Display update message
   	disp(['   Loading berms file ' fileName(countFiles).name fileName(countFiles).ext ]);
           
      %Read from the dB (all data)
      sectionRead = readBermsAllColumns( fullFileName , length(variableRow) );
      
      %Determine the number of rows
      rows = size(sectionRead,1);      
            
      %Read the DOY from the dB (flip the data by 270 degrees to get a column vector)
      Day = rot90(sectionRead([rows*(columnDay-1)+1:rows*columnDay]),3);     
      Time = rot90(sectionRead([rows*(columnTime-1)+1:rows*columnTime]),3);
      
      timeVector = datenum(Year,1,Day,fix(Time/100),Time-fix(Time/100)*100,0);
                  
      berms.data = cat(1,berms.data,sectionRead);
      berms.timeVector = cat(1,berms.timeVector,timeVector);
      
   end  %end if
            
end  %end for loop (for Berms files)

berms.variables = variableRowNew;
berms.units     = units;

% Trough out tabel id and time traces and 'n/a' columns
ind_out = find(~strcmp(variableRowNew,'n/a'));
ind_out = ind_out(6:end);

%Check whether any data is missing
clean_tv = fr_round_hhour([datenum(Year,1,1,0,30,0):datenum(0,0,0,0,30,0):datenum(Year+1,1,1)]');
% removed by Zoran Sep 12, 2002.  Doesn't work for all the cases.
%[dum,ind_tv,ind_clean] = intersect(fr_round_hhour(berms.timeVector),clean_tv,'tv');

% Temporary fix for time values of -999
ind_fix = find(berms.timeVector == datenum(Year,1,-999,fix(-999/100),-999-fix(-999/100)*100,0));
if ~isempty(ind_fix)
   no_hh = 17520/length(berms.timeVector);
   berms.timeVector = fr_round_hhour([datenum(Year,1,1,0,no_hh*30,0):datenum(0,0,0,0,no_hh*30,0):datenum(Year+1,1,1)]');
   disp('Found missing values in date-time info - use generic time trace')
end

[dum,ind_tv,ind_clean] = intersect(fr_round_hhour(berms.timeVector),clean_tv);
doy = convert_tv(clean_tv,'doy');

% Reorder to get output in normal trace structure format
% and do some house keeping (check length, get rid of '#' & '.' in varnames and get rid of 999)
% and cut length of name to min required
for i = 1:length(ind_out)
   k = ind_out(i);
   berms_out(i).Year        		= Year;
   
   var_name = char(berms.variables(k));
   var_name = strrep(var_name,'#','No');
   var_name = strrep(var_name,'.','_');
   if var_name(1) >= '0' & var_name(1) <= '9'
      var_name = ['D' var_name];
   end
   if length(var_name) > 31
      var_name = var_name(1:31);
   end
   
   berms_out(i).stage               = 'zero';
   berms_out(i).variableName 		= var_name;
   berms_out(i).ini.units    		= char(berms.units(k));
   berms_out(i).ini.extension       = file_extension;
   berms_out(i).ini.path		    = pth;
   berms_out(i).ini.measurementType = 'berms_org';
   
   berms_out(i).timeVector   		= clean_tv;
   berms_out(i).DOY 		   		= doy;
   
   berms_out(i).data 				= NaN .* ones(size(clean_tv));
   berms_out(i).data(ind_clean)	= berms.data(ind_tv,k);
   ind_nan = find(berms_out(i).data<=-999);
   berms_out(i).data(ind_nan)		= NaN;
   
end

return