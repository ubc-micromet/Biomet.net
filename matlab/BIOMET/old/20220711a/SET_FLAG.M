function flagMatrix = set_flag( flagMatrix, flagArray, flagNum )
%---------------------------------------------------------------
%
%       function flagMatrix = set_flag( flagMatrix, flagArray, flagNum )
%
%   This function sets (writes) the flag "flagNum" (a vector) into the 
%   matrix of flags "flagMatrix"
%
%   Inputs:
%       flagMatrix      matrix with all the flags
%       flagArray       array of flags to be written into flagMatrix
%       flagNum         channel number for the target flag
%
%   Outputs:
%       flagMatrix      updated input matrix with all the flags
%   
%   Written by Zoran Nesic, July 24, 1995
%----------------------------------------------------------------

if nargin < 3
    error 'Not enough parameters!'
else
    [m,n] = size(flagMatrix);
    flagMatrix = abs(flagMatrix);                   % make sure that flagMatrix is not a string
    if flagNum > n * 8
        error 'flagNum out of range'
    else
        byte = fix( ( flagNum-1 ) / 8 ) + 1;        % find the byte containing the flag
        bit  = 8 - rem( flagNum, 8 );               % find the bit
        if bit == 8 
            bit = 0;
        end  
        
%        disp(sprintf('Byte = %d',byte))
%        disp(sprintf('Bit  = %d',bit))
        
        FlagNew = flagArray * 2^bit;
        
%        disp('FlagNew:')
%        disp(sprintf(' %d\n',FlagNew))
        
        LowerBits = rem( flagMatrix(:,byte) * 2 ^ (8-bit) , 256 )/ 2 ^ (8-bit);
        
%        disp('Lower Bits:')
%        disp(sprintf(' %d\n',LowerBits))
        
        UpperBits = fix( flagMatrix(:,byte) * 2 ^ (7 - bit) / 256 )*256 / 2^(7-bit);
        
%        disp('Upper Bits:')
%        disp(sprintf(' %d\n',UpperBits))
        
        flagMatrix( :, byte ) = LowerBits + FlagNew + UpperBits;
    end
end

        
