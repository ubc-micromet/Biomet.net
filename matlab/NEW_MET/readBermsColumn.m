function sectionRead = readBermsColumn( fileName, index)

if exist('fileName') & ~isempty(fileName)  
   
   %Determine how many lines there are in the file (not used as it is too slow)
   %lines = countNumberLines(fileName);
   
   %set lines to the max there can be to 2000 (or dlmread will stop at the end of the file)
   lines = 2000;
   
   range = [2 index lines index];
   
   sectionRead = dlmread(fileName,' ',range); 
      
end