function trace_str = TA_FirstStage(year,SiteId,ini_file,mat_file,options,fix_flag)
% trace_str = TA_FirstStage(year,SiteId,ini_file,mat_file,options)
%
% This program reads the indicated initialization file, which contains all
% the traces that are available while running this program.  The '.mat' file
% contains extra information not included with the ini_file, such as points
% manually removed and restored.  The mat_file also includes all the other 
% statistics and initialization information present at its creation.	
% Each trace is sequentially loaded into the current workspace and cleaned according
% to the specifications in the ini_file(and mat_file). A menu will allow users to select
% which traces to clean, view, and export.
%
% 	Input: 
%	  year		- default is the current year
%	  SiteId		- default is fr_current_siteid
%    ini_file	- the initialization file lists all traces present. The default is 
%                the first stage ini file for year and SiteId, in 
%					  \\ANNEX001\DATABASE\Calculation_Procedures\TraceAnalysis_ini
%    mat_file	- the '.mat' file contains all the extra information
%		  	   	  not included with the ini_file.(used if ini_file not included).
%	  options	- a flag indicating if the menu should be viewed.('no','view menu','change names')
%					  'change names' overwrites the names in the matfile with those from the ini-file.
%					  This provides a way to change names in already cleaned data.
%
% 	Output:
%    -This program will prompt the user to save the new mat_file.
%     The new mat_file will contain all the recent stats,ini_file information and 
%     the removed and restored points.
%
%
%  Notes:-See DB_documents for more information about ini_files, mat_files.
%	Location:---
%-------------------------------------------------------------------------------------

% Revisions: kai* 10 Nov, 2000: Added option 'change names'
%            Elyn 07.11.01: Added year option to allow for year-independent ini files

%-------------------------------------------------------------------------------------
% Set argument defaults
arg_default('fix_flag',0);
if ~exist('year') | isempty(year)
   year = datevec(now);
   year = year(1);
end
if ~exist('SiteId') | isempty(SiteId)
   SiteId = fr_current_siteid;
   fr_set_site(SiteId,'network'); % Use defautl setup if no SiteId is provided, otherwise use current set up
end
if exist('ini_file')~=1 | isempty(ini_file)
   ini_file = biomet_path('Calculation_Procedures\TraceAnalysis_ini',SiteId);
   ini_file = fullfile(ini_file,[SiteId '_FirstStage.ini']);
end
if~exist('mat_file')
   mat_file = biomet_path('Calculation_Procedures\TraceAnalysis_ini',SiteId);
   mat_file = fullfile(mat_file,[SiteId '_' num2str(year) '_FirstStage.mat']);
   % Here we have to ask the user whether he acutally wants to use this
   if exist(mat_file)
      answer = questdlg(['Do you want to use ' mat_file '?'],'Choose *.mat file','Yes','No','Cancel','Yes');
      switch answer
      case 'Yes'
         % Do nothing
      case 'No'
         mat_file = '';
      case 'Cancel'
         return
      end
   else
      mat_file = '';
   end
end
if exist('options')~=1 | isempty(options)
   options = 'view menu';
	ind_toView = [];
elseif strcmp(lower(options),'check')
   options = 'no';
   ind_toView = 1:15;
else
	ind_toView = [];
end

%-------------------------------------------------------------------------------------
%Open initialization file if it is present:
if exist('ini_file') & ~isempty(ini_file)
   ind = find(ini_file==filesep);
   if isempty(ind)      
      temp = which(ini_file);
      if isempty(temp)      
         error([ini_file ' does not exist in the matlab search path'])
      end
      indTemp = find(temp==filesep);
      lc_path = temp(1:indTemp(end));
   else
      % kai* May 30, 2001
      % Before this read lc_path = '';
      lc_path = ini_file(1:ind(end));
   end   
   fid = fopen(ini_file,'rt');						%open text file for reading only.   
   if (fid < 0)
      error(['File, ' ini_file ', is invalid']);
   end
   % end kai*
