function [RawData,header,N] = read_met(FileName)
%
%	function [RawData,header,N] = read_met(FileName)
%
%
%	This file loads raw data from the Met.Exe program
%	(these are the files with the names like YMMDDHHh.N1)
%
%   Inputs:
%
%	FileName	- string with the file name and path
%
%   Outputs:
%
%	RawData		- numbers from the Solent
%	header		- header saved at the begining of *.N file
%			  (an array of numbers, each is the value from
%			   one setup line)
%	N		- number of lines read
%
%
% (c) Zoran Nesic 		File created:		Mar 28, 1996
%				Last modification:	Mar 29, 1996
%
s = sprintf('fid = fopen (%s%s%s,%sr%s);',39,FileName,39,39,39);
eval(s);
if fid > 0 
    %
    % open file for an ascii input (read the header)
    %
    hs = 84;		% number of header lines (Met header V2.01)
    header = zeros(1,hs);
    for i =1:hs
    	s = fgetl(fid);
    %	disp(s);
    	if i > 2
      	    x = find(s == 39);
           	if i == 4 | i==10
    	        ind = find(s(1:x-1)~=32);
    	        header(i-2) = s(ind);
    	    else
                header(i-2) = str2num(s(1:x-1));
    	    end
        end
    end
    fclose(fid);
    %
    % if file does exist read it as header(1)-colon matrix of  16-bit integers
    %
    s = sprintf('fid = fopen (%s%s%s,%sr%s);',39,FileName,39,39,39);
    eval(s);
    RawData = fread(fid,[header(1),inf],'int16');
    fclose(fid);
    N = length(RawData);
    RawData = RawData(:,301:N);
    ind = find(RawData(1,:) > 30000);
    RawData(:,ind) = []; 
else
    error 'File does not exist!'
end