function recalc_configure(base_dir)

arg_default('base_dir',pwd);

diary(fullfile(base_dir,'recalc.log'));
disp(sprintf('== Setting recalculation path =='));
disp(sprintf('Date: %s',datestr(now)));

%----------------------------------------------------------------------------------
% Do away with old path & go back to basic matlab
%----------------------------------------------------------------------------------
path(pathdef);

%----------------------------------------------------------------------------------
% Add Biomet paths
%----------------------------------------------------------------------------------
% Paths are added at the beginning, thus the directory added last will be at
% the top of the path!
%
% Biomet toolbox paths (copy of the server's toolbox as used in the analysis)
% must be added if running without automatic biomet toolbox setup
path([base_dir '\biomet.net\matlab\TraceAnalysis_FCRN_THIRDSTAGE'],path);
path([base_dir '\biomet.net\matlab\TraceAnalysis_Tools'],path);
path([base_dir '\biomet.net\matlab\TraceAnalysis_SecondStage'],path);
path([base_dir '\biomet.net\matlab\TraceAnalysis_FirstStage'],path);
path([base_dir '\biomet.net\matlab\soilchambers'],path);
path([base_dir '\biomet.net\matlab\boreas'],path);
path([base_dir '\biomet.net\matlab\biomet'],path);      
path([base_dir '\biomet.net\matlab\new_met'],path);      
path([base_dir '\biomet.net\matlab\met'],path);    
path([base_dir '\biomet.net\matlab\new_eddy'],path); 
path([base_dir '\biomet.net\MATLAB\SystemComparison'],path);         % use this line on the workstations
path([base_dir '\ubc_PC_setup\site_specific'],path);      

path(['c:\ubc_PC_setup\PC_specific'],path);

disp('Here is where you will be working from:')
path

disp(sprintf('SiteId = %s',fr_current_siteid));

