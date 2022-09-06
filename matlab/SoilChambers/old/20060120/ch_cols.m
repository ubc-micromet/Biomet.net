function x = ch_cols(pthIn,fileNameIn, pthOut, fileNameOut);
%
%  Program to split up chamber data into columns
%
%  Inputs: pthIn = where lg matrix is found
%			  fileNameIn = name of lg matrix
%			  pthOut = where columns of data are to go
%			  fileNameOut = beginning of column name ie 'ch21x'

%  (c) Zoran Nesic & E.Humphreys            File created:       Sept 1, 1998
%                                           Last modification:

if ~strcmp(pthIn(end),'\') 
   pthIn = [pthIn '\'];
end
if ~strcmp(pthOut(end),'\') 
   pthOut = [pthOut '\'];
end

load([pthIn fileNameIn]);

%dataIn = data; %added in this case since variables were renamed
%timeSer = t; % as above

[m,n] = size(dataIn);

fileName=[pthOut 'CR_CR10_tv'];
save_bor(fileName,8,timeSer);

for i=1:n
   fileName = [pthOut fileNameOut num2str(i)];
   save_bor(fileName,1,dataIn(:,i));
end


   