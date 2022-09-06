function x=dlmreadf(fileName)
%
% file: dlmreadf.m
%
% Fast way of reading comma delimited files.
% 
% (c) Zoran Nesic               File created:       Dec 19, 1998
%                               Last modification:  Dec 19, 1998

% 
% Revisions:
%

fid = fopen(fileName,'rt');             % attempt to open the file
if fid < 3                              % if it does not exist
   error 'File does not exist!'         % exit with error
end

row = 0;                                % row counter
lin = fgets(fid);                       % read first line
while ~isempty (lin) & ~isequal(lin,-1) % do while lin is not empty and not EOF
    row = row + 1;                      % increment the row number
    eval(['x1= [' lin '];']);           % store all the numbers in one row
    x(row,1:length(x1)) = x1;           % move that to the output matrix
    lin = fgets(fid);                   % get the next line
end
fclose(fid);                            % close the file
%row
   