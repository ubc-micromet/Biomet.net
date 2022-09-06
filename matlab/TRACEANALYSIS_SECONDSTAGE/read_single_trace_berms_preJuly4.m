function trace_out = read_single_trace_berms( trace_in, bermsData );

%Time Tollerance used to determine which times to make equal (ie between trace_in.timeVector and berms timeVector)
timeTollerance = 5;  %use 5 min

%set the output trace to the input trace (used for pipelining
trace_out = trace_in;

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
   
   countDiscard = 0;   %counts the amount of data that is in the berms database that cannot be used
   
   orderCount = 0;  %used to determine the efficiency of the algorithm
   
   %sort the data for that particular trace   
   %itterate through all the entries in the Berms file
   for countTime_Berms = 1:numPtsBerms
      
      if ishandle(h)
  			waitbar(countTime_Berms/numPtsBerms);         
      end   
        
      countTime_trace_in = lastTime;  %used to keep track of where the last entry was placed (so as not to search the whole trace_in.DOY field
      dataInserted = 0;
            
      %match each entry from the Berms file to the DOY field of the input trace
      while ~dataInserted         
         %disp([ datestr(trace_in.timeVector(countTime_trace_in),0)] );
         %disp([ datestr(bermsData.timeVector(countTime_Berms),0)] );
         
         orderCount = orderCount + 1;                       
         
         %if the days match then set the data and move the lastDOY counter (matching time +- 5 min)
         if abs(trace_in.timeVector(countTime_trace_in) - bermsData.timeVector(countTime_Berms)) < timeTollerance*6.9444e-004
        		trace_in.data(countTime_trace_in) = bermsData.data(numPtsBerms*(variableIndex-1)+countTime_Berms);
            lastTime = countTime_trace_in + 1;                 
            
            dataInserted = 1;
         else 
            
            %if we have passed the place where the data should go then discard the berms data, otherwise fill in the missing data with NaN
            if trace_in.timeVector(countTime_trace_in) > bermsData.timeVector(countTime_Berms)
               dataInserted = 1;
               
               %set the program to check the trace_in time again
               countTime_trace_in = countTime_trace_in - 1;
               
               countDiscard = countDiscard + 1;
            else
               trace_in.data(countTime_trace_in) = NaN;
            end
            
         end
                           
         %check the next time in the trace_in struct
         countTime_trace_in = countTime_trace_in + 1;               

         %if we have reached the end of the structure then end   	                                
         if countTime_trace_in > length(trace_in.timeVector)
            dataInserted = 1;
            lastTime = length(trace_in.timeVector);
         end %end if
      end %end while   	         
            
   end %end for loop (Berms)
   
   if countDiscard > 0
      disp( ['Warning: ' num2str(countDiscard) ' data points from berms database were not used'] );
   end
   
   disp( ['Order count: performed ' num2str(orderCount) ' comparisons vs. required min of ' num2str( length(trace_in.timeVector) ) ]);
   
   %Close the status bar window
	if ishandle(h)
	   close(h);
	end
   
end     %end if
      
   