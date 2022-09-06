function rename_Shell_30min_files(siteId);

switch upper(siteId)
    
    case 'SQM'
        pth_ascii = 'K:\ShellQuest\SQM\raw\ascii\';
        pth_out = 'K:\ShellQuest\SQM\CSI_net\old';
        lstClim30m = dir(fullfile(pth_ascii,'TOA5_20629.clim*.dat'));
        lstcompcov = dir(fullfile(pth_ascii,'TOA5_20629.comp_cov*.dat'));
        lstflux30m = dir(fullfile(pth_ascii,'TOA5_20629.flux_30m*.dat'));
        lstTscov = dir(fullfile(pth_ascii,'TOA5_20629.Tscov*.dat'));
        fnClim30m={lstClim30m.name}';
        fncompcov={lstcompcov.name}';
        fnflux30m={lstflux30m.name}';
        fnTscov={lstTscov.name}';

        for i=1:length(fnClim30m),
            fnstrClim30m=char(fnClim30m{i});
            fnstrClim30m=['SQM_Clim_30m.dat'];
			disp(sprintf('...moving %s to %s',fullfile(pth_ascii,char(fnClim30m{i})),fullfile(pth_out,fnstrClim30m)));
            movefile(fullfile(pth_ascii,char(fnClim30m{i})),fullfile(pth_out,fnstrClim30m));
         end
        
        for i=1:length(fncompcov),
            fnstrcompcov=char(fncompcov{i});
            fnstrcompcov=['SQM_comp_cov.' fnstrcompcov(21:end)];
			disp(sprintf('...moving %s to %s',fullfile(pth_ascii,char(fncompcov{i})),fullfile(pth_out,fnstrcompcov)));
            movefile(fullfile(pth_ascii,char(fncompcov{i})),fullfile(pth_out,fnstrcompcov));
        end

        for i=1:length(fnflux30m),
            fnstrflux30m=char(fnflux30m{i});
            fnstrflux30m=['SQM_flux_30m.' fnstrflux30m(21:end)];
			disp(sprintf('...moving %s to %s',fullfile(pth_ascii,char(fnflux30m{i})),fullfile(pth_out,fnstrflux30m)));
            movefile(fullfile(pth_ascii,char(fnflux30m{i})),fullfile(pth_out,fnstrflux30m));
        end

        for i=1:length(fnTscov),
            fnstrTscov=char(fnTscov{i});
            fnstrTscov=['SQM_Tscov.' fnstrTscov(18:end)];
			disp(sprintf('...moving %s to %s',fullfile(pth_ascii,char(fnTscov{i})),fullfile(pth_out,fnstrTscov)));
            movefile(fullfile(pth_ascii,char(fnTscov{i})),fullfile(pth_out,fnstrTscov));
        end
		
end