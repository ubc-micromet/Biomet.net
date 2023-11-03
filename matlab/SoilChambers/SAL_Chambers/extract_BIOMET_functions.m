%% Preparations to run UdeM ACS recalcs on any PC:
%
% (*** this works only on Zoran's PC! ***)
%
% Copy Biomet.net functions to the local folder Biomet.net folder 
% Run:
%   >> profile on
%   >> dataStruct = run_UdeM_ACS_calc_one_day(datenum(2019,8,2),false,true);
% Press CTRL-C after a few samples are processed
%   >> profile off

% The following copies only the necessary Biomet.net files to local_BIOMET.NET folder):
% Note: a folder with this name needs to exist under the UdeM toolbox folder 
%       (under the folder that contains this file)
p=profile('info');
for i=1:length(p.FunctionTable)
    if contains(p.FunctionTable(i).FileName,'paoa001','IgnoreCase',true)
        if strcmpi(p.FunctionTable(i).Type,'M-function')
            fprintf('%d - %s\n',i,p.FunctionTable(i).FileName);
            %copyfile(p.FunctionTable(i).FileName, fullfile('local_BIOMET.NET/',[p.FunctionTable(i).FunctionName '.m']));
            copyfile(p.FunctionTable(i).FileName, 'local_BIOMET.NET/');
        end
    end
end


% Next:
%   - edit the local version of fr_get_local_path (the one in the local UBC_PC_Setup\Site_Specific
%     folder. All paths should point to the local "met-data" folder.
%   - run setup_UdeM_calc to get UdeM toolbox running without the full Biomet.net and using
%     a local version of UBC_PC_Setup\PC_specific. 
%  
%
% The site PC uses its own version of Biomet.net and UBC_PC_Setup (as always).

