function data_out = ta_plot_options(action,top)
%this function creates a menu screen to allow the user to setup the properties 
%of any of the plotted traces, filter envelopes, and selected points.
% INPUT: 	'action' is given by the calling function.
%				'top' contain all trace information associated with the current working trace.
%				See the function "TraceAnalysis_Tool" for more information about the 
%				Top level data structure:
% OUTPUT: 	'data_out' is the structure containing the changes in the plotting options.
%
switch action
case 'init'
   rec_pos = get(0,'screensize');
   offset = 0;
   font_offset = 0;
   if rec_pos(4)==768
      font_offset = 2;
      offset = 150; 
   end
   %find which axis are present and include them in the setup menu:
   str = 'Bottom Left';
   if ~isempty(top.curr_ax_hdl)
      str = strvcat(str,'Bottom Right');
   end
   if ~isempty(top.other_ax_hdl)
      str = strvcat(str, 'Top Left');
   end
   if ~isempty(top.other_ax_hdl_right)
      str = strvcat(str, 'Top Right');
   end
   
   %Initiale the available working trace data sets:
   trcs_on_ax = ['Working Trace  ';
      'Original Trace ';
      'Selected Points';
      'Envelope       '];
   curr_ax = 1;
   for i=1:length(top.trc_plot_params(curr_ax).index)
      trcs_on_ax = strvcat(trcs_on_ax,...
         top.list_of_traces(top.trc_plot_params(curr_ax).index(i)).variableName);
   end
   curr_col = top.init_colors(1,:);
   
   %create the dialog:
   h_diag=dialog('handlevisibility','callback','IntegerHandle','off',...
      'NumberTitle','off','MenuBar','none',...
      'Name','Choose Color and Symbol','position',[100 100 475+offset*0.8 375+offset],...
      'Tag','pick color');
   
    %Test the font size:
   h = uicontrol(h_diag,...
      'style','text','units','pixels',...
      'position',[150 150 200 25],...
      'string','TEST',...
      'fontunits','pixels','FontSize',12);   
   hght = get(h,'extent');
   delete(h);
   
   if hght(4) < 20
      button_sz = 12 + font_offset;
   else
      button_sz = 8 + font_offset;
   end      
   
   h_t = uicontrol(h_diag,'style','text','Units','normalized','position',[0.05 0.9 0.3 0.05],...
      'string','   Current Axis: ','fontsize',button_sz,'HorizontalAlignment','left');
   h_ax_ch =uicontrol(h_diag,'style','popup','Units','normalized','position',[0.35 0.9 0.5 0.05],...
      'string',str,'fontsize',button_sz,'BackgroundColor',[1 1 1],'value',1,...
      'callback','ta_plot_options(''update_axis'')');
   h_t = uicontrol(h_diag,'style','text','Units','normalized','position',[0.05 0.8 0.3 0.05],...
      'string','Current Trace: ','fontsize',button_sz,'HorizontalAlignment','left');
   h_trc =uicontrol(h_diag,'style','popup','Units','normalized','position',[0.35 0.8 0.5 0.05],...
      'string',trcs_on_ax,'fontsize',button_sz,'BackgroundColor',[1 1 1],'value',1,...
      'callback','ta_plot_options(''update_trc'')');
   
   h_t =uicontrol(h_diag,'style','Text','Units','normalized','position',[0 0.6 0.2 0.05],...
      'string','Color:','fontsize',button_sz,'HorizontalAlignment','right');
   h_col =uicontrol(h_diag,'style','Text','Units','normalized','position',[0.3 0.6 0.25 0.05],...
      'string','','fontsize',button_sz,'backgroundcolor',curr_col);
   h_t =uicontrol(h_diag,'style','push','Units','normalized','position',[0.65 0.6 0.3 0.05],...
      'string','Change Color','fontsize',button_sz,'callback','ta_plot_options(''ch_col'')');
   
   h_t =uicontrol(h_diag,'style','Text','Units','normalized','position',[0 0.5 0.2 0.05],...
      'string','Symbol:','fontsize',button_sz,'HorizontalAlignment','right');
   h_sym =uicontrol(h_diag,'style','Text','Units','normalized','position',[0.3 0.5 0.25 0.05],...
      'string',char(top.init_symbols(1)),'fontsize',button_sz);
   h_t =uicontrol(h_diag,'style','push','Units','normalized','position',[0.65 0.5 0.3 0.05],...
      'string','Change Symbol','fontsize',button_sz,'callback','ta_plot_options(''ch_sym'')');
   
   h_t =uicontrol(h_diag,'style','Text','Units','normalized','position',[0 0.4 0.2 0.05],...
      'string','LineWidth:','fontsize',button_sz,'HorizontalAlignment','right');
   h_wdth =uicontrol(h_diag,'style','Text','Units','normalized','position',[0.3 0.4 0.25 0.05],...
      'string',num2str(top.init_width(1)),'fontsize',button_sz);
   h_t =uicontrol(h_diag,'style','push','Units','normalized','position',[0.65 0.4 0.3 0.05],...
      'string','Change Width','fontsize',button_sz,'callback','ta_plot_options(''ch_wdth'')');   
   
   h_t =uicontrol(h_diag,'style','Text','Units','normalized','position',[0 0.3 0.2 0.05],...
      'string','MarkerSize:','fontsize',button_sz,'HorizontalAlignment','right');
   h_size =uicontrol(h_diag,'style','Text','Units','normalized','position',[0.3 0.3 0.25 0.05],...
      'string',num2str(top.init_size(1)),'fontsize',button_sz);
   h_t =uicontrol(h_diag,'style','push','Units','normalized','position',[0.65 0.3 0.3 0.05],...
      'string','Change Size','fontsize',button_sz,'callback','ta_plot_options(''ch_size'')');

   h_cancel = uicontrol(h_diag,'style','push','Units','normalized','position',[0.05 0.05 0.2 0.05],...
      'string','Cancel','fontsize',button_sz,...
      'callback','ta_plot_options(''cancel'')');
   h_done = uicontrol(h_diag,'style','push','Units','normalized','position',[0.75 0.05 0.2 0.05],...
      'string','Done','fontsize',button_sz,...
      'callback','set(gcf,''Tag'',''done'')');
   %keep track of the handles for each property displayed on the text output:
   trc_opt.hndls = [h_ax_ch h_trc h_col h_sym h_wdth h_size];
   trc_opt.str = str;
   trc_opt.curr_ax = curr_ax;
   trc_opt.top = top;
   set(h_diag,'CloseRequestFcn','set(gcf,''Tag'',''cancel'')');
   set(h_diag,'UserData',trc_opt);
   waitfor(h_diag,'Tag');						%wait for the user to finish
   data_out='';
   if strcmp(get(h_diag,'Tag'),'done')
      trc_opt= get(h_diag,'UserData');		%return all values selected
      data_out = trc_opt.top;
   end
   delete(h_diag);
