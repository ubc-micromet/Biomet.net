function [answer,button_font]= Initload_screen(action,trace_str,lc_path)
%This is the initial setup menu used with the 'load_traces_local' function.
%Functionality:
%		1.		Choose traces to clean/view/export.
%		2.		Choose input path location of uncleaned raw traces.
%		3.		Choose output path of cleaned traces, data format, and range of days.	
%
%	Input:		'action' 	-the callback flag for the different buttons
%					'trace_str'	-the array of structure containing various info on all traces
%									located in the initialization file.
%					'lc_path'	-the local path where the ini_file and/or mat_file were found.
%
%	Output:		'Answer'		-contains all the setup information that the user specifies
%									from the setup screen.

if ~exist('action') | isempty(action)
   action ='init';								%initialize interface
end
if ~exist('lc_path') | isempty(lc_path)
   lc_path ='';									%default matlab path used(or current directory)
end

switch action
case 'init'
   %figure options:
   color_bg = [.85 .85 .85];   
   rec_pos = get(0,'screensize');	%check screen resolution and set offset if necessary
   offset = 0;
   font_offset = 0;
   if rec_pos(4)>=766
      offset = 150;
      font_offset = 2;
   end
   len = length(trace_str);
    
   %Create the menu screen:  
   fig_num = figure('handlevisibility','on','IntegerHandle','off',...
      'NumberTitle','off','MenuBar','none','color',color_bg,...
      'Name','Load Traces from Database:',...
      'position',[80 40 650+offset*1.5 530+offset],'Tag','options: On');
   
   %first test the what size the fonts are: large, small, etc...        
   h = uicontrol(fig_num,...
      'style','text','units','pixels',...
      'position',[150 150 200 25],...
      'string','TEST',...
      'fontunits','pixels','FontSize',12);   
   hght = get(h,'extent');
   delete(h);
   
   if hght(4) < 20
      button_font = 12 + font_offset;
   else
      button_font = 8 + font_offset;
   end  
   
   h = uicontrol(fig_num,...
      'style','text','units','normalized',...
      'position',[0.05 0.92 .9 .05],...
      'string',['SITE:   ' trace_str(1).Site_name],...
      'HorizontalAlignment','left','backgroundcolor',color_bg,...
      'FontSize',button_font+6,'FontWeight','bold');
   h = uicontrol(fig_num,...
      'style','text','units','normalized',...
      'position',[0.05 0.85 .9 .05],...
      'string',['YEAR : ' num2str(trace_str(1).Year)],...
      'HorizontalAlignment','left','backgroundcolor',color_bg,...
      'FontSize',button_font+6,'FontWeight','bold');   
 
   h = uicontrol(fig_num,...
      'style','text','units','normalized',...
      'position',[0.075 0.75 .3 .04],...
      'string','Options:','backgroundcolor',color_bg,'FontWeight','bold',...
      'HorizontalAlignment','left','fontsize',button_font); 
   h = uicontrol(fig_num,...
      'style','text','units','normalized','HorizontalAlignment','left',...
      'position',[0.075 0.45 .3 .04],...
      'string','Setup:','backgroundcolor',color_bg,'FontWeight','bold',...
      'fontsize',button_font); 
   h_path_in = uicontrol(fig_num,...
      'style','text','units','normalized',...
      'position',[0.1 0.40 .85 .04],...
      'string','Input Path:	[Biomet Group Database]','HorizontalAlignment','left',...
      'fontsize',button_font,'backgroundcolor',color_bg);
   h_path_out = uicontrol(fig_num,...
      'style','text','units','normalized',...
      'position',[0.1 0.35 .85 .04],...
      'string',['Output Path:	' lc_path],'HorizontalAlignment','left',...
      'fontsize',button_font,'backgroundcolor',color_bg);   
   h_exp = uicontrol(fig_num,...
      'style','text','units','normalized',...
      'position',[0.1 0.3 .85 .04],...
      'string','Export Format:	Binary Cleaned	(Database Format)',...
      'HorizontalAlignment','left',...
      'fontsize',button_font,'backgroundcolor',color_bg);
   %get number of days:
   Year = trace_str(1).Year;
   NumDays =  datenum(Year+1,1,1) - datenum(Year,1,1) + 1;
   dayend   = num2str(NumDays);  

   h_day = uicontrol(fig_num,...
      'style','text','units','normalized',...
      'position',[0.1 0.25 .85 .04],...
      'string',['Day Of Year:	First Day: 1 Last Day: ' dayend],...
      'HorizontalAlignment','left',...
      'fontsize',button_font,'backgroundcolor',color_bg);   
   % end kai*
        
   h_cancel = uicontrol(fig_num,...
      'style','push','units','normalized','HorizontalAlignment','left',...
      'position',[0.03 0.03 .2 .05],...
      'fontsize',button_font,'string','Cancel','callback','Initload_screen(''cancel'')');
   h_start = uicontrol(fig_num,...
      'units','normalized','style','push','HorizontalAlignment','left',...
      'position',[0.77 0.03 .2 .05],...
      'fontsize',button_font,...
      'string','Start','callback','Initload_screen(''start'')');
   h_setup = uicontrol(fig_num,...
      'units','normalized','style','push','HorizontalAlignment','left',...
      'position',[0.4 0.03 .2 .05],...
      'fontsize',button_font,...
      'string','Setup','callback','Initload_screen(''setup'')');
   
   h_export = uicontrol(fig_num,...
      'style','push','units','normalized','HorizontalAlignment','left',...
      'fontsize',button_font,'position',[0.1 0.54 .4 .05],...
      'string','Choose Traces To Export','callback','Initload_screen(''export'')');
   h_view = uicontrol(fig_num,...
      'units','normalized','style','push','HorizontalAlignment','left',...
      'fontsize',button_font,'position',[0.1 0.61 .4 .05],...
      'string','Choose Traces To Check','callback','Initload_screen(''view'')');
   h_clean = uicontrol(fig_num,...
      'units','normalized','style','push','HorizontalAlignment','left',...
      'fontsize',button_font,'position',[0.1 0.68 .4 .05],...
      'string','Choose Traces To Load','callback','Initload_screen(''clean'')'); 
   
   ex = uicontrol(fig_num,...
      'style','text','HorizontalAlignment','left',...
      'units','normalized','position',[0.6 .54 0.45 .04],...
      'fontsize',button_font,'string','Number Traces Chosen: 0',...
      'BackgroundColor',color_bg);   
   vw = uicontrol(fig_num,...
      'style','text','HorizontalAlignment','left',...
      'units','normalized','position',[0.6 .61 0.45 .04],...      
      'fontsize',button_font,'string',['Number Traces Chosen: ' num2str(len)],...
      'BackgroundColor',color_bg);
   cl = uicontrol(fig_num,...
      'style','text','HorizontalAlignment','left',...
      'units','normalized','position',[0.6 .68 0.45 .04],...
      'fontsize',button_font,'string',['Number Traces Chosen: ' num2str(len)],...
      'BackgroundColor',color_bg);
   top.chosen = [cl vw ex];			%handles of count text ouputs
   top.ex_hndls = [h_path_in h_path_out h_exp h_day];%handles of setup path and days
   top.trace_str = trace_str;			%copy of array of trace structures
   top.ini_sel = [1:len];
   top.ind_toClean = [1:len];			%index of traces to clean
   top.lc_path = lc_path;
   top.set_up = [];
   %Reset figure options for callbacks and close requests:
   set(gcf,'CloseRequestFcn','Initload_screen(''cancel'')',...
      'UserData',top,'handlevisibility','callback');
   %Wait for button press(which reset the tag for the screen menu):
   waitfor(fig_num,'Tag','options: Off');
   
   %get the current setup information:
   top_dat = get(fig_num,'UserData');
   if ~isempty(top_dat)
      answer.ind_view = [1:len];						%indices of traces to view
      answer.ind_export = [];							%indices of traces to export
      answer.ind_clean = top_dat.ind_toClean;	%indices of traces to clean
      answer.opts = top_dat.set_up;					%setup options(input/ouput paths...)
      if isfield(top_dat,'ind_toView')
         answer.ind_view = top_dat.ind_toView;
      end   
      if isfield(top_dat,'ind_toExport')
         answer.ind_export = top_dat.ind_toExport;
      end 
   else
      answer='';
   end  
   delete(fig_num);			%close menu screen
