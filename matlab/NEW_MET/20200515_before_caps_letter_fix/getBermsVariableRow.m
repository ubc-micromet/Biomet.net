function [variables,units] = getBermsVariableRow( fileName )

variables = [];
units     = [];

%-------------------------------------------------------------------------------------
%Open berms file if it is present:
if exist('fileName') & ~isempty(fileName)
   ind = find(fileName==filesep);
   if isempty(ind)      
      temp = which(fileName);
      if isempty(temp)      
         error([fileName ' does not exist in the matlab search path'])
      end
      indTemp = find(temp==filesep);
      lc_path = temp(1:indTemp(end));
   else
      lc_path = '';
   end   
   fid = fopen(fileName,'rt');						%open text file for reading only.   
   if (fid < 0)
      error(['File, ' fileName ', is invalid']);
      return
   end
   % end kai*
end

firstLine = '';  %holds the first line of the berms data file (ie one with all the field names)
fieldName = '';  %holds the name of the field that is to be checked against the variableName
countVariables = 1;  %holds the number of variables found within the berms file

if exist('fileName') & ~isempty(fileName)  
   firstLine = fgetl(fid);
   
   % Get the first field name from the header file
   [fieldName, remainder] = strtok( firstLine );     
      
   %Itterate over all fields
   while ~isempty( fieldName )
      
      variables{countVariables} = fieldName;
      
      %Get the next fieldName
      [fieldName, remainder] = strtok( remainder );
            
      %Increment to the next field
      countVariables = countVariables+1;
   end  %end while     
   
   remainder = fgetl(fid);
   
   % Get the first field name from the header file
   for i = 1:countVariables-1
      
      [fieldName, remainder] = strtok( remainder );
      units{i} = fieldName(2:end-1);% Remove brackets 
      if isempty(units{i})
         units{i} = ' ';% Remove brackets
      end
            
   end  %end for     
   
end  %end if   
   
fclose(fid);


