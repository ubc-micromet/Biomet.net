function [clean_data,ind] = cle_data(data,remove_type,number);
%*****************************************************************%
% THIS MATLAB FUNCTION REMOVES OBVIOUSLY BAD DATA                 %
%                                                                 %
%        function [clean_data,ind] =										%
%						cle_data(data,remove_type,number)  					%
%                                                                 %
%          INPUT:                                                 %
%          data = column file name containing the data you want   %
%                 cleaned-up                                      %
%                                                                 %
%          remove_type = 1 -> # exactly equal to                  %
%                      = 2 -> # greater than or equal to          %
%                      = 3 -> # less than or equal to             %
%                                                                 %
%          number = number(s) you wish replaced with NaN's        %
%                                                                 %
%          OUTPUT:                                                %
%          colunm containing data with the bad data you specified %
%          replaced with Not-a-Number (NaN)                       %
%                                                                 %
%*****************************************************************%        

%
% Revisions:
%		  Nov 26, 1997    (Zoran)
%					 exported variable ind 
%       Jun 13, 1997    (Zoran)
%               defined ind variable and added if nargin < 3
%

if nargin < 3
    error 'Too few input parameters!'
end

clean_data=data;
ind = [];
if remove_type == 1;
        for i = 1:length(number);
                x = find(data == number(i));
                ind=[ind x];
                end;
        clean_data(ind)=NaN*ones(1,length(ind));

elseif remove_type == 2;
        for i = 1:length(number);
                x = find(data >= number(i));
                ind=[ind x];
                end;
        clean_data(ind)=NaN*ones(1,length(ind));
        
elseif remove_type == 3;
        for i = 1:length(number);
                x = find(data <= number(i));
                ind=[ind x];
                end;
        clean_data(ind)=NaN*ones(1,length(ind));
else;
end;