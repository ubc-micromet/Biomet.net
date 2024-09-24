function create_BIOMET_file_for_EP(yearsIn,siteID,dataType,varNames,varUnits,outputPath)
% create_BIOMET_file_for_EP - outputs a csv file containing Pa and Ta data in EddyPro format
%
% Inputs:
%   yearsIn         - range of years to output. Default current year.
%   siteID          - site ID
%   dataType        - default: 'Clean\SecondStage' for second-stage clean data
%   varNames        - default: {'TA_1_1_1','PA_1_1_1'}
%   varUnits        - default: {'C','kPa'}
%   outputPath      - path where the file should be stored at. 
%
% Notes:
%  - the file name is set to siteID_biomet_for_eddypro.csv
%
% Zoran Nesic           File created:       Sep 23, 2024
%                       Last modification:  Sep 23, 2024

% Revisions: 
%

arg_default('yearsIn',year(datetime))
arg_default('dataType','clean/SecondStage')
arg_default('varNames',{'TA_1_1_1','PA_1_1_1'})
arg_default('varUnits',{'C','kPa'})
arg_default('outputPath','.')

if ~exist(outputPath,'dir')
    error('Output path does not exist!');
end

outputFile = fullfile(outputPath,sprintf('%s_biomet_for_eddypro.csv',upper(siteID)));
pathIn = biomet_path('yyyy',siteID,dataType);

tv = read_bor(fullfile(pathIn,'clean_tv'),8,[],yearsIn);
tv_dt = datetime(tv,'ConvertFrom','datenum');
tv_dt.Format= "uuuu-MM-dd HHmm";
dataOut = [];
for cntVars = 1: length(varNames)
    varName = char(varNames{cntVars});
    dataOut(:,cntVars) = read_bor(fullfile(pathIn,varName),[],[],yearsIn);
end

% Replace all NaNs with -9999
dataOut(isnan(dataOut)) = -9999;

% round all values to 4 decimal places
dataOut = round(dataOut,4);

% Create a struct of variable names from the header
tabOut = array2table(dataOut,'VariableNames',varNames);
tabOut = addvars(tabOut,string(tv_dt),'before',1,'NewVariableNames','TIMESTAMP_1');

% Write the header first
varNamesOut = 'TIMESTAMP_1';
varUnitsOut = 'yyyy-mm-dd HHMM';
for cntVars = 1:length(varNames)
    varNamesOut = [varNamesOut ',' char(varNames(cntVars))];
    varUnitsOut = [varUnitsOut ',' char(varUnits(cntVars))];
end
    
fid = fopen(outputFile,'w');
if fid > 0
    fprintf(fid,'%s\n',varNamesOut);
    fprintf(fid,'%s',varUnitsOut);
    fclose(fid);
end
writetable(tabOut,outputFile,'WriteMode','append','WriteVariableNames',false,'QuoteStrings',false);

% Create the 




