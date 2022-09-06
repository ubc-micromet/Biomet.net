%==================================================
% Aug 17, 1994
%
%       LoadZipA
%
%   This script loads a data file which has been
%   zipped. The FileName is the name of the *.ZIP
%   file and the name of the zipped data file (*.MAT file)
%   
%   FileName is the name without an extension
%
%

dos(['pkunzip -o ' FileName]);
eval(['load ' FileName]);
dos(['del ' FileName '.mat']);