case 'clean'
   top = get(gcf,'UserData');
   TraceNames= {top.trace_str.variableName};			%Trace names of all present in ini_file
  
   %prompt user for list to clean:
   [ind_toClean,ok] = listdlg('PromptString','Select Traces to Clean:',...
      'ListString',TraceNames,'ListSize',[300 400],...
      'InitialValue',top.ini_sel,'name','select_clean');    

   
   if ok ~= 0
      top.ini_sel = ind_toClean;
      top.ind_toClean = ind_toClean;		%track all traces chosen
      top.ind_toView = ind_toClean;
      len = length(ind_toClean);   
      %Update text counts printed on the menu screen:
      set(top.chosen(1),'String',['Number Traces Chosen: ' num2str(len)]);
      set(top.chosen(2),'String',['Number Traces Chosen: ' num2str(len)]);
      if isfield(top,'ind_toExport')
         temp = ind_toClean;
         top.ind_toExport =intersect(temp,top.ind_toExport);
         set(top.chosen(3),'String',...
            ['Number Traces Chosen: ' num2str(length(top.ind_toExport))]);
      end
   end
   set(gcf,'UserData',top);
   
case 'view'
   top = get(gcf,'UserData');
   TraceNames = {top.trace_str.variableName};		%only view traces that are being cleaned
   TraceNames = TraceNames(top.ind_toClean);
   
   %prompt user to pick traces to view from those being cleaned:
   [ind_toView,ok] = listdlg('PromptString','Select Traces to View:','ListSize',[300 400],...
      'ListString',[TraceNames, {'NONE'}],'InitialValue',[1:length(TraceNames)]);          
 
   
   %Update traces to view:
   if ok ~= 0
      if max(ind_toView) > length(top.ind_toClean)
         if length(ind_toView) ==1
            ind_toView = [];
         else
            ind_toView = ind_toView(1:end-1);
         end
      end
      
      top.ind_toView = top.ind_toClean(ind_toView);        
      len = length(top.ind_toView);
      set(top.chosen(2),'String',['Number Traces Chosen: ' num2str(len)]);
   else
      return
   end
   set(gcf,'UserData',top);
   
