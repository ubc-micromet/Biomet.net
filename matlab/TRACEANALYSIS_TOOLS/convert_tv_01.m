function [converted_tv,year] = convert_tv(tv,output_format,gmt_shift,...
                                          point_of_interval,length_of_interval)
% Generates time vector or converts it to various formats.
% See convert_tv_primer for details on time vector conventions and formats,
% the input parameters and also on examples for using convert_tv.
%
% function [converted_tv,year] = convert_tv(tv,output_format,gmt_shift,...
%                                          point_of_interval,length_of_interval)
% Input paramters:
%    tv                 - time vector read from database or [beginning,end]
%    output_format      - 'doy','jul','mtv','nod'
%                         Default: 'doy'
%    gmt_shift          - when given, output will be shifted to local time 
%                         Default: 0
%    point_of_interval  - 'beginning','end', or a number between 0 and 1
%                         Default: 'end'
%    length_of_interval - 'halfhour','hour','day', or a length in days
%                         only effective if a vector is generated
%                         Default: 'halfhour'
% Output: 
%    converted_tv        - time vector in requested format
%    year                - contains the year for each element in converted_tv,
%                          useful if requested format is 'doy', 'jul' or 'nod'
%
% (C) Kai Morgenstern				File created:  09.09.00
%											Last modified: 09.09.00
%

% Revision: none

%
% Remark on order of conversion:
% The conversion are done in the following order:
% generating of vector (if requested)
% point of interval
% GMT shift
% format conversion

%
% Assessing default values
%
if ~exist('tv') | isempty(tv)
   help convert_tv;
   return
end   
if ~exist('output_format') | isempty(output_format)
   output_format     = 'doy';
end
if ~exist('gmt_shift') | isempty(gmt_shift)
   gmt_shift         = 0;
end
if ~exist('point_of_interval') | isempty(point_of_interval)
   point_of_interval = 'end';   
end
if ~exist('length_of_interval') | isempty(length_of_interval)
   length_of_interval= 'halfhour';   
end

%
% Test of length_of_interval
%
if ischar(length_of_interval)
   switch length_of_interval
   case 'halfhour'
      dt = 1/48;
   case 'hour'
      dt = 1/24;
   case 'day'
      dt = 1;
   otherwise
      disp('Unknown length_of_interval given - returning.');
      converted_tv = []; year = [];
      return;
   end
else
   dt = length_of_interval;
end

if     length(tv) == 2 % tv contains [beginning,end] of requested time vector
   tv = [tv(1):dt:tv(2)]' ;
elseif length(tv) > 2 & exist(length_of_interval) 
   disp('length_of_interval only used in generating - returning');
   converted_tv = []; year = [];
   return;
elseif length(tv) < 2  
   disp('please give either [beginning,end] or tv in first parameter - returning.');
   converted_tv = []; year = [];
   return;
end   

%
% Test and conversion point_of_interval
%
if ischar(point_of_interval)
   switch point_of_interval
   case 'beginning'
      tv(1) = tv(1)-(tv(2)-tv(1)); % for first assume lenght between first and second
      tv(2:end) = tv(1:end-1); % for the rest use end of last as beginning of next
   case 'end'
      % do nothing
   otherwise
      disp('Unknown point_of_interval given - returning.');
      converted_tv = []; year = [];
      return;
   end
else
   if point_of_interval < 0 | point_of_interval > 1
      disp('point_of_interval given - returning.');
      converted_tv = []; year = [];
      return;
   end
   d_tv = tv(2:end)-tv(1:end-1); % calculate length of intervals
   % substract (1-fraction) of interval from END(!) of measurement
   tv(1)     = tv(1)     - d_tv(1) * (1-point_of_interval);
   tv(2:end) = tv(2:end) - d_tv * (1-point_of_interval);
   pt = -point_of_interval*dt;
end

%
% Test and conversion gmt_shift
%
if abs(gmt_shift > 12)
   disp('gmt_shift out of range - returning.');
   converted_tv = []; year = [];
   return;
else
   tv = tv - gmt_shift/24;
end

%
% Convert to requested format
%
year_beginning = datevec(tv(1));
year_end       = datevec(tv(end));
year           = zeros(size(tv));
TimeOffset     = zeros(size(tv));
for i=year_beginning:year_end
   new_year_current = datenum(i  ,1,1);
   new_year_next   = datenum(i+1,1,1);
   ind = find(tv >= new_year_current & tv < new_year_next);
   year(ind) = i;
   TimeOffset(ind) = datenum(i,1,1,0,0,0);
end   

switch output_format
case 'doy'
   converted_tv = tv - TimeOffset + 1; 
case 'jul'
   converted_tv = tv - TimeOffset; 
case 'nod'
   converted_tv = tv - tv(1); 
case 'mtv'
   converted_tv = tv; 
otherwise
   disp('Unknown output_format given - returning.');
   converted_tv = []; year = [];
   return 
end
