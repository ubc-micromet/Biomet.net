function fr_create_extra_thirdstage(Years,SiteId,ini_file_third,db_out,dir_out)
% fr_create_extra_thirdstage - Create non-standard third stage
%
% fr_create_extra_thirdstage(Years,SiteId,ini_file_third,db_out,dir_out)
%
% Reads the data for multiple years of a single site with SiteID using 
% the ini_file_third (fullpath and name) and exports it to db_out under the
% directory 'Year\SiteId\clean\dir_out'. Data is read from the db indicated
% by biomet_path. 

for yy = Years
    yy_str = num2str(yy);
    disp(['============== Special cleaning ' SiteId ' ' yy_str ' ==============']);
    pth_out = fullfile(db_out,yy_str,SiteId,'clean',dir_out,'');
    db_dir_ini(yy,SiteId,db_out,3,dir_out);
    data_cleaned = read_data(yy,SiteId,ini_file_third);
    export(data_cleaned,pth_out);
    disp(['============== End special cleaning ' SiteId ' ' yy_str ' ===========']);
    disp(sprintf(''));
end

