function fcrn_print_report(h,pth_plt)

if ~exist('pth_plt') | isempty(pth_plt)
   [dd,pth_fcrnresult] = fr_get_local_path;
   pth_plt = fullfile(pth_fcrnresult,'report',filesep);
end

max_win = kais_poster_figsize;

for i = 1:length(h)
   set(h(i).hand,'Position',max_win,'Renderer','painter','Color','none','InvertHardcopy', 'off');
   figure(h(i).hand)
   print('-dmeta',fullfile(pth_plt,h(i).name))
end