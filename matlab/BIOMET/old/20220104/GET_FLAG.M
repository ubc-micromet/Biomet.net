function flag = get_flag( data, flagNum )
%---------------------------------------------------------------
%
%       function flag = get_flag( data, flagNum )
%
%   This function reads flag "flagNum" (a vector) from the variable
%   "data".
%
%   Inputs:
%       data        matrix with all the flags
%       flagNum     channel number for the target flag
%
%   Outputs:
%       flag        colon of 1's and 0's ( 0 - data missing, 1 - data exists )
%   
%   Written by Zoran Nesic, July 13, 1995
%----------------------------------------------------------------

if nargin < 2
    error 'Not enough parameters!'
else
    [m,n] = size(data);
    if flagNum > n * 8
        error 'flagNum out of range'
    else
        byte = fix( ( flagNum-1 ) / 8 ) + 1;        % find the byte containing the flag
        bit  = 8 - rem( flagNum, 8 );               % find the bit
        if bit == 8 
            bit = 0;
        end              
        flag = ( rem( data(:,byte) * 2 ^ (7 - bit) , 256 ) >= 128 );
    end
end

        