end

%Load the .mat file containing the array of traces as defined in the function description.
old_structure = '';
if exist('mat_file') & ~isempty(mat_file)
   ind_mat_path = find(mat_file == filesep);
   if isempty(ind_mat_path)
      temp = which(mat_file);								%locate path of input mat_file.
      if isempty(temp)
         error([mat_file ' does not exist in the matlab search path'])
      end
      ind = find(temp==filesep);
      lc_path = temp(1:ind(end));
   else
      % kai* May 30, 2001
      % Before this read lc_path = '';
      lc_path = ini_file(1:ind(end));
   end   
   temp = load(mat_file);   		%load structure array into current workspace.
   fldNms = fieldnames(temp);		%get the fieldnames of the temp variable.
   
   try
      %try to read the data just loaded:
      lasterr('');
      trace_str = getfield(temp,char(fldNms(1)));
   catch
      disp(['An error reading ' mat_file  ' has occurred!']);
		trace_str='';
      lasterr      
      return      
   end 
   
   % ----------------------------------------------------------------------
   % This has to be done to avoid 17521 as an entry and has to be for all
   % ini-files up to 2000 that were used while the time bug was in effect.
   if fix_flag
       if leapyear(trace_str(1).Year)
           obs = 17568;
       else
           obs = 17520;
       end
       
       for i = 1:length(trace_str)
           trace_str(i).pts_restored = trace_str(i).pts_restored-1;
           trace_str(i).pts_restored = trace_str(i).pts_restored(find(trace_str(i).pts_restored>0)); 
           
           trace_str(i).pts_removed = trace_str(i).pts_removed-1;
           trace_str(i).pts_removed  = trace_str(i).pts_removed(find(trace_str(i).pts_removed>0)); 
           if length(trace_str(i).interpolated)>obs
               trace_str(i).interpolated = trace_str(i).interpolated(2:obs+1); 
           elseif length(trace_str(i).interpolated)==obs
               trace_str(i).interpolated = [trace_str(i).interpolated(2:obs);NaN]; 
           end
       end
   end
   % End of time bug fix
   % ----------------------------------------------------------------------
   
   %trace_str should be a structure array:
   if ~isstruct(trace_str)
       error([lc_path mat_file ' does not contain the the ini_file information.'])
   else
       old_structure = trace_str;							%Keep track of this structure,
   end  															 %contains stats or removed points
end																 %used when reading the ini_file.

%-------------------------------------------------------------------------------------
% Read each line of the initialization file and add the fields associated 
% with each trace to the array of traces. 
flag_read_ini = 0;
if exist('ini_file') & ~isempty(ini_file)   
   trace_str = read_ini_file_old(fid,year);     
   fclose(fid);
   if isempty(trace_str)
      return
   end
end

%-------------------------------------------------------------------------------------
%Get optional input from user from main menu screen:
ind_toClean = 1:length(trace_str);					%default: clean all traces present.
file_opts.format = 'bnc';								%export file type(binary by default)
file_opts.in_path = 'database';						%Data import
file_opts.out_path = lc_path;							%Data export
% kai* 06.09.00
% This before read
% file_opts.days = [1 366];	%full year
% I insert the diff to GMT so that all site have the GMT year exported by default
Year = trace_str(1).Year;
NumDays =  datenum(Year+1,1,1) - datenum(Year,1,1) + 1;
doydiff = trace_str(1).Diff_GMT_to_local_time/24;
file_opts.days = [1-doydiff NumDays-doydiff];	%full GMT year
% end kai*
if strcmp(lower(options),'view menu')
   try
      [ind_traces,button_font ]= Initload_screen('init',trace_str,lc_path);%open menu 
   catch
      ind_traces = '';
      return
   end   
   if ~isempty(ind_traces)
      ind_toClean = ind_traces.ind_clean;			%index of traces to do basic cleaning
      ind_toView = ind_traces.ind_view;			%index of traces to view(pick points)
      ind_toExport = ind_traces.ind_export;
      if ~isempty(ind_traces.opts)
         file_opts = ind_traces.opts;				%track input,output paths for data
			      											%and various other information
         % kai* 06.09.00
         % Incase file_opts.days is 1 to end_of_year the the diff to GMT is added so 
         % that all site have the GMT year exported by default
         if file_opts.days(1) == 1 & file_opts.days(2) == NumDays 
            file_opts.days = [1-doydiff NumDays-doydiff];	%full GMT year
         end
         % end kai*
      end
   else
      return
   end
