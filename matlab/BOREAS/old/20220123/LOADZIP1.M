function x = loadZip1(Date1,Time1,Half1,trace)
%==================================================
% Aug 17, 1994
%
%       LoadZip
%
%   This script loads a data file which has been
%   zipped. The FileName is the name of the *.ZIP
%   file and the name of the zipped data file (*.MAT file)
%   
%   FileName is the name without an extension
%
%


hourst = [num2str(Time1) num2str(Half1)];
if Time1 < 10 
    hourst = [ '0' hourst];
end
FileName = [ Date1 hourst];
dos(['pkunzip -o ' FileName]);
eval(['load ' FileName]);
eval(['x = ' trace ';']);
dos(['del ' FileName '.mat']);


