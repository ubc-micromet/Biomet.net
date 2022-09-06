function testReadData(Year, SiteID)
% This function tests the read_data function. Does so by doing the following
%    1) Get's data from data base using read_data
%    2) Runs the ta_secondStage (note that user input is required) for all traces
%    3) Compares the 'data' fields of the structures returned (compares every trace
%       and every data entry within that trace) 
%    4) Compares the 'timeVector' fields of the structures returned (compares every
%	     trace and every data entry within that trace)
%    5) Compares the 'DOY' fields of the structures returned (compares every
%	     trace and every data entry within that trace)
%    6) If there exists any discrepancies in the data compared in steps 3,4 or 5
%       the number of dispcrepancies will be displayed in the command prompt; namely
%       under the heading "Number of errors in data"
% 
% Input:		'Year' - Year of the data to test from the database
%				'SiteID' - site ID of the data to test from the database

cd d:\Chad\Development\biomet.net.mod2\matlab\read_data\
new_second_stage = read_data(Year, SiteID, ['\\ANNEX001\DATABASE\Calculation_Procedures\TraceAnalysis_ini\' SiteID '\' SiteID '_SecondStage.ini']);

cd c:\biomet.net\matlab\TRACEANALYSIS_SECONDSTAGE\
old_second_stage = ta_secondStage(Year, SiteID, ['\\ANNEX001\DATABASE\Calculation_Procedures\TraceAnalysis_ini\' SiteID '\' SiteID '_SecondStage.ini']);

cd d:\Chad\Development\biomet.net.mod2\matlab\read_data\

length_old = length(old_second_stage);
length_new = length(new_second_stage);

if ~(length_old == length_new)
   disp( ['Size mismatch in new and old programs: new ', length_new, '  old ', length_old] );
end

error_count = 0;

%Check that data is the same for both the old and the new program
for countTraces = 1:length(length_old)
   
   %Check that the data is correct
   for countData = 1:length(old_second_stage(countTraces).data)
	   if ~( old_second_stage(countTraces).data(countData) == new_second_stage(countTraces).data(countData) )
         if isnan(old_second_stage(countTraces).data(countData)) & isnan(new_second_stage(countTraces).data(countData))      
         else
            disp( ['Data Error: ' num2str(new_second_stage(countTraces).data(countData)) ' not equal to ' num2str(old_second_stage(countTraces).data(countData)) ] );
            error_count = error_count + 1;
         end   
      end
   end
   
   %Check that the time vector is the same
   for countTimeVector = 1:length(old_second_stage(countTraces).timeVector)
	   if ~( old_second_stage(countTraces).timeVector(countData) == new_second_stage(countTraces).timeVector(countData) )
         if isnan(old_second_stage(countTraces).timeVector(countData)) & isnan(new_second_stage(countTraces).timeVector(countData))      
         else
            disp( ['Time Vector Error: ' num2str(new_second_stage(countTraces).timeVector(countData)) ' not equal to ' num2str(old_second_stage(countTraces).timeVector(countData)) ] );
            error_count = error_count + 1;
         end   
      end
   end
   
   %Check that the Day of Year (DOY) is the same
   for countDOY = 1:length(old_second_stage(countTraces).DOY)
	   if ~( old_second_stage(countTraces).DOY(countData) == new_second_stage(countTraces).DOY(countData) )
         if isnan(old_second_stage(countTraces).DOY(countData)) & isnan(new_second_stage(countTraces).DOY(countData))      
         else
            disp( ['DOY Error: ' num2str(new_second_stage(countTraces).DOY(countData)) ' not equal to ' num2str(old_second_stage(countTraces).DOY(countData)) ] );
            error_count = error_count + 1;
         end   
      end
   end
   
end

disp( ['Number of errors in data: ' num2str(error_count)]);