% kai* 10 Nov, 2000
% I inserted these lines since otherwise ind_toExport is uninitialized for options other 
% than 'view menu'
else
   ind_toExport = 0;
% end kai*
end

% kai* June 4, 2001
%--------------------------------------------------------------------------------
% Check whether the export directories exist
if ~isempty(ind_toExport) & ind_toExport ~= 0
    TA_check_export_path(file_opts,trace_str(ind_toExport));
end

%--------------------------------------------------------------------------------
%Find all dependencies listed in the initialization file for each trace:
[trace_str,ct]= find_all_dependent(trace_str);
if ct > 0
   [trace_out,ind] = clean_all_dependents(trace_str,file_opts.in_path,ct);
   if isempty(trace_out)      
      str = ['Could not find the data file for: ' trace_str(ind).variableName '!'];
      disp(str);
      trace_str = [];  
      return
   else      
      trace_str = trace_out;
   end
end

% kai* 10 Nov, 2000
% I inserted this so names in the matfile can be changed by changing them in the *.ini
% file and copying these changes. 
if strcmp(lower(options),'change names')
	if exist('old_structure') & ~isempty(old_structure)          
        if length(trace_str) ~= length(old_structure)
            warndlg('Cannot proceed. *.ini file and *.mat file must contain the same number of traces','Warning','modal');
            return
        else
            temp = questdlg('Changing name in a *.mat file will only work if no entirely new trace have been inserted.',...
                    'Warning','Abort','Continue','Abort');
            switch temp
            case 'Abort'
                return
            case 'Continue'
                disp('Renamed traces:');
            end
        end
      ind_diff = find(strcmp({trace_str.variableName},{old_structure.variableName}) == 0);
      for i = ind_diff
	     disp(['Change ' old_structure(i).variableName ' to ' trace_str(i).variableName]);
         % kai* June 12, 2001
         % old_strucure was spelled here, fixed that bug
         old_structure(i).variableName = trace_str(i).variableName;
      end
   else
      disp('Cannot change names if no *.mat file is given!');
   end
end
% end kai*

if exist('old_structure') & ~isempty(old_structure)          
   %Check for differences between the mat_file and the ini_file:
   result = compare_trace_str(trace_str,old_structure,ini_file); 
   if strcmp(result,'cancel')
      return
   end      
   %The old_structure contains all the information inside the input '.mat' file
   %which is not stored in the corresponding ini_file.  So the extra 'stats'
   %field must be included:      
   [val ind_new ind_old] = intersect({trace_str.variableName},{old_structure.variableName});      
   for i=1:length(ind_new)
      if isfield(old_structure(ind_old(i)),'stats') & ...
            isfield(old_structure(ind_old(i)).stats,'index')         
         if isfield(old_structure(ind_old(i)).stats.index,'pts_restored')
            trace_str(ind_new(i)).pts_restored = ...
               old_structure(ind_old(i)).stats.index.pts_restored;     
         end
         if isfield(old_structure(ind_old(i)).stats.index,'pts_removed')
            trace_str(ind_new(i)).pts_removed = ...
               old_structure(ind_old(i)).stats.index.pts_removed;     
         end
      end
      if isfield(old_structure(ind_old(i)),'interpolated');
         trace_str(ind_new(i)).interpolated = old_structure(ind_old(i)).interpolated;
      end
      if isfield(old_structure(ind_old(i)),'pts_removed');
         trace_str(ind_new(i)).pts_removed = old_structure(ind_old(i)).pts_removed;
      end
      if isfield(old_structure(ind_old(i)),'pts_restored');
         trace_str(ind_new(i)).pts_restored = old_structure(ind_old(i)).pts_restored;
      end      
   end    
