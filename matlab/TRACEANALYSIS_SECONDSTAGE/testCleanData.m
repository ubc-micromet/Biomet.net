function testCleanData(Year, SiteID)
% This function tests the autoCleanTraces function. Does so by doing the following
%    1) Get's data from data base using read_data
%	  2) Cleans the data using the autoCleanTraces
%    3) Runs the ta_firstStage_test (note that user input is required) for all traces
%        NOTE: ta_firstStage_test was created soley for the purpose of testing the
%              autoCleanTraces function.  Allows for the return of all the cleaned 
%					data to the fields 'data'
%    4) Compares the data fields of the structures returned (compares every trace
%       and every data entry within that trace) If the test was successful the program
%       will display 0 number or errors within the data at the command prompt
% 
% Input:		'Year' - Year of the data to test from the database
%				'SiteID' - site ID of the data to test from the database
% Ouput:		'trace_str_out' - array of traces that have been cleaned (ie the data
%									field has been changed to reflect cleaning procedures)


cd d:\Chad\Development\biomet.net.mod2\matlab\read_data\
raw_data = read_data(Year, SiteID, ['\\ANNEX001\DATABASE\Calculation_Procedures\TraceAnalysis_ini\' SiteID '\' SiteID '_FirstStage.ini']);

cd d:\Chad\Development\biomet.net.mod2\matlab\clean_data\
new_clean_data = autoCleanTraces( raw_data );

cd c:\biomet.net\matlab\TRACEANALYSIS_FIRSTSTAGE\
old_clean_data = ta_firstStage_test(Year, SiteID, ['\\ANNEX001\DATABASE\Calculation_Procedures\TraceAnalysis_ini\' SiteID '\' SiteID '_FirstStage.ini']);

cd d:\Chad\Development\biomet.net.mod2\matlab\clean_data\

length_old = length(old_clean_data);
length_new = length(new_clean_data);

if ~(length_old == length_new)
   disp( ['Size mismatch in new and old programs: new ', length_new, '  old ', length_old] );
   return;
end

error_count = 0;

%Check that data is the same for both the old and the new program
for countTraces = 1:length(length_old)
   
   %Check that the data is correct
   for countData = 1:length(old_clean_data(countTraces).data)
	   if ~( old_clean_data(countTraces).data(countData) == new_clean_data(countTraces).data(countData) )
         if isnan(old_clean_data(countTraces).data(countData)) & isnan(new_clean_data(countTraces).data(countData))      
         else
            disp( ['Data Error: ' num2str(new_clean_data(countTraces).data(countData)) ' not equal to ' num2str(old_clean_data(countTraces).data(countData)) ] );
            error_count = error_count + 1;
         end   
      end
   end
   
end

disp( ['Number of errors in data: ' num2str(error_count)]);
