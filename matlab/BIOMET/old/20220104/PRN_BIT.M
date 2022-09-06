function bits = prn_bit( dataIn )
%---------------------------------------------------------------
%
%       function bits = prn_bit( dataIn )
%
%   This function prints dataIn (a vector) as a vector of binary numbers
%   POSITIVE numbers only!
%
%   Inputs:
%       dataIn      input array (int16)
%
%   Outputs:
%       bits        binary output of "dataIn"
%   
%   Written by Zoran Nesic, July 24, 1995
%
%   Last Rev.: Zoran Nesic, July 25,1995
%----------------------------------------------------------------
bits = [];
[ len1, width ] = size(dataIn);
if nargin < 1
    error 'Not enough parameters!'
elseif width > 1
    error 'Input must be a colon vector!'
else
    data = abs(dataIn);
    maxIn = max(dataIn);
    Bytes = fix(log(maxIn)/log(256))+1;
    for byte = 1:Bytes
        dataHigh = fix(data/256);    
        data = rem(data,256);
        oneByte = [];
        for bit = 0:7
            flag = ( rem( data * 2 ^ bit , 256 ) >= 128 );
            oneByte = [ oneByte num2str(flag)'];
        end
        bits = [oneByte(:,1:4) ' '*ones(len1,1) oneByte(:,5:8) ' '*ones(len1,1) bits];
        data = dataHigh;
    end
end

        