end

%Get name for mat_file
if ~isempty(ini_file)
    if ~isempty(year);
        temp_ind1 = find(ini_file == '_');
        temp_ind2 = find(ini_file == '.');
        sv_fn = [ini_file(1:temp_ind1(end)) ...
                num2str(year) ini_file(temp_ind1(end):temp_ind2(end)-1) '.mat'];	%default save as ini_file name.
    else 
        temp_ind = find(ini_file == '.');
        sv_fn = [ini_file(1:temp_ind(end)-1) '.mat'];			%default save as ini_file name.
    end    
end
																	%OR
if ~isempty(old_structure)											%save as old mat_file name.
   sv_fn = mat_file;													
end
file_opts.sv_fn = sv_fn;

%--------------------------------------------------------------------------------
%This section will set up the default font sizes for the various user interface controls:
old_ax_font = get(0,'defaultaxesfontsize');
set(0,'defaultaxesfontsize',10);
old_ui_font = get(0,'defaultuicontrolfontsize');
set(0,'defaultuicontrolfontsize',9);

%--------------------------------------------------------------------------------
%This is the control loop for running the program.  Each trace is sequentially loaded
%with the call to the helper function 'load_single_trace'.  The trace is cleaned with the 
%parameters set in the ini_file, and then viewed with the point picking tool.
%Once the user quits the point picking tool, the trace is optionally exported.
%When the helper function returns(with the changed state of all the traces),
%the trace is implicitly removed from the current workspace(since the helper function
%creates its own workspace).  Depending on the command given in the visual pointpicking
%tool, either the program will terminate, goto the next trace, or goto the previous trace.
%These are the initialization variables for this loop:
trace_str(1).ind_toView = ind_toView; 		%Used to keep track of which trace is first/last.
count=1;												%Count tracks the which trace indice to use						
len = length(ind_toClean);						%flag for end of traces to clean
done = 'no';						%need two control flags to control this while loop.
cont = 'yes';						%for commands within the point picking tool.
state_pos = [];					%track the state of the visual point picking tool.
export_mat = [];
while strcmp(done,'no')
   i = ind_toClean(count);			%get first index of trace
   ptpk = 0;							%flags indicating if this trace should be viewed/exported
   export_trc = 0; 
   
   %load first trace structure:
   if isfield(trace_str(i),'ini')								%make sure has ini field.
      if ismember(i,ind_toView) & strcmp(cont,'yes')
         ptpk = 1;													%set flag to view trace.
      end
      if ismember(i,ind_toExport)
         export_trc = 1;											%set flag to export trace.
      end       
      file_opts.trcInd = i;
      %Clean,View, and export trace data using the helper function:
      [trace_str action state_pos export_mat clean_tv flag_array] = ...
         load_single_trace(trace_str,ptpk,export_trc,file_opts,state_pos,export_mat);
      
	  % kai* May 31, 2001
      % Update the flag for the cleaned trace - moved initialisation of flag up front
      if ~isempty(ind_toExport) & ind_toExport~=0 ...
             & length(ind_toClean) == length(trace_str) & strcmp(file_opts.format,'bnc') == 1
          % Initialize if neccessary
          if ~exist('flag_matrix') 
              bytes = ceil(length(trace_str)/8);
              flag_matrix = zeros(length(clean_tv),bytes);
          end       
          flag_matrix = set_flag(flag_matrix,flag_array,i);
      end       
      %end kai* 
      
      %Determine which trace to look at next(either next or previous), or quit program
      %or continue looping but without viewing traces:
      switch action
      case 'terminate'
         if ptpk==1
             delete(state_pos.fig_top);
         end
         cont='no';done='yes';
      case 'quit'
         cont = 'no';
         % kai* 14 June, 2001
         % Quit now is the regular way of continuing and the window is then killed
         delete(state_pos.fig_top);
         % end kai*
         if count < len
            count = count + 1;
         else
            done = 'yes';
         end         
      case 'prev'
         if count > 1
            count = count - 1;
         end
      case 'next'
         if count < len
            count = count + 1;
         % kai* 13 Dec, 2000
         % Before, there was no else statement
         % Therefore, the loop did not terminate
         else
            done = 'yes';
         % end kai*
         end
      otherwise			
         if count == len
            done = 'yes';
         else
            count = count + 1;
         end
      end      
   end
