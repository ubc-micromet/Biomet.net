function file = getAllFileNames(path, extention)

dirStruct = dir(path);

ignoreExt = 0;  %flag to ignore the file's extention

if ~exist('extention') | isempty(extention)
   ignoreExt = 1;
   extention = '';
else ignoreExt = 0;
end   
   
file = [];

file.path = '';  %holds the path of the file
file.name = '';  %holds the name of the file
file.ext = '';   %holds the extention of the file

countDirFiles = 1;

%Variables used to catch output from fileparts
name = '';      
ext = '';
versn = '';
dummyPath = '';

%if the path exists
if ~isempty(dirStruct)   
   
   %itterate through all files found in directory
   for countFiles = 1:length(dirStruct)
      
      %only check files not directories
      if ~dirStruct(countFiles).isdir 
         
         % get the file's extention and name
         [dummyPath,name,ext,versn] = fileparts( dirStruct(countFiles).name );
         
         %make check to see if the extention is correct
         if (strcmp(lower(ext), lower(extention)) | ignoreExt)
	         file(countDirFiles).name = name;                     %save the files name
   	      file(countDirFiles).path = path;							  %save the files path (from command line)
      	   file(countDirFiles).ext = ext; 							  %save the files extention
            
            %itterate to the next file
            countDirFiles = countDirFiles + 1;
         end %end if
         
      end    %end if
      
   end       %end for
   
end          %end if

