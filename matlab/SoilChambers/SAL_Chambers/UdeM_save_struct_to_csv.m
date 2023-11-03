function UdeM_save_struct_to_csv(chamberOut,outputPath)
%
% Input:
%   chamberOut -data structure with joint daily UdeM dataStruct-ures
%   outputPath - path for csv files (files: chamberXX.csv) 
%
% Output:
%   csv files stored in the folder outputPath (one chamber per file)  
%
% Example:
%    - use: chamberOut = UdeM_join_mat_files(filePath,dateRange) to create chamberOut structure
%    - use: UdeM_save_struct_to_csv(chamberOut,outputPath) to save csv files
%
%
% Zoran Nesic               File created:       Apr  1, 2020
%                           Last modification:  Apr  1, 2020


for chNum=1:18
    % Reserve some memory space. maxColumns should be larger than the anticipated 
    % number of traces being exported
    N = length(chamberOut.chamber(chNum).tv);
    maxColumns = 50;
    dataOut = NaN * zeros(N,maxColumns);
    strHeader = '';
    colCount = 0;
    colCount = colCount+1; strHeader = [strHeader 'END time']; dataOut(:,colCount) = chamberOut.chamber(chNum).tv; %#ok<*AGROW>
    tvEndHour = ceil(rem(chamberOut.chamber(chNum).tv*24,24));
    colCount = colCount+1; strHeader = [strHeader ',END hour']; dataOut(:,colCount) = tvEndHour;
    colCount = colCount+1; strHeader = [strHeader ',Tair']; dataOut(:,colCount) = chamberOut.chamber(chNum).airTemperature.avg;
    colCount = colCount+1; strHeader = [strHeader ',PAR']; dataOut(:,colCount) = chamberOut.chamber(chNum).PAR_in.avg;
    colCount = colCount+1; strHeader = [strHeader ',Tsoil']; dataOut(:,colCount) = chamberOut.chamber(chNum).soilTemperature_in.avg;
    colCount = colCount+1; strHeader = [strHeader ',VWC']; dataOut(:,colCount) = chamberOut.chamber(chNum).soilVWC_in.avg;
    colCount = colCount+1; strHeader = [strHeader ',H2O']; dataOut(:,colCount) = chamberOut.chamber(chNum).h2o_ppm.avg;
    colCount = colCount+1; strHeader = [strHeader ',CO2']; dataOut(:,colCount) = chamberOut.chamber(chNum).co2_dry.avg;
    colCount = colCount+1; strHeader = [strHeader ',CH4']; dataOut(:,colCount) = chamberOut.chamber(chNum).ch4_dry.avg;      
    for cellGasNames = {'co2','ch4'}    
        cGasName = char(cellGasNames); 
        for cellFitFieldNames = {'lin_B','exp_B'}            
            cFitName = char(cellFitFieldNames);
            colCount = colCount+1; strHeader = [strHeader ',' cGasName '_dcdt_' cFitName]; dataOut(:,colCount) = chamberOut.chamber(chNum).flux.(cGasName).(cFitName).dcdt;
            colCount = colCount+1; strHeader = [strHeader ',' cGasName '_flux_' cFitName]; dataOut(:,colCount) = chamberOut.chamber(chNum).flux.(cGasName).(cFitName).flux;
            colCount = colCount+1; strHeader = [strHeader ',' cGasName '_rmse_' cFitName]; dataOut(:,colCount) = chamberOut.chamber(chNum).flux.(cGasName).(cFitName).rmse;
        end
    end
    % 'E:\Site_DATA\WL\met-data\csv'
    fileName = fullfile(outputPath,sprintf('chamber_%02d.csv',chNum));
    fid = fopen(fileName,'w');
    if fid>0
        fprintf(fid,'%s\n',strHeader);
        for sampleNum = 1:size(dataOut,1)
            for rowNum=1:colCount
                if rowNum==1
                    fprintf(fid,'%s,',datestr(dataOut(sampleNum,rowNum),0));
                else
                    fprintf(fid,'%12.4e,',dataOut(sampleNum,rowNum));
                end
            end
            fprintf(fid,'\n');
        end
        fclose(fid);
    else
        fprintf('Error!! Could not write file: %s. Probably opened in Excel.\n',fileName);
    end                 
end
fprintf('%s - Finished saving csv files.\n\n',datestr(now));       