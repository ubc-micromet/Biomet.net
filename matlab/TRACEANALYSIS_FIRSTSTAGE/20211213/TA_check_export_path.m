function TA_check_export_path(file_opts,trace_str)

cl_flag = 0;
fl_flag = 0;
pr_flag = 0;

for i = 1:length(trace_str)
    switch upper(trace_str(i).ini.measurementType)
    case 'CL'
        cl_flag = 1;
    case 'FL'
        fl_flag = 1;
    case 'PR'
        pr_flag = 1;
    end
end    

path = [file_opts.out_path 'climate\clean\'];
if ~exist(path) & cl_flag == 1
    button = questdlg([path ' does not exist.Create it?']);        
    switch button
    case 'Yes'
        status = mkdir(file_opts.out_path,'climate');            
        status = mkdir(file_opts.out_path,'climate\clean');            
        if status == 0
            warndlg(['Could not create ' path]);
            return
        end
    case 'Cancel'
        return
    end
end
path = [file_opts.out_path 'flux\clean\'];
if ~exist(path) & fl_flag == 1
    button = questdlg([path ' does not exist.Create it?']);        
    switch button
    case 'Yes'
        status = mkdir(file_opts.out_path,'flux');            
        status = mkdir(file_opts.out_path,'flux\clean');            
        if status == 0
            warndlg(['Could not create ' path]);
            return
        end
    case 'Cancel'
        return
    end
end
path = [file_opts.out_path 'profile\clean\'];
if ~exist(path) & pr_flag == 1
    button = questdlg([path ' does not exist.Create it?']);        
    switch button
    case 'Yes'
        status = mkdir(file_opts.out_path,'profile');            
        status = mkdir(file_opts.out_path,'profile\clean');            
        if status == 0
            warndlg(['Could not create ' path]);
            return
        end
    case 'Cancel'
        return
    end
end