case 'ch_col'
   %change color for a particular trace currently selected:
   trc_opt = get(findobj('Tag','pick color'),'UserData');
   top = trc_opt.top;
   c = uisetcolor([0 0 0], 'DialogTitle');
   if ~any(c)
      return
   end 
   set(trc_opt.hndls(3),'backgroundcolor',c);
   ind = get(trc_opt.hndls(2),'Value');
    
   if trc_opt.curr_ax ==1
      if ind <=4
         top.init_colors(ind,1:3) = c;
      else
         ind = ind-4;
         top.trc_plot_params(trc_opt.curr_ax).color(ind,1:3) = c;
      end
   else
      top.trc_plot_params(trc_opt.curr_ax).color(ind,1:3) = c;     
   end
   trc_opt.top = top;
   set(findobj('Tag','pick color'),'UserData',trc_opt);
   
case 'ch_sym'
   %change symbol type for trace currently selected:
   trc_opt = get(findobj('Tag','pick color'),'UserData');
   sym = ['point .        ';
      'x-mark x       ';
      'plus +         ';
      'star *         ';
      'solid line -   ';
      'dotted line :  ';
      'dashed line -- ';
      'dashdot line -.';
      'circle o       ';
      'triangle  v    ';
      'triangle  ^    ';
      'triangle  >    ';
      'triangle  <    ';
      'square         ';
      'diamond        ';
      'pentagram      ';
      'hexagram       '];
   [s,answer] = listdlg('PromptString','Select a Symbol:',...
      'SelectionMode','single','ListString',sym);
   if answer==1
      temp = deblank(sym(s,:));
      if s < 14
         temp = temp(end-1:end);        
      end
      
      set(trc_opt.hndls(4),'String',temp);
      ind = get(trc_opt.hndls(2),'Value');
      if trc_opt.curr_ax ==1
         if ind <=4
            trc_opt.top.init_symbols(ind) = {temp};
         else
            ind = ind-4;
            trc_opt.top.trc_plot_params(trc_opt.curr_ax).symbol(ind) = {temp};
         end
      else
         trc_opt.top.trc_plot_params(trc_opt.curr_ax).symbol(ind) = {temp};     
      end
   end
   set(findobj('Tag','pick color'),'UserData',trc_opt);
    
