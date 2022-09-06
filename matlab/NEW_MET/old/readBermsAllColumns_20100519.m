function sectionRead = readBermsAllColumns( fileName, columnNum )

%last modification:

%  May 26,2006: Modified dlmread statement for compatibility with MATLAB 6
%               NickG

if exist('fileName') & ~isempty(fileName)  
   
  %set lines to the max there can be to 2000 (or dlmread will stop at the end of the file)
   %lines = 2000;
   
   %range = [2 0 lines columnNum-1 ];
   
% --------commented out dlmread statement as a result of a migration
% --------problem from MATLAB 5/6.....Nick 5/26/06
   
%    sectionRead = dlmread(fileName,',',2,0); 
%    rowNum = floor(length(sectionRead)/columnNum);
%    if rowNum ~= length(sectionRead)/columnNum
%       disp('File not read completely.');
%    end
%    
%    sectionRead = reshape(sectionRead(1:columnNum*rowNum),columnNum,rowNum)';

%--------------------------------------------------------
%--------------------------------------------------------

% new dlmread statement for MATLAB 6

  sectionRead = dlmread(fileName,' ',2,0);

  [m,n] = size(sectionRead);
  rowNum = floor(m*n/columnNum);
    if rowNum ~= m
       disp('File not read completely.');
    end
end