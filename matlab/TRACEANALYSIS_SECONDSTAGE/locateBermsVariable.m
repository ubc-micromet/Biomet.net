function index = locateBermsVariable( fileName, variableName )

index = 0;

%-------------------------------------------------------------------------------------
%Open initialization file if it is present:
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
location = [];   %holds the location of the variableName within the string firstLine
fieldName = '';  %holds the name of the field that is to be checked against the variableName
fieldIndex = 0;  %holds the index of the field where the variableName is located

if exist('fileName') & ~isempty(fileName)  
   firstLine = fgetl(fid);
   
   % Find the location where the varibleName is located within the fieldNames
   location = findstr(firstLine, variableName);
   
   if ~isempty(location)      
      
      % Get the first field name from the header file
      [fieldName, remainder] = strtok( firstLine );     
      
      %Set the field index to the first field
      fieldIndex = 1;     
      
      %Itterate over all fields
      while ~isempty( fieldName )
         
         %If the field and varialbeNames are the same
         if strcmp(fieldName, variableName)            
            %Set the index to the field Index and return
            index = fieldIndex;            
            return
         else
            %Get the next fieldName
            [fieldName, remainder] = strtok( remainder );
            
            %Increment the fieldIndex to the next field
            fieldIndex = fieldIndex + 1;
            
         end %end if
         
      end  %end while     
      
   end    %end if
   
   fclose(fid);
end  %end if

