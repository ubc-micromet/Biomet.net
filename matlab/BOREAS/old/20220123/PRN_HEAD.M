function head_str = prn_head(FileName)
%
%	function head_str = prn_head(FileName)
%
%
%	This file prints the header of a Met.Exe raw data file.
%	(these are the files with the names like YMMDDHHh.N1)
%
%   Inputs:
%
%	FileName	- string with the file name and path
%
%   Output
%
%	head_str 	- string containing header
%
% (c) Zoran Nesic 		File created:		Mar 29, 1996
%				Last modification:	Mar 29, 1996
%
s = sprintf('fid = fopen (%s%s%s,%sr%s);',39,FileName,39,39,39);
eval(s);
if fid > 0 
    hs = 84;		% number of header lines (Met header V2.01)
    head_str = [];
    for i =1:hs
	s = fgetl(fid);
	head_str = [head_str s [13 10]];
	disp(s);
    end
    fclose(fid);
else
    error 'File does not exist!'
end