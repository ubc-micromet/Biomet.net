function view_hf_xy(fig)

user_data_in = get(fig,'UserData');

for i = 1:2
   a      = ['Trace' num2str(i)'];
   b      = findobj(fig,'Tag',a);            % get the selected trace from popup menu
   val(i) = get(b,'Value');                 % read the string matrix
end

subplot(1,1,1);                              
g = gca;
p = get(g,'Position');
set(g, 'Position', [0.75.*p(1) p(2) 0.75.*p(3) 0.985*p(4)],'Color',[0 0.1 0.2],...
   'Fontsize',10);

switch user_data_in(1).type
case 'xcorr'
   ind = find(abs(user_data_in.xdata) <= 100);
   trace_1 		= user_data_in.xdata(ind);
   trace_2 		= user_data_in.data(ind,(val(1)-1).*7 + val(2));
   title_str    = ['Correlation ' char(user_data_in.titles(val(1))) ' x ' char(user_data_in.titles(val(2))) ];
   xlabel_str	= 'Delay (samples)';
   ylabel_str	= 'Correlation';
   ax_vec		= [-100 100 -1 1];
   plot(trace_1,trace_2,'y-');
	set(g,'XGrid','on','YGrid','on');
   
case 'spec'
   trace_1 		= user_data_in.xdata;
   ax_f		= [5e-4 10];
   if val(1) == val(2)
      ind = 1;
      title_str   = ['Power spectrum ' char(user_data_in.titles(val(1)))];
      trace_2 		= user_data_in.data.Psd(:,val(1))./user_data_in.data.Psd_norm(val(ind));
      loglog(trace_1,trace_2)
      ax_vec = [ax_f 1e-4 1e2];
      ylabel_str	= 'fS_x \sigma^{-2}';
   else
      ind = find(val~=3);
      if length(ind)>1
         h = msgbox(['Sorry - only w''x'' co-spectra are calculated'],'No spectrum','error','modal');
			bgc = [0 0.36 0.532];
		   set(h,'Color',bgc,'WindowStyle','modal');
   return
      else
         trace_2 		= user_data_in.data.Csd(:,val(ind))./user_data_in.data.Csd_norm(val(ind));
         title_str   = ['Co-spectrum ' char(user_data_in.titles(val(1))) ' x ' char(user_data_in.titles(val(2)))];
         semilogx(trace_1,trace_2)
         ax_vec = [ax_f -1e2 1e2];
         ylabel_str	= 'fC_{xy} cov_{xy}^{-1}';
      end
   end
	xlabel_str	= 'f (Hz)';
   
case '1to1'
   trace_1 = user_data_in(val(1)).data;
   trace_2 = user_data_in(val(2)).data;
   len = min(length(trace_1),length(trace_2));
   trace_1 = trace_1(1:len);
   trace_2 = trace_2(1:len);
   
   ax_x = [mean(trace_1)-4*std(trace_1) mean(trace_1)+4*std(trace_1)];
   ax_y = [mean(trace_2)-4*std(trace_2) mean(trace_2)+4*std(trace_2)];
   ax_vec = [ax_x ax_y];
   
   g = gca;
   set(g,'XGrid','on','YGrid','on');
   title_str   = [''];
   xlabel_str	= [char(user_data_in(val(1)).title) ' ' char(user_data_in(val(1)).unit)];
   ylabel_str	= [char(user_data_in(val(2)).title) ' ' char(user_data_in(val(2)).unit)];
   
   plot(trace_1,trace_2,'y.');
   hold on
   plot(ax_x,[mean(trace_2) mean(trace_2)],'r-');
   plot([mean(trace_1) mean(trace_1)],ax_y,'r-');
	set(g,'XGrid','on','YGrid','on');
end

axis(ax_vec);
title(title_str,'Fontsize',12);
xlabel(xlabel_str,'Fontsize',12);
ylabel(ylabel_str,'Fontsize',12);

zoom on;

return
