function csv_save(cHeader,opath,fileName,tv,cFormat,data)
%% THIS MATLAB FUNCTION SAVE CSV FILES FOR WEB PLOTTING
%
%       cHeader         column headers
%       opath           output path
%       fileName        File name
%       tv              time vector (string)
%       cFormat         column data format
%       data            data (as matrix)
%
%   Written by Sara Knox, Oct 21, 2019
%   Last modification:    Nov  8, 2019

% Revisions (newest first)
%
%  Nov 6, 2019 (Zoran)
%    - Worked on speeding up the function
%

%%
% Create header
commaHeader = [cHeader;repmat({','},1,numel(cHeader))]; %insert commaas
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader); %cHeader in text with commas

%write header to file
fid = fopen([opath fileName],'w'); 
fprintf(fid,'%s\n',textHeader);
   tmp1 = [char(tv{:}) ones(length(tv),1)* ','];
   tmp3 = sprintf(cFormat, data');
   tmp2=reshape(tmp3,[],length(tv))';
   str_buffer = [tmp1 tmp2];
fprintf(fid,'%s',str_buffer');
fclose(fid);