function [h,varOut,textResults] = fcrn_plot_comp(Stats_all,system_names,config_plot,tv_exclude,figureTitle,export_pth)
% h = fcrn_plot_comp(Stats_all,system_names,config_plot,tv_exclude,figureTitle)
%
%
% 

plotting_setup

arg_default('system_names',{'XSITE_CP','XSITE_OP'});
arg_default('config_plot','report_var');
arg_default('tv_exclude');
arg_default('figureTitle',{[char(system_names(1)),'_',char(system_names(2)),'_',config_plot]});
arg_default('export_pth');

% For plotting replace the underscore
system_names_plt = strrep(system_names,'_','\_');

%----------------------------------------------------
% Define variables to be extracted for both systems
%----------------------------------------------------
eval(['variable_info = ' config_plot ';']);

%----------------------------------------------------
% Extract variables for both systems
%----------------------------------------------------
[var_names] = fcrn_extract_var('Stats_all',system_names,variable_info);

%----------------------------------------------------
% Exclude indeces given in command line
%----------------------------------------------------
[dum,ind_name] = unique(var_names);
[tv_dum,ind_exclude] = intersect(fr_round_hhour(tv),fr_round_hhour(tv_exclude));
for k = ind_name
    cmd = [char(var_names(k)) '(ind_exclude) = NaN;'];
    eval(cmd);
    cmd = ['varOut.' char(var_names(k)) '= ' char(var_names(k)) ';'];
    eval(cmd);
end   

%----------------------------------------------------
% File export
%----------------------------------------------------
if exist(export_pth) & ~isempty(export_pth)
    yy = datevec(fr_round_hhour(tv));
    export_mat = [yy(:,1:5)];
    for k = 1:length(var_names)
        cmd = [char(var_names(k)) '(find(isnan(' char(var_names(k)) '))) = -999;'];
        eval(cmd);
        cmd = ['export_mat = [export_mat ' char(var_names(k)) '];'];
        eval(cmd);
    end   
    
    %----------------------------------------------------
    % Write header    
    fileName = fullfile(export_pth,[char(figureTitle) '_header.csv']);
    fid = fopen([fileName],'w');

    fprintf(fid,'YYYY,MM,DD,hh,mm,',char(var_names(k)));
    for k = 1:length(var_names)
        fprintf(fid,'%s,',char(var_names(k)));
    end   
    fseek(fid,-1,0);
    fprintf(fid,'\n');
    fprintf(fid,' , , , , ,',char(var_names(k)));
    for k = 1:length(variable_info)
        fprintf(fid,'%s,%s,',char(variable_info(3,k)),char(variable_info(3,k)));
    end   
    fseek(fid,-1,0);
    fprintf(fid,'\n');

    fclose(fid);
    
    %----------------------------------------------------
    % Write data
    fileName = fullfile(export_pth,[char(figureTitle) '_data.csv']);
    csvwrite([fileName],export_mat,2,0);
    
    return
end

%----------------------------------------------------
% Do comparison plots
%----------------------------------------------------
j = 1;
for k = 1:round(length(variable_info)/4)*4
    i = mod(k-1,4)+1;
    if i == 1;
        if j>1
            select_datapoints(h(j-1).hand);
        end
        
        if length(figureTitle) == 1
            figureTitle_cur = [char(figureTitle) '_' num2str(j)];
        else
            figureTitle_cur = [char(figureTitle(j))];
        end
        
        h(j).name = figureTitle_cur;
        h(j).hand = figure;
        set(h(j).hand,'Name',h(j).name);
        set(h(j).hand,'NumberTitle','off');
        top.tv = tv;
        top.SiteId = fr_current_siteid;
        set(gcf,'UserData',top);
        j = j+1;
    end
    
    subplot(2,2,i)
    set(gca,'FontSize',fcrn_report_font_size) 
    set(gca,'DefaultTextFontSize',fcrn_report_font_size);
    
    cmd = ['plot_regression(' char(var_names(2*k-1)) ',' char(var_names(2*k)) ',[],[],''ortho'')'];   
    eval(cmd);
    cmd = ['xlabel(''' char(variable_info(4,k)) ' ' char(system_names_plt(1)) ' (' char(variable_info(3,k)) ')'');'];
    eval(cmd);
    cmd = ['ylabel(''' char(variable_info(4,k)) ' ' char(system_names_plt(2)) ' (' char(variable_info(3,k)) ')'');'];
    eval(cmd);
    
    cmd = ['a(k,:) = linregression_orthogonal(' char(var_names(2*k-1)) ',' char(var_names(2*k)) ');'];   
    eval(cmd);
    %   zoom_together(gcf,'on')

    if k == 1
        textResults = sprintf('\n\nNumber of good points = %d\n\n',a(k,9));
        textResults = [textResults sprintf('    Variable:               Slope          Intercept        r^2        RMSE of reg.\n')];
    end

    textResults = [textResults sprintf('%20s:%6.2f +/- %5.2f %6.2f +/- %5.2f     %5.2f     %5.3f\n',char(variable_info(2,k)),a(k,[1 5 2 6 8 7]))];
end
disp(textResults)

select_datapoints(h(j-1).hand);

return