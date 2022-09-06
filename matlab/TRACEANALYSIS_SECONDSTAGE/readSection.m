function sectionRead = readBermsSection( fileName, index)

if exist('fileName') & ~isempty(fileName)  
   
   %Determine how many lines there are in the file
   lines = countNumberLines(fileName);
   
   range = [3 index lines index];
   
   sectionRead = dlmread(fileName,' ',range); 
   
end