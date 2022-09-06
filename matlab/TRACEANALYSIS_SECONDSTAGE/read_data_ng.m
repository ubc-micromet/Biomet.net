function trace_str = read_data(year, SiteID, ini_file, sourceDB, options)

% last modification: July 2, 2010

% revisions:
% July 2, 2010
%   -Nick added to handle hourly UBC Totem historical climate data, July
%    2, 2010
% Jan 24,2007 : Nick modified the loading of trace_str.timeVector to handle
%               high frequency data

% This function reads the data from the database.  Given the ini_file the function
% is able to determine what stage of the cleaning process should be applied (ie first of second stage)
% Note however that data is not cleaned in this stage;  data is mearly read from the database
% and in the case of the second stage clean data is read from the database (followed by calculations 
% on the data.


%Input:	'Year' - year of the data to be read
%			'SideId' - site Id of the data to be read
%			'ini_file' - file path for the ini file (first or second stage)
%			'options' - currently not used (not required), default is 'none'
%			'sourceDB' - used to specify location of database, can either be 'database' 
%   						(default path of database) or contains the path of the database 
%							to be read(not required), default is 'database'

%Output: 'trace_str' - an array of traces organized in a particular trace structure
%                      See the function 'read_ini_file' for more information


%-------------------------------------------------------------------------------------
% Set argument defaults
bgc = [0 0.36 0.532];

if ~exist('year') | isempty(year)
   year = datevec(now);
   year = year(1);
end

% Empty year will be filled in from the ini file

if exist('ini_file')~=1 | isempty(ini_file)
   ini_file = biomet_path('Calculation_Procedures\TraceAnalysis_ini',SiteID);
   ini_file = fullfile(ini_file,[SiteID '_FirstStage.ini']);
end

if ~exist('options') | isempty(options)
	options = 'none';   
end

if ~exist('sourceDB') | isempty(sourceDB)
   sourceDB = 'database';
end

%-------------------------------------------------------------------------------------
% Handle the path - all site specific generation should be done via function in
% biomet_path('Calculation_Procedures\TraceAnalysis_ini',SiteID,'Derived_Variables')
addpath( biomet_path('Calculation_Procedures\TraceAnalysis_ini',SiteID,'Derived_Variables'))

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
      disp(['File, ' ini_file ', is invalid']);
      trace_str = [];
      return
   end
   % end kai*
end

%-------------------------------------------------------------------------------------
% Read each line of the initialization file and add the fields associated 
% with each trace to the array of traces. 
flag_read_ini = 0;
if exist('ini_file') & ~isempty(ini_file)   
   trace_str = read_ini_file(fid,year);     
   fclose(fid);
   if isempty(trace_str)
      return
   end
end

% Fill in the empty year
if ~exist('SiteID') | isempty(SiteID)
   SiteID = upper(trace_str(1).SiteID);
end
% Make SiteID current
if ~strcmp(upper(fr_current_SiteID),upper(SiteID))
   fr_set_site(SiteID,'network');
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


%--------------------------------------------------------------------------------
%Read from database or some local directory:

%Set basic variables
allTraces = 1:length(trace_str);

%Itterate through all traces
count = 1;										%Count tracks the which trace indice to use						
len = length(allTraces);					%flag for end of traces to load 
done = 'no';									%need two control flags to control this while loop.
error_count = 0;								%counts the number of errors encountered during reading
addTimeInfo = 0;								%flag for adding in DOY and timeVector to the trace struture
currentFlag = 0;								%flag for determining if the current traces should be saved to the workspace
bermsData = [];								%holds all the data from the berms database, filled only if at least one trace has data in the berms database
bermsPath = '';								%holds the path location of the berms database

%Break up search path into correct parts
if isfield(trace_str(1),'searchPath')
   [searchPath, remainder] = strtok( strrep(trace_str(1).searchPath, ',', ' ' ));
else
   searchPath = [];
end

%Determine which path to load into DB
while ~isempty( searchPath )
   switch searchPath
	  case 'low_level'
         pth_full = biomet_path(year,SiteID,'cl');
         ind_y = findstr(pth_full,num2str(1999));
         if ~isempty(ind_y)
            pth_full(ind_y:ind_y+3) = num2str(year);
         end
         pth_full = pth_full(1:end-8);
         initializeWorkSpaceTraces( [pth_full 'Climate\Clean\'] ); %load all the traces into the workspace, used by second stage reading
			initializeWorkSpaceTraces( [pth_full 'Profile\Clean\'] ); %load all the traces into the workspace, used by second stage reading		
			initializeWorkSpaceTraces( [pth_full 'Flux\Clean\'] ); %load all the traces into the workspace, used by second stage reading		
            %Added February 2, 2006 (dgg)
            initializeWorkSpaceTraces( [pth_full 'Chambers\Clean\'] ); %load all the traces into the workspace, used by second stage reading		
     case 'high_level'
        for pth = trace_str(1).high_level_path
           pth_full = biomet_path(year,SiteID,char(pth));
           ind_y = findstr(pth_full,num2str(1999));
           if ~isempty(ind_y)
              pth_full(ind_y:ind_y+3) = num2str(year);
           end
           initializeWorkSpaceTraces(pth_full); %load all the traces into the workspace, used by second stage reading
        end
      case 'current'
         %currently not used as when the trace is evaluated it is saved in the current workspace,
         %  over-writing any variable with the same name (ie current is always on, with the highest priority)
         currentFlag = 1;      
    end
    
    [searchPath, remainder] = strtok( remainder );
 end 

%Verify that the clean_tv structure is loaded 
if exist('clean_tv')~=1 & isfield(trace_str(1).ini,'Evaluate1')
   disp(['Warning: Unable to find trace clean_tv, output traces may not contain fields DOY or timeVector']);
end
if exist('clean_tv')~=1
   addTimeInfo = 0;
else 
   addTimeInfo = 1;
end

% Cycle thru traces
numberTraces = length(trace_str);

% Create waitbar --added name of trace to waitbar (crs)
h = waitbar_ubc(0,'Reading traces from database ...','DefaultTextInterpreter','none');
set(h,'Color',bgc);
set(h,'Name','Reading traces from database ...');
set(get(h,'Children'),'Color',bgc,'LineWidth',0.5);
set(get(get(h,'Children'),'Title'),'Color',[1 1 1])
h1 = get(get(h,'Children'),'Children');
set(h1(1),'Color',[1 1 1]);

disp('Reading traces from database ...');

for countTraces = 1:numberTraces
    
    trace_out = trace_str(countTraces);   
    h = waitbar_ubc(countTraces/numberTraces,h,trace_out.variableName);

   
   %Load the next trace into trace_out
   if isfield(trace_str(countTraces),'ini')								%make sure it has ini field.               
         
      if isfield(trace_str(countTraces).ini,'Evaluate1')       %if the data needs to be evaluated
         trace_out = evaluate_trace( trace_out, countTraces );	  %evaluate the trace (second stage only)       
      else
         
         %Create timeVector and DOY (first stage only)
%          try
%             trace_out = createTimeVector( trace_out );
%          catch
%             trace_out.Error = 1;  %Set the error code to a read error
%          end
%          
         trace_out = read_single_trace( trace_out, sourceDB);   					%read raw data from the database
                                             
      end
      
   end      
   
   %If the trace has data (ie it was loaded) then save it to the trace structure
   % otherwise output an error message and don't save the trace to the trace structure
   if trace_out.Error == 0
      % disp(['Loaded Trace: ' trace_str(countTraces).ini.variableName]);
      trace_str(countTraces) = trace_out;
      
      if addTimeInfo == 1 & (length(trace_str(countTraces).data) == 17520 | length(trace_str(countTraces).data) == 17568)
	     %Add the time Vector
		  trace_str(countTraces).timeVector = clean_tv;     
          %Add Day of Year (DOY) vector
          trace_str(countTraces).DOY = convert_tv( clean_tv,'doy' );
      % handles FSP 3min PAR data
      elseif addTimeInfo == 1 & (length(trace_str(countTraces).data) == 175200 | length(trace_str(countTraces).data) == 175680)
           trace_str(countTraces).timeVector = clean_3min_tv;
           trace_str(countTraces).DOY = convert_tv( clean_3min_tv,'doy' );  
      % Nick added to handle Mark Johnson's WaterQ 10 min data
      elseif addTimeInfo == 1 & (length(trace_str(countTraces).data) == 52560 | length(trace_str(countTraces).data) == 52704)
           trace_str(countTraces).timeVector = clean_10min_tv;
           trace_str(countTraces).DOY = convert_tv( clean_10min_tv,'doy' ); 
      % Nick added to handle hourly UBC Totem historical climate data, July
      % 2, 2010
      elseif addTimeInfo == 1 & (length(trace_str(countTraces).data) == 8760 | length(trace_str(countTraces).data) == 8808)
           trace_str(countTraces).timeVector = clean_hourly_tv;
           trace_str(countTraces).DOY = convert_tv( clean_hourly_tv,'doy' ); 
      end        
     
     %Set the data_old to data
     trace_str(countTraces).data_old = trace_str(countTraces).data;
         
  else
      %if there is an error display an error message for the users information
      disp(['*** Read Error: ' trace_str(countTraces).ini.variableName ' not loaded']);
      error_count = error_count + 1;
   end   
      
end


% Round timeVector 
for countTraces = 1:numberTraces
    if mean(diff(trace_str(countTraces).timeVector)) > 1/48-1/86400 & mean(diff(trace_str(countTraces).timeVector)) < 1/48+1/86400 ...
       & ~exist('timeVector')
        timeVector = fr_round_hhour(trace_str(1).timeVector);
    end
    if mean(diff(trace_str(countTraces).timeVector)) > 1/48-1/86400 & mean(diff(trace_str(countTraces).timeVector)) < 1/48+1/86400
        trace_str(countTraces).timeVector = timeVector;
    end
end

%Close the status bar window
if ishandle(h)
   close(h);
end

if error_count > 0
	%display error message for users reference
%   out_p=questdlg( [ 'Error during reading of traces from database:' num2str(error_count) ' trace(s) not loaded, see command window for more details'],'WARNING','Continue','Continue');
end

