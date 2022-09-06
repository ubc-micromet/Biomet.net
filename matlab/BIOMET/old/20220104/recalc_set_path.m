function recalc_set_path(pth_base)

%
% Biomet toolbox path (mirror copy of the server's toolbox is stored there)
%
arg_default('pth_base',pwd);

pth = fullfile(pth_base,'biomet.net','matlab');
path(pathdef);
path(fullfile(pth,'TraceAnalysis_Tools'),path);
path(fullfile(pth,'TraceAnalysis_SecondStage'),path);
path(fullfile(pth,'TraceAnalysis_FirstStage'),path);
path(fullfile(pth,'TRACEANALYSIS_FCRN_THIRDSTAGE'),path);
path(fullfile(pth,'soilchambers'),path);
path(fullfile(pth,'soilchambers'),path);
path(fullfile(pth,'biomet'),path);  
path(fullfile(pth,'boreas'),path);
path(fullfile(pth,'biomet'),path);      
path(fullfile(pth,'new_met'),path);      
path(fullfile(pth,'met'),path);    
path(fullfile(pth,'new_eddy'),path); 
path(fullfile(pth,'SystemComparison'),path); 

path(fullfile(pth_base,'ubc_PC_setup','site_specific'),path);      

pth_pc = fullfile('c:','ubc_PC_setup','PC_specific');
if exist(pth_pc) == 7
    path(pth_pc,path);
else
    path(fullfile(pwd,'ubc_PC_setup','PC_specific'),path);          
end