end

% kai* 13.01.2001
% Save the matrix that contains the flags 
% kai* 14 June, 2001
% The flag matrix is now saved in all the output directories
% kai* Nov 21, 2001
% Removed the saving again, Elyn will think of something better
if exist('flag_matrix')
        path = [file_opts.out_path 'climate\clean\'];
%        save_bor([path 'clean_flag'],2,flag_matrix,bytes);
        path = [file_opts.out_path 'flux\clean\'];
%        save_bor([path 'clean_flag'],2,flag_matrix,bytes);
        path = [file_opts.out_path 'profile\clean\'];
%        save_bor([path 'clean_flag'],2,flag_matrix,bytes);
end       
% end kai*

if ~isempty(export_mat)
   trace_str(ind_toExport(1)).timeVector = clean_tv;
   berms_table_export(trace_str(ind_toExport),[],file_opts,export_mat);
end

%--------------------------------------------------------------------------------
%This section will reset the default font sizes for the various user interface controls:

set(0,'defaultaxesfontsize',old_ax_font);
set(0,'defaultuicontrolfontsize',old_ui_font);

%Viewing/Cleaning is now finished. 
%--------------------------------------------------------------------------------

%Save trace_str as a matlab '.mat' file.  This file is the data file containing the 
%structure array associated with the current initialization file.
% kai* June, 13, 2001
% changed [lc_path sv_fn] to [sv_fn]
if ~(~isempty(ind_toView) & strcmp(lower(options),'no'))
   [fn,savepath] = uiputfile([sv_fn],'Save Matlab Trace Array:');
   if fn~=0
      save([savepath fn], 'trace_str');							%save new .mat file.
   end
end


%--------------------------------------------------------------------------------
%--------------------------------------------------------------------------------
function [list_of_traces, action, state_pos,export_mat,clean_tv,flag_array] = ...
   load_single_trace(list_of_traces,ptpk,export_trc,file_opts,state_pos,export_mat)
% This function loads each input trace into the current workspace.  After this
% trace is loaded, it is cleaned according to the specifications in the ini_file and/or
% mat_file.  If the flag ptpk is set to 1, then this trace will be loaded
% into the visual point selecting tool.  Using this tool, points in the trace can 
% then be selected manually(removed or restored) and the information saved 
% into the output trace structure.  After the optional visual inspection is done,
% the trace is removed from the current workspace(by default) and the next trace
% loaded.
% Input:		trace_in: 			is the current trace being worked on(as matlab structure).
%				ptpk: 				is a binary flag indicating if trace should be viewed.
%				list_of_traces: 	is the top structure containing all trace variables.
%										Only used for reading,(in visual inspection of trace_in).
% Output:	trace_out:			The cleaned trace including all new removed and restored
%										points, and the cleaning statistics.

action = 'next';		%default action is to go to the next trace
trace_in = list_of_traces(file_opts.trcInd);
%First check if the current trace contains a valid measurement identification:
% if ~ismember({trace_in.ini.measurementType},{'cl','fl','ch','pr','BERMS'})
%    str = ['Invalid Site identification ''' trace_in.ini.measurementType ''' for trace: ' trace_in.variableName '!'];
%    disp(str);
%    out_p=questdlg(str,'WARNING','Quit','Continue','Continue');
%    action = 'not_present';
%    trace_out = '';
%    return
% end

%--------------------------------------------------------------------------------
%Read from database or some local directory:

if strcmp(file_opts.in_path,'database')
   try
      str = ['Could not load ' trace_in.variableName ' from the database!'];
      trace_in = ta_load_from_db(trace_in);		%load trace from DB (keeping structure form).
   catch
      %display error message and return from this function depending on user input:
      disp(str);
      out_p=questdlg(str,'WARNING','Quit','Continue','Continue');
      trace_in.data = [];
      switch out_p
      case 'Quit'
         action = 'terminate';
      otherwise
         action = 'not_present';
      end    
   end   
else   
   try
      str = ['Could not load ' trace_in.variableName ' from ' file_opts.in_path];
      trace_in = ta_load_from_path(trace_in,file_opts.in_path);		%load trace from inpath(keeping structure form).
   catch
      %display error message and return from this function depending on user input:
      disp(str);
      out_p=questdlg(str,'WARNING','Quit','Continue','Continue');
      trace_in.data = [];
      switch out_p
      case 'Quit'
         action = 'terminate';
      otherwise
         action = 'not_present';
      end    
   end   
   % end kai*
end
%if any problems then quit and go to the next trace:
if isempty(trace_in.data) | isempty(trace_in.DOY)
   return
end  

%-------------------------------------------------------------------------------------
%if no problem loading the raw data from database, local, or cache memory
%then display which trace is loaded, and then do the basic cleaning:
disp(['Loading Trace: ' trace_in.ini.variableName]);
cln = clean_traces(trace_in);				%do the basic cleaning on the trace.   
cln_out = ta_update_statistics(cln);
if ~isempty(cln_out)
   cln = cln_out;
end
list_of_traces(file_opts.trcInd).stats = cln.stats;

if isfield(cln,'pts_restored') & ~isempty(cln.pts_restored)
   cln.data(cln.pts_restored) = cln.data_old(cln.pts_restored);
end
if isfield(cln,'pts_removed') & ~isempty(cln.pts_removed)
   %Reset all interpolated values:
   cln.data(cln.pts_removed) = NaN;
   if isfield(cln,'interpolated') & ~isempty(cln.interpolated)   
      cln.data(cln.pts_removed) = cln.interpolated(cln.pts_removed);   
   end
end

%------------------------------------------------------------------------------
%Use visual point picking tool.
if ptpk==1    
   file_opts.state_pos = state_pos;		%Keep last window position and other state information.   
   ind_update = traceAnalysis_tool(cln,list_of_traces,'no',file_opts);     
   if isempty(ind_update)
      action = 'not_present';
      trace_out = '';
      return
   end   
   %These values are the returned state from the pointpicking tool:
   list_of_traces = ind_update.list_of_traces;    
   temp_data = ind_update.data;
   action = ind_update.program_action;
   state_pos = ind_update.state_pos;     
% insert kai* 05.09.00
% If trace is not viewed (i.e. ptpk~=1) then temp_data is uninitialized and causes an
% error if export_trc==1 and file_opts.format=='bnc'. Also action is always 'next'
else
   temp_data = cln.data;
   if file_opts.trcInd == length(list_of_traces)
      action = 'terminate';
   end
% end kai* 05.09.00
end

% kai* May 31, 2001
% Moved flag array determination out of export section because it is needed even
% if the current trace is not export
flag_array = find_good_measurements(cln);
[n m] = size(flag_array);
if m>n 
   keyboard;
end
clean_tv = cln.timeVector;
% end kai*

%--------------------------------------------------------------------------------
%Export selected traces to the appropriate directory.
%requires some initial configuration details on the first menu screen.
if export_trc==1    
   % kai* 15 Dec, 2000
   % Output is now done within this function, which is common between
   % first and second stage cleaning.
   if ~exist('export_mat')
      export_mat = [];
   end
   export_mat = trace_export(file_opts,cln,export_mat);
   clean_tv = cln.timeVector;
   % end kai*
end
