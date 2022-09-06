function [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1)
% fr_movefile - same as movefile except it checks if destination already exists.
%               If destination is already present it adds _x (up to 9) to
%               the file extension data.20070810 becomes data.20070810_1
%
% (c) Zoran Nesic       File created:   Aug 10, 2007
%                       Last modified:  Aug 10, 2007

k = 1;
originalDestination = destinationFile1;
while exist(destinationFile1,'file') && k < 10
    fileName = dir(destinationFile1);
    if fileName.isdir == 1
        error('Destination file: %s name is a directory!',destinationFile1)
    else
        destinationFile1 = [originalDestination '_' num2str(k)];
        k = k +1;
    end
end

if k < 10
    [Status1,Message1,MessageID1] = movefile(sourceFile,destinationFile1);
else
    error('Too many output files with the same extension (fr_movefile.m)')
end