case 'export'
   top = get(gcf,'UserData');
   TraceNames={top.trace_str.variableName};
   TraceNames = TraceNames(top.ind_toClean); 
   
   %prompt user for traces to export from those being cleaned:
   [ind_toExport,ok] = listdlg('PromptString','Select Traces to Export:',...
      'ListString',[TraceNames,{'NONE'}],'InitialValue',[1:length(TraceNames)],...
      'ListSize',[300 400]); 
  
   
   %Update traces being exported:
   if ok ~= 0
      if max(ind_toExport) > length(top.ind_toClean)
         if length(ind_toExport) ==1
            ind_toExport = [];
         else
            ind_toExport = ind_toExport(1:end-1);
         end
      end
      
      top.ind_toExport = top.ind_toClean(ind_toExport);        
      len = length(top.ind_toExport);
      set(top.chosen(3),'String',['Number Traces Chosen: ' num2str(len)]);
   else
      return
   end
   set(gcf,'UserData',top);
case 'setup'
   top = get(gcf,'UserData');
   top.set_up = setup_menu_screen('init',top);
   if ~isempty(top.set_up)
      switch top.set_up.in_path
      case 'database'
        str_temp = '[Biomet Group Database]'; 
      otherwise
        str_temp = top.set_up.in_path;
      end
      set(top.ex_hndls(1),'string',['Input Path:	' str_temp]);
      switch top.set_up.out_path
      case 'database'
         str_temp = '[Biomet Group Database]'; 
      otherwise
         str_temp = top.set_up.out_path; 
      end
      set(top.ex_hndls(2),'string',['Output Path:	' str_temp]);
      switch top.set_up.format
      case 'bnc'
         str_form = 'Binary Cleaned   (Database Format)';
      case 'bnr'
         str_form = 'Binary Raw   (Database Format)';
      case 'txt'
         str_form = 'Text (.txt)';   
      case 'mat'
         str_form = 'Matlab Structure (.mat)';
      case 'mtc'
         str_form = 'Matlab Data Column (.mat)';
      end
      set(top.ex_hndls(3),'String',['Export Format:	' str_form]);
      set(top.ex_hndls(4),'String',['Day Of Year:	First Day: ' ...
            num2str(top.set_up.days(1)) '	Last Day: ' num2str(top.set_up.days(2))]);       
   end   
   set(gcf,'UserData',top);
case 'start'
   set(gcf,'Tag','options: Off');
case 'cancel'
   set(gcf,'UserData','','Tag','options: Off');
end