case 'ch_wdth'
   %change line thickness for current data set selected:
   trc_opt = get(findobj('Tag','pick color'),'UserData');
   prompt={'Enter the line width:'};
   def={'1'};
   title='';
   lineNo=1;
   answer=inputdlg(prompt,title,lineNo,def);
   if ~isempty(answer)
      temp = char(answer);
      set(trc_opt.hndls(5),'String',temp);
      ind = get(trc_opt.hndls(2),'Value');
      if trc_opt.curr_ax ==1
         if ind <=4
            trc_opt.top.init_width(ind) = str2num(temp);
         else
            ind = ind-4;
            trc_opt.top.trc_plot_params(trc_opt.curr_ax).width(ind) = str2num(temp);
         end
      else
         trc_opt.top.trc_plot_params(trc_opt.curr_ax).width(ind) = str2num(temp);     
      end
   end
   set(findobj('Tag','pick color'),'UserData',trc_opt);
    
case 'ch_size'
   %Change marker size for symbol for current data selected:
   trc_opt = get(findobj('Tag','pick color'),'UserData');
   prompt={'Enter the marker size:'};
   def={'8'};
   title='';
   lineNo=1;
   answer=inputdlg(prompt,title,lineNo,def);
   if ~isempty(answer)
      temp = char(answer);
      set(trc_opt.hndls(6),'String',temp);
      ind = get(trc_opt.hndls(2),'Value');
      if trc_opt.curr_ax ==1
         if ind <=4
            trc_opt.top.init_size(ind) = str2num(temp);
         else
            ind = ind-4;
            trc_opt.top.trc_plot_params(trc_opt.curr_ax).size(ind) = str2num(temp);
         end
      else
         trc_opt.top.trc_plot_params(trc_opt.curr_ax).size(ind) = str2num(temp);     
      end
   end
   set(findobj('Tag','pick color'),'UserData',trc_opt);
   
case 'update_trc'
   %Update the current trace selected:
   ind = get(gcbo,'Value');
   trc_opt = get(findobj('Tag','pick color'),'UserData'); 
   
   if trc_opt.curr_ax ==1
      if ind <=4
         colr = trc_opt.top.init_colors(ind,1:3);
         symb = trc_opt.top.init_symbols(ind);
         wdth = trc_opt.top.init_width(ind);
         mksz = trc_opt.top.init_size(ind);         
      else
         colr = trc_opt.top.trc_plot_params(1).color(ind-4,1:3);
         symb = trc_opt.top.trc_plot_params(1).symbol(ind-4);
         wdth = trc_opt.top.trc_plot_params(1).width(ind-4);
         mksz = trc_opt.top.trc_plot_params(1).size(ind-4);         
      end
   else
      colr = trc_opt.top.trc_plot_params(trc_opt.curr_ax).color(ind,1:3);
      symb = trc_opt.top.trc_plot_params(trc_opt.curr_ax).symbol(ind);
      wdth = trc_opt.top.trc_plot_params(trc_opt.curr_ax).width(ind);
      mksz = trc_opt.top.trc_plot_params(trc_opt.curr_ax).size(ind);
   end
  
   set(trc_opt.hndls(3),'backgroundcolor',colr);
   set(trc_opt.hndls(4),'String',char(symb));
   set(trc_opt.hndls(5),'String',num2str(wdth));
   set(trc_opt.hndls(6),'String',num2str(mksz));
case 'update_axis'
   %Update the current axis looking at:
   ind = get(gcbo,'Value');
   trc_opt = get(findobj('Tag','pick color'),'UserData'); 
   switch deblank(trc_opt.str(ind,:))
   case 'Bottom Left'
      trc_opt.curr_ax = 1;
   case 'Bottom Right'
      trc_opt.curr_ax = 2;
   case 'Top Left'
      trc_opt.curr_ax = 3;
   case 'Top Right'
      trc_opt.curr_ax = 4;
   end
   ind_trcs = trc_opt.top.trc_plot_params(trc_opt.curr_ax).index;
   trc_names = {trc_opt.top.list_of_traces(ind_trcs).variableName};
   if trc_opt.curr_ax ==1
      trc_names = ['Working Trace','Original Trace',...
            'Selected Points','Envelope ' trc_names];
      colr = trc_opt.top.init_colors(1,1:3);
      symb = trc_opt.top.init_symbols(1);
      wdth = trc_opt.top.init_width(1);
      mksz = trc_opt.top.init_size(1);          
   else
      colr = trc_opt.top.trc_plot_params(trc_opt.curr_ax).color(1,1:3);
      symb = trc_opt.top.trc_plot_params(trc_opt.curr_ax).symbol(1);
      wdth = trc_opt.top.trc_plot_params(trc_opt.curr_ax).width(1);
      mksz = trc_opt.top.trc_plot_params(trc_opt.curr_ax).size(1);
   end
   set(trc_opt.hndls(2),'String',trc_names);
   set(trc_opt.hndls(3),'backgroundcolor',colr);
   set(trc_opt.hndls(4),'String',char(symb));
   set(trc_opt.hndls(5),'String',num2str(wdth));
   set(trc_opt.hndls(6),'String',num2str(mksz));
   set(findobj('Tag','pick color'),'UserData',trc_opt);
case 'cancel'
   
end
