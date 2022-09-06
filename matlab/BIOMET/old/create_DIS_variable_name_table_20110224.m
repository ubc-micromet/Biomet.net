function [data_first,data_second,data_third,data_fcrn] = create_DIS_variable_name_table(year,SiteId,db_ini);

% year = 2007;
% SiteId = 'BS';
% db_ini = [];

arg_default('db_ini',[]);

data_first = fr_cleaning_siteyear(year,SiteId,1,db_ini);
for i=1:length(data_first)
  data_first(i).inifile = 1;
end

data_second = fr_cleaning_siteyear(year,SiteId,2,db_ini);
for i=1:length(data_second)
  data_second(i).inifile = 2;
end

data_third = fr_cleaning_siteyear(year,SiteId,3,db_ini);
for i=1:length(data_third)
  data_third(i).inifile = 3;
end

data_fcrn = get_fcrn_trace_str(data_first,data_second,data_third);

fid = fopen([ SiteId '_DIS_variable_table.txt' ],'wt');
for j=1:length(data_fcrn)
    if j==1
        disp(sprintf('%40s    %30s  %30s','UBC_Variable_Name','DIS_Variable_Name','ini_file_Stage'));
        fprintf(fid,'%40s    %30s  %30s\n','UBC_Variable_Name','DIS_Variable_Name','ini_file_Stage');
    end
    disp(sprintf('%40s    %30s  %30s',data_fcrn(j).variableName,data_fcrn(j).ini.FCRN_Variable,num2str(data_fcrn(j).inifile)));
    fprintf(fid,'%40s    %30s  %30s\n',data_fcrn(j).variableName,data_fcrn(j).ini.FCRN_Variable,num2str(data_fcrn(j).inifile));
end

fclose(fid);