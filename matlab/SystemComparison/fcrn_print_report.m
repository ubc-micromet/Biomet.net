function fcrn_print_report(h,pth_plt,textResults,print_format)

arg_default('print_format','-deps');

if ~exist('pth_plt') | isempty(pth_plt)
   [dd,pth_fcrnresult] = fr_get_local_path;
   pth_plt = fullfile(pth_fcrnresult,'report',filesep);
end

max_win = get(0,'ScreenSize');

for i = 1:length(h)
    if ~isfield(h(i),'PreserveAspectRatio')
        set(h(i).hand,'Position',max_win);
    end
   figure(h(i).hand)
   c = get(h(i).hand,'Children'); % These are the axes
   if isfield(h(i),'PreserveAspectRatio')
        for j = 1:length(c)
            set(c(j),'Units','inches');
        end
   end
  if strcmp(print_format,'-deps')
       set(h(i).hand,'Renderer','painter');
       print(print_format,'-tiff',fullfile(pth_plt,h(i).name ));
   else
       set(h(i).hand,...
           'Renderer','painter',...
           'InvertHardcopy','off',...
           'Color','none');
       print(print_format,fullfile(pth_plt,h(i).name ));
   end
   
   close(h(i).hand);
end

if exist('textResults') & ~isempty(textResults)
    fid = fopen(fullfile(pth_plt,[h(1).name '.txt']),'wt');
    fprintf(fid,'%s',textResults);
    fclose(fid);
end
