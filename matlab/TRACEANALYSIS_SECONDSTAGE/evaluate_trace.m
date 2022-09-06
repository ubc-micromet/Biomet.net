function trace_out = evaluate_trace(trace_in, traceIndex)

%Get all the field names from the ini file
allINICommands = fieldnames( trace_in.ini );

%Itterate over all the commands within the ini file for specified trace
for countCommand =1:length(allINICommands)
   %Execute only the Evaluate commands
   if strncmp( char(allINICommands(countCommand)) , 'Evaluate', 8 )     
      commandLine = getfield( trace_in.ini, char(allINICommands(countCommand)) );    %get the command line
      
      lasterr('');
      
      %Process the command line
      commandLine = strrep(commandLine, '...,', '');   %remove ',...' from the command line
      commandLine = strrep(commandLine, ',,', ',');    %make sure that there are no comma repetitions
      commandLine = strrep(commandLine, ';,', '; ');   %remove ';,' from the command line 
      commandLine = strrep(commandLine, '+,', '+');
      commandLine = strrep(commandLine, '-,', '-');
		commandLine = strrep(commandLine, '/,', '/');
		commandLine = strrep(commandLine, '*,', '*');
      
      evalin('caller',[commandLine], ['trace_in.Error = 1;']);  %execute the command(s) within the callers workspace, errors output to Error in callers workspace            
      
      if trace_in.Error == 0
         %retrieve the data from the callers workspace         
         try
            trace_in.data = evalin('caller',trace_in.variableName);
         catch
            disp(['Error in ini file: variable name in evaluate statement does not match ' trace_in.variableName ]);
            trace_in.Error = 1;
         end
      else 
         trace_in.data = [];
         disp(['Unable to evaluate: ' commandLine ]);    %evalutate the command     
         disp(['Last error: ' lasterr]);
      end
          	                   
   end
end

%Set trace_out to trace_in
trace_out = trace_in;
