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
      % kai* May 30, 2001
      % Before this read lc_path = '';
      lc_path = ini_file(1:ind(end));
   end   
   fid = fopen(fileName,'rt');						%open text file for reading only.   
   if (fid < 0)
      error(['File, ' fileName ', is invalid']);
      return
   end
   % end kai*
end

if exist('fileName') & ~isempty(fileName)  
   firstLine = fgetl(fid);
   
   location = findstr(firstLine, variableName);
   
   if ~isempty(location)      
     [fieldName, remainder] = strtok( firstLine );     
     fieldIndex = 1;     
     while ~isempty( fieldName )
        if strcmp(fieldName, variableName)
           index = fieldIndex;
           return
        else
           [searchPath, remainder] = strtok( remainder );
           fieldIndex = fieldIndex + 1;
        end %end if
      end  %end while     
   end    %end if
   
   fclose(fid);
end  %end if

