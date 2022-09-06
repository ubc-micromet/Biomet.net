function [dir_bin,wT_bin] = fcrn_calc_cov_dir_comp(tv_exp,SiteId)

arg_default('tv_exp',floor(now-1):1/48:ceil(now-1));
arg_default('SiteId',fr_current_siteid);

for i = 1:length(tv_exp)
    
    try
        if strcmp(fr_get_pc_name,'XSITE01')
            cd('c:\ubc_pc_setup\site_specific');
        else
            cd(fullfile(xsite_base_path,SiteId,'ubc_pc_setup\site_specific'));
        end
        [Stats_xsite,HF_xsite] = yf_calc_module_main(tv_exp(i),[],2);
        
        cd(fullfile(xsite_base_path,SiteId,'Setup'));
        [Stats_main,HF_main] = yf_calc_module_main(tv_exp(i),[],2);
        
        
        tv_sys_xsite = [1:length(HF_xsite.System(1).EngUnits)]./20;
        tv_sys_main  = [1:length(HF_main.System(1).EngUnits)]./20;
        tv_ins_xsite = [1:length(HF_xsite.Instrument(2).EngUnits)]./20;
        tv_ins_main  = [1:length(HF_main.Instrument(2).EngUnits)]./20;
        
        dir_xsite = FR_Sonic_wind_direction(HF_xsite.System(1).EngUnits(:,1:3)','GILLR3');
        dir_main  = FR_Sonic_wind_direction(HF_main.System(1).EngUnits(:,1:3)','CSAT3');
        
        [HF_xsite.System(1).EngUnits(:,1:3)] = fr_rotatn_hf(HF_xsite.System(1).EngUnits(:,1:3),...
            [Stats_xsite.XSITE_CP.Three_Rotations.Angles.Eta ...
                Stats_xsite.XSITE_CP.Three_Rotations.Angles.Theta ...
                Stats_xsite.XSITE_CP.Three_Rotations.Angles.Beta]);      
        
        [HF_main.System(1).EngUnits(:,1:3)] = fr_rotatn_hf(HF_main.System(1).EngUnits(:,1:3),...
            [Stats_main.MainEddy.Three_Rotations.Angles.Eta ...
                Stats_main.MainEddy.Three_Rotations.Angles.Theta ...
                Stats_main.MainEddy.Three_Rotations.Angles.Beta]);      
        
        d_sys = fr_delay(HF_xsite.System(1).EngUnits(:,3),HF_main.System(1).EngUnits(:,3),5000);
        disp(['Delay: ' num2str(d_sys)]);
        
        [w_xsite,w_main] = fr_remove_delay(HF_xsite.System(1).EngUnits(:,3)',...
            HF_main.System(1).EngUnits(:,3)',d_sys,d_sys);
        w = [w_xsite',w_main'];
        
        [T_xsite,T_main] = fr_remove_delay(HF_xsite.System(1).EngUnits(:,4)',...
            HF_main.System(1).EngUnits(:,4)',d_sys,d_sys);
        T = [T_xsite',T_main'];
        
        [dir_xsite,dir_main] = fr_remove_delay(dir_xsite,dir_main,d_sys,d_sys);
        dir = [dir_xsite',dir_main'];
        [dir_s,ind_s] = sort(dir(:,1));
        
        tv = [1:length(T)]./20;
        
        wT = detrend(w(ind_s,:),0).*detrend(T(ind_s,:),0);
        diff_wT = diff(wT,[],2);
        
        [dir_bin(:,i),wT_bin(:,:,i)] = bin_avg(dir_s,diff_wT,0:10:360,[1 4 5]);
    end
end
