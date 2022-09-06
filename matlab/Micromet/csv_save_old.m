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
% 
%%
% Create header
commaHeader = [cHeader;repmat({','},1,numel(cHeader))]; %insert commaas
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader); %cHeader in text with commas

%write header to file
fid = fopen([opath fileName],'w'); 
fprintf(fid,'%s\n',textHeader);

%Write CSV file
for iLine = 1:size(data, 1) % Loop through each time/value row
   fprintf(fid, '%s,', tv{iLine}) ; % Print the time string
   fprintf(fid, cFormat, data(iLine, 1:end)) ; % Print the data values
end
fclose(fid);