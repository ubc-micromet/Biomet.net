function y = read_bor(data,data_type, flagLen,year,indOut,override_1999);
%******************************************************************************
% THIS MATLAB FUNCTION READS DATA FROM THE BOREAS DATABASE INTO MATLAB
%
%       function data = read_bor(data,data_type, flagLen,year,indOut)
%
%       data             the column file name representing the data you want
%       data_type       1 - for single precision numbers (default)
%                       2 - flag1
%                       3 - flag2 
%                       4 - date string
%                       5 - time string
%                       6 - integers
%                       7 - long integers (EDDY: num.of.lines)
%                       8 - double precision numbers ('_tv' files)
%
%       flagLen         length of the flag1 in bytes per raw 
%                       ( 10-channel data needs 2 bytes = 8 bits from the first byte 
%                         and 2 from the second byte)
%                       This parameter is required when flag data is loaded.
%       year            an optional parameter. Used to append multiple years to
%                       a single output. See read_bor_primar for usage examples
%       indOut          an optional parameter. Used to extract a data period without
%                       reading the entire file. See read_bor_primar for usage examples
%		  override_1999	When set to 0 the program assumes that 1996-1999 are all in one folder
%								(also default when flag not present). When set to 1 it is assumed that
%								the data of each of the years 1996-1999 is in a different folder.
%
%   Written by Peter Blanken, July 8, 1995
%
%   Last Rev.:   kai*, Nov 24, 2000
%******************************************************************************

%
% Revisions:
%
%   Sep 14, 2001
%       - fixed bug that prevented the function from using override_1999 = 1 option
%         Changed:
%           if ~exist('override_1999') | ~isempty(override_1999) 
%         to
%           if ~exist('override_1999') | isempty(override_1999) 
%   Nov 24, 2000
%        - added the override_1999 flag
%   Feb 8, 2000
%        - removed a bug in the if statement for data_type = 2 
%           (there were 2 ifs: "if if data_type...")
%   Jan 10, 2000
%       - added two optional input parameters: year and indOut.
%   May 11, 1998
%       -   added data_type=8, double precision numbers. This enables the program
%           to load timeVector files ("_tv")
%   Apr 7, 1998
%       -   changed type "char" to type "uchar" for data_type(s) 2 and 3
%

if exist('data_type')~= 1 | isempty(data_type) 
        data_type = 1;
end
if exist('year')~= 1 | isempty(year)  
    year = datevec(now);
    year = year(1);
end
y = [];
ind=findstr(lower(data),'yyyy');
if isempty(ind) & length(year) > 1
    error 'Multiple years require a wildcard: yyyy!'
end
if exist('indOut')== 1 & ~isempty(indOut) 
    indSkip = indOut(1)-1;
else
    indSkip = 0;
end

if ~exist('override_1999') | isempty(override_1999) 
    override_1999 = 0;
end

%firstYear = year(1);
%lastYear = year(end);

if override_1999 == 0
	% if user has requested years 1996->1999
	% convert them all to 1999
   ind1 = find(year>=1996 & year <=1999);
   year(ind1) = 1999;
   % keep only one of 1999s
   year = unique(year);
end

for i = 1:length(year)    
        fileName = data;
        if ~isempty(ind) & length(ind) == 1            
            fileName(ind:ind+3) = num2str(year(i));
        end
        eval(['fid = fopen(''' fileName  ''');']);

        if fid == -1 
            eval(['error ' '''File: (' fileName ') does not exist!'''])
        else
            if data_type == 1
                if i == 1 
                    fseek(fid,indSkip*4,'bof');
                end
                x = fread(fid,'float32');
            elseif data_type == 2
                if exist('flagLen')~= 1 | isempty(flagLen) 
                    error 'Required parameter is missing!'
                else
                    if i == 1 
                        fseek(fid,indSkip*flagLen,'bof');
                    end
                    x = fread(fid,[ flagLen Inf ],'uchar' )';
                end
            elseif data_type == 3
                if i == 1 
                    fseek(fid,indSkip*10,'bof');
                end
                x = fread(fid,[ 10 Inf ],'uchar')';        
            elseif data_type == 4
                if i == 1 
                    fseek(fid,indSkip*10,'bof');
                end
                x = setstr( fread(fid,[ 10 Inf ],'char')' );
            elseif data_type == 5
                if i == 1 
                    fseek(fid,indSkip*8,'bof');
                end
                x = setstr( fread(fid,[ 8 Inf ],'char')' );
            elseif data_type == 6
                if i == 1 
                    fseek(fid,indSkip*2,'bof');
                end
                x = fread(fid,'int16');
            elseif data_type == 7
                if i == 1 
                    fseek(fid,indSkip*4,'bof');
                end
                x = fread(fid,'int32');
            elseif data_type == 8
                if i == 1 
                    fseek(fid,indSkip*8,'bof');
                end
                x = fread(fid,'float64');
            else
                x = [];
            end
            fclose(fid);
        end 
        y = [y ;x ];
end
if exist('indOut')== 1 & ~isempty(indOut) 
    y = y(indOut-indOut(1)+1);
end
