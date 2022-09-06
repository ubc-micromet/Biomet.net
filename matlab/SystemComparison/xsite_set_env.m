function xsite_set_env(experiment,setup)
% xsite_set_env(experiment,setup) Set path for current computer

% Determine location - lab or field PC

pc_name = fr_get_pc_name;
lab = isempty(find(strcmp(upper(pc_name),{'XSITE01','XSITE02'})));

if strcmp(upper(setup),'CURRENT')
    % Use default matlab setup and only change data/hhour path
    if lab
        addpath('\\paoa001\sites\xsite\';
    else
        pth_base_config = 'c:';
    end
    
end


        

pc_name = fr_get_pc_name;

if isempty(find(strcmp(upper(pc_name),{'XSITE01','XSITE02'})))
    pth_base_config = '\\paoa001\sites\xsite';
    pth_base_data   = '\\Fluxnet02\HFREQ_XSITE';
else
    pth_base_config = 'c:';
    pth_base_data   = 'd:';
end


    