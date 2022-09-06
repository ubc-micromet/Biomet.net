%=====================================================================
%
%       MET-HEAD.m is a part of MET.m 
%
%       This is a procedure for reading the header of a file transfered 
%       from MET.BAS.
%
%=====================================================================
HeaderLength=20;
%
% The first HeaderLength rows contain the header from the original file
%
[NumOfLines, NumOfChannels] = size(NumInt);
i = 2;
[row,col] = vec2mat(i,NumOfChannels);
tmp = NumInt(row,col);
if tmp == 1
	AnemometerType = 'S';
	ADconv = 1;
else
	AnemometerType = 'A';
	ADconv = 5000/2048;
end
%
i=42;[row,col] = vec2mat(i,NumOfChannels);
ADoffset = NumInt(row,col);
%
i = 5; [row,col] = vec2mat(i,NumOfChannels);
delay =  NumInt(row,col);
%
i = 8;[row,col] = vec2mat(i,NumOfChannels);
tmp = NumInt(row,col);
if tmp == 1
	rotation = 'C';
else
	rotation = 'N';
end
%
i=16;[row,col] = vec2mat(i,NumOfChannels);
Ugain = NumInt(row,col);
%
i=17;[row,col] = vec2mat(i,NumOfChannels);
Vgain = NumInt(row,col);
%
i=18;[row,col] = vec2mat(i,NumOfChannels);
Wgain = NumInt(row,col);
%
i=19;[row,col] = vec2mat(i,NumOfChannels);
Tgain = NumInt(row,col);
%
i=20;[row,col] = vec2mat(i,NumOfChannels);
Tinternal = NumInt(row,col);
%
i=21;[row,col] = vec2mat(i,NumOfChannels);
Pgauge = NumInt(row,col);
%
i=22;[row,col] = vec2mat(i,NumOfChannels);
Po = NumInt(row,col);
%
i=14;[row,col] = vec2mat(i,NumOfChannels);
Pconst1 = NumInt(row,col);
%
i=15;[row,col] = vec2mat(i,NumOfChannels);
Pconst2 = NumInt(row,col);
%
i=23;[row,col] = vec2mat(i,NumOfChannels);
Tco = NumInt(row,col);
%
i=24;[row,col] = vec2mat(i,NumOfChannels);
Cgain = NumInt(row,col);
%
i=25;[row,col] = vec2mat(i,NumOfChannels);
OffsetC = NumInt(row,col);
%
i=26;[row,col] = vec2mat(i,NumOfChannels);
ac = NumInt(row,col);
i=27;[row,col] = vec2mat(i,NumOfChannels);
bc = NumInt(row,col);
i=28;[row,col] = vec2mat(i,NumOfChannels);
cc = NumInt(row,col);
i=29;[row,col] = vec2mat(i,NumOfChannels);
dc = NumInt(row,col);
i=30;[row,col] = vec2mat(i,NumOfChannels);
ec = NumInt(row,col);
%
i=31;[row,col] = vec2mat(i,NumOfChannels);
Tho = NumInt(row,col);
i=33;[row,col] = vec2mat(i,NumOfChannels);
OffsetH = NumInt(row,col);
i=32;[row,col] = vec2mat(i,NumOfChannels);
Hgain = NumInt(row,col);
i=34;[row,col] = vec2mat(i,NumOfChannels);
ah = NumInt(row,col);
i=35;[row,col] = vec2mat(i,NumOfChannels);
bh = NumInt(row,col);
i=36;[row,col] = vec2mat(i,NumOfChannels);
ch = NumInt(row,col);
i=37;[row,col] = vec2mat(i,NumOfChannels);
dh = NumInt(row,col);
i=38;[row,col] = vec2mat(i,NumOfChannels);
eh = NumInt(row,col);
%
i=39;[row,col] = vec2mat(i,NumOfChannels);
OffsetRHOV = NumInt(row,col);
i=40;[row,col] = vec2mat(i,NumOfChannels);
Vox = NumInt(row,col);
i=41;[row,col] = vec2mat(i,NumOfChannels);
XKw = NumInt(row,col);
%
i=43;[row,col] = vec2mat(i,NumOfChannels);
PGconst1 = NumInt(row,col);
i=44;[row,col] = vec2mat(i,NumOfChannels);
PGconst2 = NumInt(row,col);
%
i=45;[row,col] = vec2mat(i,NumOfChannels);
ProbeOrient = NumInt(row,col);
%
i=46;[row,col] = vec2mat(i,NumOfChannels);
SolentTempSlope = NumInt(row,col);
%
i=47;[row,col] = vec2mat(i,NumOfChannels);
SolentTempOffset = NumInt(row,col);
%
%       Remove the header
%
NumInt = NumInt(HeaderLength+1:NumOfLines,:);
NumOfLines = NumOfLines - HeaderLength;
