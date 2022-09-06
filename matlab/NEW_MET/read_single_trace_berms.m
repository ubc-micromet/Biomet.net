function trace_out = read_single_trace_berms( trace_in, bermsData );

numDataPtsInDay = 48;

%set the output trace to the input trace (used for pipelining
trace_out = trace_in;

%initialize the data if it already hasn't been done
trace_out.data = [];

%Check to see if the Berms field is filled, as well as the DOY field
if ~isempty( trace_out.ini.Berms ) & ~isempty( trace_out.timeVector ) & ~isempty( bermsData )
   
   variableIndex = locateBermsVariableIndex( bermsData.variables, trace_out.ini.Berms );
   
   if variableIndex == 0     
     disp(['  Warning: Unable to locate ' trace_out.ini.Berms ' in Berms database, ignoring command in ini file']);  
     return;
   end
   
   lastTime = 1;
   
   h = waitbar(0,['Sorting Berms data for ''' strrep(trace_in.variableName,'_',' ') ''' ...']);
   
   numPtsBerms = length(bermsData.timeVector);         
   
   %get the difference between the times in the time vector
   
   diff_time_vector = diff(bermsData.timeVector);
   
   difference = datenum(2000,10,10,0,30,0)-datenum(2000,10,10,0,0,0);
   
   missing_sections = diff_time_vector > difference;
   
   number_missing_sections = sum( missing_sections );
   
   %find the breaks in the data (holds index of break)
   indexBreaks = find( missing_sections );
   
   %Insert the first index into indexBreaks
   indexBreaks(length(indexBreaks)+1) = 0;
   indexBreaks(length(indexBreaks)+1) = numPtsBerms;
   
   %Sort the index's in assending order
   indexBreaks = sort(indexBreaks);
   
   distanceBetweenBreaks = diff( indexBreaks );
   
   validSection = distanceBetweenBreaks >= numDataPtsInDay;
   
   %grab the offset inorder to get the correct column
   offset = numPtsBerms*(variableIndex-1);
   
   numPtsMissing = 0;   %number of pts that are missing between data sets
   
   for countSections = 1:length(indexBreaks)-1
      if validSection(countSections)
         
         %for the first section check to see that if there should be data before
         if countSections == 1 
            numPtsMissing = round( (bermsData.timeVector(1)-dateNum(trace_out.Year,1,1,0,0,0))/difference) - 1;
         else
            numPtsMissing = round(diff_time_vector( indexBreaks(countSections) )/difference) - 1;         
         end
         
         trace_out.data = cat(2, trace_out.data, repmat(NaN, 1, numPtsMissing ) ); 

			trace_out.data = cat(2, trace_out.data, bermsData.data(offset+indexBreaks(countSections)+1:offset+indexBreaks(countSections+1)) );
         
         %for the last section check to see if there should be data after the last point
         if countSections == length(indexBreaks)-1
            numPtsMissing = round( (dateNum(trace_out.Year+1,1,1,0,0,0)-bermsData.timeVector(length(bermsData.timeVector)))/difference);
         	trace_out.data = cat(2, trace_out.data, repmat(NaN, 1, numPtsMissing ) ); 
         end
         
      end
   end
      	   
   trace_out.data = rot90( trace_out.data, 3);
   
   %Close the status bar window
	if ishandle(h)
   	close(h);
	end
   
end     %end if
      
   